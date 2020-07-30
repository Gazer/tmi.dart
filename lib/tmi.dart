library tmidart;

import 'package:logger/logger.dart';
import 'package:websok/io.dart';
import 'package:eventify/eventify.dart';

import 'src/commands/command.dart';
import 'src/message.dart';
import 'src/utils.dart' as _;

class Client {
  var log = Logger(
    printer: PrettyPrinter(),
  );

  final String channels;
  final bool secure;
  final EventEmitter emitter = new EventEmitter();

  IOWebsok _sok;
  int currentLatency;
  DateTime latency = DateTime.now();
  String username;
  Map<String, dynamic> globaluserstate;
  Map<String, dynamic> userstate;
  String lastJoined;
  Map<String, List<String>> moderators = Map();
  Map<String, String> emotes;

  Map<String, Command> twitchCommands;

  Client({this.channels, this.secure})
      : _sok = IOWebsok(host: 'irc-ws.chat.twitch.tv', tls: secure) {
    twitchCommands = {
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
    };
  }

  void connect() {
    _sok.connect();
    _sok.listen(
      onData: _onData,
    );
    _onOpen();
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

  bool _wsReady() {
    return !((_sok == null) || !_sok.isActive);
  }

  void _onOpen() {
    if ((_sok == null) || !_sok.isActive) return;

    _emit("connecting");

    // check if we have username
    var username = "justinfan33";
    // get token for the user name
    // generate password from token
    var password = false;

    _emit("logon");
    _sok.send(
      "CAP REQ :twitch.tv/tags twitch.tv/commands twitch.tv/membership",
    );
    if (password) {
      _sok.send("PASS $password");
    }
    _sok.send("NICK $username");
  }

  void _onData(dynamic event) {
    var parts = (event as String).split("\r\n");

    parts
        .where((part) => part != null && part.isNotEmpty)
        .forEach((part) => _handleMessage(Message.parse(part)));
  }

  void _handleMessage(Message message) {
    if (emitter.getListenersCount("raw_message") > 0) {
      _emit("raw_message", [message]);
    }

    var channel = _.channel(message.params[0]);
    var msg = _.get(message.params, 1);
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
      switch (message.command) {
        // Received PING from server..
        case "PING":
          _emit("ping");
          if (_wsReady()) {
            _sok.send("PONG");
          }
          break;

        // Received PONG from server, return current latency..
        case "PONG":
          var currDate = DateTime.now();
          currentLatency = (currDate.millisecondsSinceEpoch -
                  latency.millisecondsSinceEpoch) ~/
              1000;
          _emit("pong", [currentLatency]);

          // clearTimeout(this.pingTimeout);
          break;

        default:
          print("Could not parse message with no prefix:\n${message.raw}");
          break;
      }
    } else if (message.prefix == "tmi.twitch.tv") {
      // Messages with "tmi.twitch.tv" as a prefix..
      switch (message.command) {
        // Retrieve username from server..
        case "001":
          username = message.params[0];
          break;
        // https://github.com/justintv/Twitch-API/blob/master/chat/capabilities.md#notice
        case "NOTICE":
          // TODO
          print("NOTICE: $msgid");
          break;
        // Received a reconnection request from the server..
        case "RECONNECT":
          // TODO
          print("RECONNECT: $msgid");
          break;
        case "GLOBALUSERSTATE":
          this.globaluserstate = message.tags;
          // Received emote-sets..
          //if(typeof message.tags["emote-sets"] !== "undefined") {
          //	this._updateEmoteset(message.tags["emote-sets"]);
          //}
          break;
        // TODO: subs-only"
        // Wrong cluster..
        case "SERVERCHANGE":
          break;

        default:
          if (twitchCommands.containsKey(message.command)) {
            var command = twitchCommands[message.command];
            command.call(message);
          } else {
            print(
                "Could not parse message from tmi.twitch.tv:\n${message.raw}");
          }
          break;
      }
    } else if (message.prefix == "jtv") {
      // Messages from jtv..

      print("JTV NOT SUPPORTED");
    } // Anything else..
    else {
      switch (message.command) {
        case "353":
          _emit("names", [message.params[2], message.params[3].split(" ")]);
          break;
        case "366":
          break;
        case "JOIN":
          var nick = message.prefix.split("!")[0];
          // Joined a channel as a justinfan (anonymous) user..
          if (username.contains("justinfan") && username == nick) {
            this.lastJoined = channel;
            //this.channels.push(channel);
            log.i("Joined ${channel}");
            _emit("join", [channel, nick, true]);
          }

          // Someone else joined the channel, just emit the join event..
          if (this.username != nick) {
            _emit("join", [channel, nick, false]);
          }
          break;
        case "PART":
          var isSelf = false;
          var nick = message.prefix.split("!")[0];
          // Client left a channel..
          if (this.username == nick) {
            isSelf = true;
            if (userstate[channel] != null) {
              userstate.remove(channel);
            }

            var index = this.channels.indexOf(channel);
            //if(index != -1) { this.channels.splice(index, 1); }

            //var index = this.opts.channels.indexOf(channel);
            //if(index !== -1) { this.opts.channels.splice(index, 1); }

            log.i("Left ${channel}");
            _emit("_promisePart");
          }

          // Client or someone else left the channel, emit the part event..
          _emit("part", [channel, nick, isSelf]);
          break;
        case "WHISPER":
          var nick = message.prefix.split("!")[0];
          log.i("[WHISPER] <${nick}>: ${msg}");

          // Update the tags to provide the username..
          if (!message.tags.containsKey("username")) {
            message.tags['username'] = nick;
          }
          message.tags["message-type"] = "whisper";

          var from = _.channel(message.tags['username']);
          // Emit for both, whisper and message..
          _emit("whisper", [from, message.tags, msg, false]);
          _emit("message", [from, message.tags, msg, false]);
          break;
        case "PRIVMSG":
          // Add username (lowercase) to the tags..
          message.tags['username'] = message.prefix.split("!")[0];

          if (message.tags['username'] == "jtv") {
            var name = _.username(msg.split(" ")[0]);
            var autohost = msg.contains("auto");
            // Someone is hosting the channel and the message contains how many viewers..
            if (msg.contains("hosting you for")) {
              var count = int.tryParse(msg);

              _emit("hosted", [channel, name, count, autohost]);
            }

            // Some is hosting the channel, but no viewer(s) count provided in the message..
            else if (msg.contains("hosting you")) {
              _emit("hosted", [channel, name, 0, autohost]);
            }
          } else {
            // Message is an action (/me <message>)..
            var actionMessage =
                RegExp(r"/^\u0001ACTION ([^\u0001]+)\u0001$/").firstMatch(msg);
            message.tags["message-type"] =
                actionMessage != null ? "action" : "chat";
            msg = actionMessage != null ? actionMessage : msg;
            // Check for Bits prior to actions message
            if (message.tags.containsKey("bits")) {
              _emit("cheer", [channel, message.tags, msg]);
            } else {
              if (actionMessage != null) {
                // Action, tipically /me command
                _emit("message", [channel, message.tags, msg, false]);
                _emit("action", [channel, message.tags, msg, false]);
              } else {
                // Message is a regular chat message..
                _emit("message", [channel, message.tags, msg, false]);
                _emit("chat", [channel, message.tags, msg, false]);
              }
            }
          }
          break;
        default:
          print("COMMAND ${message.command} not yet implemented");
      }
    }
  }

  Future<bool> sendCommand(delay, String channel, command, Function fn) async {
    return _sendCommand(delay, channel, command, fn);
  }

  Future<bool> _sendCommand(delay, String channel, command, Function fn) async {
    // Make sure the socket is opened..
    if (!_wsReady()) {
      // Disconnected from server..
      return false; //reject("Not connected to server.");
    }

    // Executing a command on a channel..
    if (channel != null && channel.isNotEmpty) {
      var chan = _.channel(channel);
      print("[${chan}] Executing command: ${command}");
      _sok.send("PRIVMSG ${chan} :${command}");
    } else {
      // Executing a raw command..

      print("Executing command: ${command}");
      _sok.send(command);
    }
    return fn();
  }

  emit(String type, [List params]) {
    _emit(type, params);
  }

  _emit(String type, [List params]) {
    emitter.emit(type, null, params);
  }
}
