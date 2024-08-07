library tmidart;

import 'package:logger/logger.dart';
import 'package:tmi/src/monitor.dart';
import 'package:eventify/eventify.dart';
import 'package:web_socket_client/web_socket_client.dart' as ws;

import 'src/commands/command.dart';
import 'src/commands/ping.dart';
import 'src/commands/pong.dart';
import 'src/message.dart';
import 'src/utils.dart' as _;

class Client {
  var log = Logger(
    printer: PrettyPrinter(),
  );

  final String channels;
  final bool secure;
  final EventEmitter emitter = new EventEmitter();

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

  Client({required this.channels, required this.secure})
      : _sok = ws.WebSocket(Uri.parse('ws://irc-ws.chat.twitch.tv')) {
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
      "376": NoOp(this, log),
      "CAP": NoOp(this, log),
      "372": Connected(this, log),
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

  Listener on(String event, Function f) {
    return emitter.on(event, this, (ev, context) {
      List params = ev.eventData as List;
      switch (params.length) {
        case 0:
          f();
          break;
        case 1:
          f(params[0]);
          break;
        case 2:
          f(params[0], params[1]);
          break;
        case 3:
          f(params[0], params[1], params[2]);
          break;
        case 4:
          f(params[0], params[1], params[2], params[3]);
          break;
        case 5:
          f(params[0], params[1], params[2], params[3], params[4]);
          break;
        case 6:
          f(params[0], params[1], params[2], params[3], params[4], params[5]);
          break;
        default:
          throw Exception("Got more params that I can handle");
      }
    });
  }

  void send(String command) {
    if (_wsReady()) {
      _sok.send(command);
    }
  }

  bool _wsReady() {
    return _sok.connection.state is ws.Connected;
  }

  void _onOpen() {
    if (!_wsReady()) return;

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

    if (emitter.getListenersCount("raw_message") > 0) {
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

  Future<bool> sendCommand(
      delay, String? channel, command, bool Function() fn) async {
    return _sendCommand(delay, channel, command, fn);
  }

  Future<bool> _sendCommand(
      delay, String? channel, command, bool Function() fn) async {
    // Make sure the socket is opened..
    if (!_wsReady()) {
      // Disconnected from server..
      return false; //reject("Not connected to server.");
    }

    // Executing a command on a channel..
    if (channel != null && channel.isNotEmpty) {
      var chan = _.channel(channel);
      log.d("[${chan}] Executing command: ${command}");
      _sok.send("PRIVMSG ${chan} :${command}");
    } else {
      // Executing a raw command..

      log.d("Executing command: ${command}");
      _sok.send(command);
    }
    return fn();
  }

  void emits(List<String> types, List values) {
    for (var i = 0; i < types.length; i++) {
      var val = i < values.length ? values[i] : values[values.length - 1];
      emit(types[i], val);
    }
  }

  void emit(String type, [List? params]) {
    emitter.emit(type, null, params);
  }

  String? getToken() {
    return null;
  }
}
