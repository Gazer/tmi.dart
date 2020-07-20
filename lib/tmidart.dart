library tmidart;

import 'package:websok/io.dart';
import 'package:eventify/eventify.dart';

import 'src/message.dart';

class Client {
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

  Client({this.channels, this.secure})
      : _sok = IOWebsok(host: 'irc-ws.chat.twitch.tv', tls: secure);

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
        "CAP REQ :twitch.tv/tags twitch.tv/commands twitch.tv/membership");
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
    var channel = _channel(message.params[0]);
    var msg = _get(message.params, 1);
    var msgid = message.tags["msg-id"];

    // Parse badges, badge-info and emotes..
    // TODO
    // message.tags = parse.badges(parse.badgeInfo(parse.emotes(message.tags)));

    // Transform IRCv3 tags..
    // TODO

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
        case "002":
        case "003":
        case "004":
        case "375":
        case "376":
        case "CAP":
          break;
        // Retrieve username from server..
        case "001":
          username = message.params[0];
          break;
        // Connected to server..
        case "372":
          _emit("connected");
          // TODO: Check logic for time out and multichannel
          _join(channels);
          break;

        // https://github.com/justintv/Twitch-API/blob/master/chat/capabilities.md#notice
        case "NOTICE":
          // TODO
          print("NOTICE: $msgid");
          break;
        // Handle subanniversary / resub..
        case "USERNOTICE":
          var username = message.tags["display-name"] ?? message.tags["login"];
          var plan = message.tags["msg-param-sub-plan"] ?? "";
          var planName = _unescapeIRC(message.tags["msg-param-sub-plan-name"]);
          var prime = plan.contains("Prime");
          var methods = {prime, plan, planName};
          var userstate = message.tags;
          var streakMonths =
              int.tryParse(message.tags["msg-param-streak-months"]) ?? 0;
          var recipient = message.tags["msg-param-recipient-display-name"] ??
              message.tags["msg-param-recipient-user-name"];
          var giftSubCount =
              int.tryParse(message.tags["msg-param-mass-gift-count"]) ?? 0;
          userstate["message-type"] = msgid;

          switch (msgid) {
            // Handle resub
            case "resub":
              _emit(
                "resub",
                [channel, username, streakMonths, msg, userstate, methods],
              );
              _emit(
                "subanniversary",
                [channel, username, streakMonths, msg, userstate, methods],
              );
              break;
            // Handle sub
            case "sub":
              _emit(
                "subscription",
                [channel, username, methods, msg, userstate],
              );
              break;
            // Handle gift sub
            case "subgift":
              _emit(
                "subgift",
                [
                  channel,
                  username,
                  streakMonths,
                  recipient,
                  methods,
                  userstate,
                ],
              );
              break;
            // Handle anonymous gift sub
            // Need proof that this event occur
            case "anonsubgift":
              _emit(
                "anonsubgift",
                [channel, streakMonths, recipient, methods, userstate],
              );
              break;
            // Handle random gift subs
            case "submysterygift":
              _emit(
                "submysterygift",
                [channel, username, giftSubCount, methods, userstate],
              );
              break;
            // Handle anonymous random gift subs
            // Need proof that this event occur
            case "anonsubmysterygift":
              _emit(
                "anonsubmysterygift",
                [channel, giftSubCount, methods, userstate],
              );
              break;
            // Handle user upgrading from Prime to a normal tier sub
            case "primepaidupgrade":
              _emit(
                "primepaidupgrade",
                [channel, username, methods, userstate],
              );
              break;
            // Handle user upgrading from a gifted sub
            case "giftpaidupgrade":
              var sender = message.tags["msg-param-sender-name"] ??
                  message.tags["msg-param-sender-login"];
              _emit("giftpaidupgrade", [channel, username, sender, userstate]);
              break;
            // Handle user upgrading from an anonymous gifted sub
            case "anongiftpaidupgrade":
              _emit("anongiftpaidupgrade", [channel, username, userstate]);
              break;
            // Handle raid
            case "raid":
              var username = message.tags["msg-param-displayName"] ??
                  message.tags["msg-param-login"];
              var viewers =
                  int.tryParse(message.tags["msg-param-viewerCount"]) ?? 0;
              _emit("raided", [channel, username, viewers, userstate]);
              break;
          }
          break;
        // Channel is now hosting another channel or exited host mode..
        case "HOSTTARGET":
          var msgSplit = msg.split(" ");
          var viewers = int.tryParse(msgSplit[1]) ?? 0;
          // Stopped hosting..
          if (msgSplit[0] == "-") {
            // this.log.info(`[${channel}] Exited host mode.`);
            _emit("unhost", [channel, viewers]);
            _emit("_promiseUnhost");
          } else {
            // Now hosting..
            // this.log.info(`[${channel}] Now hosting ${msgSplit[0]} for ${viewers} viewer(s).`);
            _emit("hosting", [channel, msgSplit[0], viewers]);
          }
          break;
        // Someone has been timed out or chat has been cleared by a moderator..
        case "CLEARCHAT":
          // TODO
          print("CLEARCHAT: $msgid");
          break;
        // Someone's message has been deleted
        case "CLEARMSG":
          if (message.params.length > 1) {
            var username = message.tags["login"];
            var deletedMessage = msg;
            var userstate = message.tags;
            userstate["message-type"] = "messagedeleted";

            // this.log.info(`[${channel}] ${username}'s message has been deleted.`);
            _emit(
              "messagedeleted",
              [channel, username, deletedMessage, userstate],
            );
          }
          break;
        // Received a reconnection request from the server..
        case "RECONNECT":
          // TODO
          print("RECONNECT: $msgid");
          break;
        case "USERSTATE":
          // TODO
          print("USERSTATE: $msgid");
          break;
        case "GLOBALUSERSTATE":
          this.globaluserstate = message.tags;

          // Received emote-sets..
          //if(typeof message.tags["emote-sets"] !== "undefined") {
          //	this._updateEmoteset(message.tags["emote-sets"]);
          //}
          break;
        case "ROOMSTATE":
          if (_channel(lastJoined) == channel) {
            _emit("_promiseJoin", [channel]);
          }

          message.tags['channel'] = channel;
          _emit("roomstate", [channel, message.tags]);
          break;
        // TODO: subs-only"
        // Wrong cluster..
        case "SERVERCHANGE":
          break;

        default:
          print("Could not parse message from tmi.twitch.tv:\n${message.raw}");
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
            //this.log.info(`Joined ${channel}`);
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

            //this.log.info(`Left ${channel}`);
            _emit("_promisePart");
          }

          // Client or someone else left the channel, emit the part event..
          _emit("part", [channel, nick, isSelf]);
          break;
        case "WHISPER":
          var nick = message.prefix.split("!")[0];
          //this.log.info(`[WHISPER] <${nick}>: ${msg}`);

          // Update the tags to provide the username..
          if (!message.tags.containsKey("username")) {
            message.tags['username'] = nick;
          }
          message.tags["message-type"] = "whisper";

          var from = _channel(message.tags['username']);
          // Emit for both, whisper and message..
          _emit("whisper", [from, message.tags, msg, false]);
          _emit("message", [from, message.tags, msg, false]);
          break;
        case "PRIVMSG":
          // Add username (lowercase) to the tags..
          message.tags['username'] = message.prefix.split("!")[0];

          if (message.tags['username'] == "jtv") {
            var name = _username(msg.split(" ")[0]);
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

  Future _join(String channel) async {
    channel = _channel(channel);

    _sendCommand(null, null, "JOIN $channel", () {
      // no-op
    });

    EventCallback listener;
    var hasFulfilled = false;
    listener = (Event ev, context) {
      var eventChannel = (ev.eventData as List)[0];
      if (channel == _channel(eventChannel)) {
        hasFulfilled = true;
        emitter.removeListener("_promiseJoin", listener);
        print("JOINED!");
      }
    };
    emitter.on("_promiseJoin", this, listener);

    // TODO: Race timeout and return future
    //Future.delayed(Duration(seconds: 10))
    //.then((value) => if (!hasFulfilled) return false);
  }

  Future<bool> _sendCommand(delay, String channel, command, Function fn) async {
    // Make sure the socket is opened..
    if (!_wsReady()) {
      // Disconnected from server..
      return false; //reject("Not connected to server.");
    }

    // Executing a command on a channel..
    if (channel != null && channel.isNotEmpty) {
      var chan = _channel(channel);
      print("[${chan}] Executing command: ${command}");
      _sok.send("PRIVMSG ${chan} :${command}");
    } else {
      // Executing a raw command..

      print("Executing command: ${command}");
      _sok.send(command);
    }
    return fn();
  }

  String _channel(String str) {
    var channel = (str ?? "").toLowerCase();
    return channel[0] == "#" ? channel : "#" + channel;
  }

  String _username(String str) {
    var channel = (str ?? "").toLowerCase();
    return channel[0] == "#" ? channel.substring(1) : channel;
  }

  String _get(List<String> list, int index) {
    if (index >= list.length) return null;

    return list[index];
  }

  // Escaping values:
  // http://ircv3.net/specs/core/message-tags-3.2.html#escaping-values
  String _unescapeIRC(String msg) {
    var unescapeIRCRegex = RegExp(r"\\([sn:r\\])", caseSensitive: false);
    var ircEscapedChars = {'s': ' ', 'n': '', ':': ';', 'r': ''};

    if (msg == null || !msg.contains('\\')) return msg;

    msg.replaceAllMapped(
      unescapeIRCRegex,
      (match) => ircEscapedChars[match[1]] ?? match[1],
    );
  }

  _emit(String type, [List params]) {
    emitter.emit(type, null, params);
  }
}
