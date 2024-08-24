import 'package:tmi/src/message.dart';
import 'package:tmi/src/utils.dart' as _;

import '../command.dart';

class RoomState extends Command {
  RoomState(super.client, super.log);

  @override
  void call(Message message) {
    var channel = _.channel(message.params[0]);

    if (_.channel(client.lastJoined) == channel) {
      client.emit("_promiseJoin", [null, channel]);
    }

    message.tags['channel'] = channel;
    client.emit("roomstate", [channel, message.tags]);
  }
}
