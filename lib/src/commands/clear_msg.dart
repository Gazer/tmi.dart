import 'package:logger/src/logger.dart';
import 'package:tmi/src/message.dart';
import 'package:tmi/tmi.dart';
import 'package:tmi/src/utils.dart' as _;

import 'command.dart';

// Someone's message has been deleted
class ClearMsg extends Command {
  ClearMsg(Client client, Logger log) : super(client, log);

  @override
  void call(Message message) {
    var channel = _.channel(message.params[0]);
    var msg = _.get(message.params, 1);

    if (message.params.length > 1) {
      var username = message.tags["login"];
      var deletedMessage = msg;
      var userstate = message.tags;
      userstate["message-type"] = "messagedeleted";

      log.i("[${channel}] ${username}'s message has been deleted.");
      client.emit(
        "messagedeleted",
        [channel, username, deletedMessage, userstate],
      );
    }
  }
}
