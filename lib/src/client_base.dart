import 'dart:async';

import 'package:logger/logger.dart';
import 'package:tmi/src/monitor.dart';
import 'package:web_socket_client/web_socket_client.dart' as ws;

import 'client_emitter.dart';
import 'commands/command.dart';
import 'commands/ping.dart';
import 'commands/pong.dart';
import 'message.dart';
import 'utils.dart' as _;

class ClientBase extends ClientEmitter {
  var log = Logger(
    printer: PrettyPrinter(),
  );

  final String channels;
  final bool secure;

  ws.WebSocket _sok;
  late Monitor _monitor;
  late String clientId;
  String? token;

  int currentLatency = 0;
  DateTime latency = DateTime.now();
  String username = "";
  Map<String, dynamic>? globaluserstate;
  Map<String, dynamic> userstate = {};
  String lastJoined = "";
  Map<String, List<String>> moderators = Map();
  String emotes = "";
  Map<String, String> emotesets = {};
  bool wasCloseCalled = false;
  bool reconnect = false;
  String? reason;

  late Map<String, Command> twitchCommands;
  late Map<String, Command> noScopeCommands;
  late Map<String, Command> userCommands;

  ClientBase({required this.channels, required this.secure, ws.WebSocket? mock})
      : _sok = mock ?? ws.WebSocket(Uri.parse('ws://irc-ws.chat.twitch.tv')) {
    noScopeCommands = {
      "PING": Ping(this, log),
      "PONG": Pong(this, log),
    };

    twitchCommands = {
      "001": Username(this, log),
      "002": NoOp(this, log),
      "003": NoOp(this, log),
      "004": NoOp(this, log),
      "375": NoOp(this, log),
      "372": NoOp(this, log),
      "CAP": NoOp(this, log),
      "376": Connected(this, log),
      "USERNOTICE": UserNotice(this, log),
      "HOSTTARGET": HostTarget(this, log),
      "CLEARCHAT": ClearChat(this, log),
      "CLEARMSG": ClearMsg(this, log),
      "USERSTATE": UserState(this, log),
      "ROOMSTATE": RoomState(this, log),
      "SERVERCHANGE": NoOp(this, log),
      "NOTICE": Notice(this, log),
      "GLOBALUSERSTATE": GlobalUserState(this, log),
    };

    userCommands = {
      "JOIN": Join(this, log),
      "PART": Part(this, log),
      "WHISPER": Whisper(this, log),
      "PRIVMSG": PrivMsg(this, log),
      "366": NoOp(this, log),
      "353": Names(this, log),
    };

    _monitor = Monitor(this);
  }

  void connect() {
    _sok.messages.listen(_onData);
    _sok.connection.listen((state) {
      if (state is ws.Connected) {
        _onOpen();
      }
    });
  }

  void close() {
    _sok.close();
  }

  void startMonitor() {
    _monitor.loop();
  }

  bool _isReady() {
    return _sok.connection.state is ws.Connected;
  }

  void _onOpen() {
    if (!_isReady()) return;

    emit("connecting");

    // check if we have username
    var username = _.justinfan();
    // get token for the user name
    // generate password from token
    // var password = false;

    emit("logon");
    _sok.send(
      "CAP REQ :twitch.tv/tags twitch.tv/commands twitch.tv/membership",
    );
    //if (password) {
    //  _sok.send("PASS $password");
    //}
    _sok.send("NICK $username");
  }

  void _onData(dynamic event) {
    var parts = (event as String).split("\r\n");

    parts
        .where((part) => part.isNotEmpty)
        .forEach((part) => _handleMessage(Message.parse(part)));
  }

  void _handleMessage(Message? message) {
    if (message == null) {
      return;
    }

    if (getListenersCount("raw_message") > 0) {
      emit("raw_message", [message]);
    }

    var msgid = message.tags["msg-id"];

    // Parse badges, badge-info and emotes..
    message.tags.addAll(_.badges(_.badgeInfo(_.emotes(message.tags))));

    // Transform IRCv3 tags..
    if (message.tags.isNotEmpty) {
      var tags = message.tags;
      for (var key in tags.keys) {
        if (![
          "msg-param-streak-months",
          "msg-param-viewerCount",
          "msg-param-mass-gift-count",
          "emote-sets",
          "ban-duration",
          "bits"
        ].contains(key)) {
          dynamic value = tags[key];
          if (value.runtimeType == bool) {
            value = null;
          } else if (value == "1") {
            value = true;
          } else if (value == "0") {
            value = false;
          } else if (value.runtimeType == String) {
            value = _.unescapeIRC(value);
          }
          tags[key] = value;
        }
      }
    }

    // Messages with no prefix..
    if (message.prefix.isEmpty) {
      if (noScopeCommands.containsKey(message.command)) {
        noScopeCommands[message.command]?.call(message);
      } else {
        print("Could not parse message with no prefix:\n${message.raw}");
      }
    } else if (message.prefix == "tmi.twitch.tv") {
      // Messages with "tmi.twitch.tv" as a prefix..
      switch (message.command) {
        // https://github.com/justintv/Twitch-API/blob/master/chat/capabilities.md#notice
        // Received a reconnection request from the server..
        case "RECONNECT":
          // TODO
          print("RECONNECT: $msgid");
          break;
        // TODO: subs-only"
        // Wrong cluster..
        default:
          if (twitchCommands.containsKey(message.command)) {
            var command = twitchCommands[message.command];
            command?.call(message);
          } else {
            log.e(
              "Could not parse message from tmi.twitch.tv:\n${message.raw}",
            );
          }
          break;
      }
    } else if (message.prefix == "jtv") {
      // Messages from jtv..

      print("JTV NOT SUPPORTED");
    } // Anything else..
    else {
      if (userCommands.containsKey(message.command)) {
        userCommands[message.command]?.call(message);
      } else {
        log.e("COMMAND ${message.command} not yet implemented");
      }
    }
  }

  Future<T> sendCommand<T>(
    String? channel,
    command,
    FutureOr<T> Function() fn,
  ) async {
    return _sendCommand(0, channel, command, fn);
  }

  Future<T> _sendCommand<T>(
    delay,
    String? channel,
    command,
    FutureOr<T> Function() fn,
  ) async {
    // Make sure the socket is opened..
    if (!_isReady()) {
      // Disconnected from server..
      throw "Not connected to server.";
    }

    // Executing a command on a channel..
    if (channel != null && channel.isNotEmpty) {
      var chan = _.channel(channel);
      log.d("[${chan}] Executing command: PRIVMSG ${chan} :${command}");
      _sok.send("PRIVMSG ${chan} :${command}");
    } else {
      // Executing a raw command..

      log.d("Executing command: ${command}");
      _sok.send(command);
    }
    return fn();
  }

  String? getToken() {
    return null;
  }

  // Send a message to channel
  Future<T> sendMessage<T>(
    String channel,
    String message,
    Map<String, String> tags,
    T Function() fn,
  ) async {
    // Promise a result
    // Make sure the socket is opened and not logged in as a justinfan user
    if (!this._isReady()) {
      throw 'Not connected to server.';
    } else if (_.isJustinfan(username)) {
      throw 'Cannot send anonymous messages.';
    }
    final chan = _.channel(channel);
    if (!this.userstate.containsKey(chan)) {
      this.userstate[chan] = {};
    }

    // Split long lines otherwise they will be eaten by the server
    if (message.length > 500) {
      const maxLength = 500;
      final msg = message;
      var lastSpace = msg.substring(0, maxLength).lastIndexOf(' ');
      // No spaces found, split at the very end to avoid a loop
      if (lastSpace == -1) {
        lastSpace = maxLength;
      }
      message = msg.substring(0, lastSpace);

      //setTimeout(() =>
      //	this._sendMessage({ channel, message: msg.slice(lastSpace), tags })
      //, 350);
    }

    String formedTags = _.formTags(tags) ?? "";
    send("${formedTags}PRIVMSG ${chan} :${message}");

    // Merge userstate with parsed emotes
    // TODO
    // const userstate = Object.assign(
    // {},
    // this.userstate[chan],
    // { emotes: null }
    // );

    // Message is an action (/me <message>)
    final actionMessage = _.actionMessage(message);
    if (actionMessage != null) {
      userstate['message-type'] = 'action';
      log.d("[${chan}] *[$username]*: ${actionMessage[1]}");
      this.emits([
        'action',
        'message'
      ], [
        [chan, userstate, actionMessage, true]
      ]);
    } else {
      // Message is a regular chat message
      userstate['message-type'] = 'chat';
      log.d("[${chan}] [$username]: ${message}");
      this.emits([
        'chat',
        'message'
      ], [
        [chan, userstate, message, true]
      ]);
    }
    return fn();
  }

  /// This should not be called directly by tmi users
  void send(String command) {
    if (_isReady()) {
      _sok.send(command);
    }
  }
}
