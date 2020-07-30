import 'package:logger/src/logger.dart';
import 'package:tmi/src/commands/command.dart';
import 'package:tmi/src/message.dart';
import 'package:tmi/tmi.dart';
import 'package:tmi/src/utils.dart' as _;

class Whisper extends Command {
  Whisper(Client client, Logger log) : super(client, log);

  @override
  void call(Message message) {
    var msg = _.get(message.params, 1);

    var nick = message.prefix.split("!")[0];
    log.i("[WHISPER] <${nick}>: ${msg}");

    // Update the tags to provide the username..
    if (!message.tags.containsKey("username")) {
      message.tags['username'] = nick;
    }
    message.tags["message-type"] = "whisper";

    var from = _.channel(message.tags['username']);
    // Emit for both, whisper and message..
    client.emit("whisper", [from, message.tags, msg, false]);
    client.emit("message", [from, message.tags, msg, false]);
  }
}
