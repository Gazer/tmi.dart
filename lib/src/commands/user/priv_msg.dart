import 'package:tmi/src/commands/command.dart';
import 'package:tmi/src/message.dart';
import 'package:tmi/src/utils.dart' as _;

class PrivMsg extends Command {
  PrivMsg(super.client, super.log);

  @override
  void call(Message message) {
    var channel = _.channel(message.params[0]);
    var msg = _.get(message.params, 1);
    if (msg == null) {
      return;
    }

    // Add username (lowercase) to the tags..
    message.tags['username'] = message.prefix.split("!")[0];

    if (message.tags['username'] == "jtv") {
      var name = _.username(msg.split(" ")[0]);
      var autohost = msg.contains("auto");

      if (msg.contains("hosting you for")) {
        // Someone is hosting the channel and the message contains how many viewers..
        var count = _.extractNumber(msg);

        client.emit("hosted", [channel, name, count, autohost]);
      } else if (msg.contains("hosting you")) {
        // Some is hosting the channel, but no viewer(s) count provided in the message..
        client.emit("hosted", [channel, name, 0, autohost]);
      }
    } else {
      // Message is an action (/me <message>)..
      var actionMessage =
          RegExp(r"^\u0001ACTION ([^\u0001]+)\u0001$").firstMatch(msg);
      message.tags["message-type"] = actionMessage != null ? "action" : "chat";

      msg = actionMessage != null ? actionMessage.group(1) : msg;
      // Check for Bits prior to actions message
      if (message.tags.containsKey("bits")) {
        client.emit("cheer", [channel, message.tags, msg]);
      } else {
        if (actionMessage != null) {
          // Action, tipically /me command
          client.emit("message", [channel, message.tags, msg, false]);
          client.emit("action", [channel, message.tags, msg, false]);
        } else {
          // Message is a regular chat message..
          client.emit("message", [channel, message.tags, msg, false]);
          client.emit("chat", [channel, message.tags, msg, false]);
        }
      }
    }
  }
}
