import 'package:logger/src/logger.dart';
import 'package:tmi/src/message.dart';
import 'package:tmi/tmi.dart';
import 'package:tmi/src/utils.dart' as _;

import 'command.dart';

// Someone has been timed out or chat has been cleared by a moderator..

class ClearChat extends Command {
  ClearChat(Client client, Logger log) : super(client, log);

  @override
  void call(Message message) {
    var channel = _.channel(message.params[0]);
    var msg = _.get(message.params, 1);

    // User has been banned / timed out by a moderator..
    if (message.params.length > 1) {
      // Duration returns null if it's a ban, otherwise it's a timeout..
      var duration = message.tags["ban-duration"];

      if (duration == null) {
        log.i("[${channel}] ${msg} has been banned.");
        client.emit("ban", [channel, msg, null, message.tags]);
      } else {
        log.i(
          "[${channel}] ${msg} has been timed out for ${duration} seconds.",
        );
        client.emit(
          "timeout",
          [channel, msg, null, int.tryParse(duration) ?? 0, message.tags],
        );
      }
    } else {
      // Chat was cleared by a moderator..
      log.i("[${channel}] Chat was cleared by a moderator.");
      client.emit("clearchat", [channel]);
      client.emit("_promiseClear", [null]);
    }
  }
}
