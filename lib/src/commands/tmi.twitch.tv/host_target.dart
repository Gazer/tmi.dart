import 'package:logger/logger.dart';
import 'package:tmi/src/message.dart';
import 'package:tmi/tmi.dart';
import 'package:tmi/src/utils.dart' as _;

import '../command.dart';
// Channel is now hosting another channel or exited host mode..

class HostTarget extends Command {
  HostTarget(Client client, Logger log) : super(client, log);

  @override
  void call(Message message) {
    var channel = _.channel(message.params[0]);
    var msg = _.get(message.params, 1);
    if (msg == null) {
      return;
    }

    var msgSplit = msg.split(" ");
    var viewers = int.tryParse(msgSplit[1]) ?? 0;
    // Stopped hosting..
    if (msgSplit[0] == "-") {
      log.i("[${channel}] Exited host mode.");
      client.emit("unhost", [channel, viewers]);
      client.emit("_promiseUnhost");
    } else {
      // Now hosting..
      log.i(
        "[${channel}] Now hosting ${msgSplit[0]} for ${viewers} viewer(s).",
      );
      client.emit("hosting", [channel, msgSplit[0], viewers]);
    }
  }
}
