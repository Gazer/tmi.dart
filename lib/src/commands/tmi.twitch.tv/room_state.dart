import 'package:logger/src/logger.dart';
import 'package:tmi/src/message.dart';
import 'package:tmi/tmi.dart';
import 'package:tmi/src/utils.dart' as _;

import '../command.dart';

class RoomState extends Command {
  RoomState(Client client, Logger log) : super(client, log);

  @override
  void call(Message message) {
    var channel = _.channel(message.params[0]);

    if (_.channel(client.lastJoined) == channel) {
      client.emit("_promiseJoin", [channel]);
    }

    message.tags['channel'] = channel;
    client.emit("roomstate", [channel, message.tags]);
  }
}
