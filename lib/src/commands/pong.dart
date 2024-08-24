import 'package:tmi/src/message.dart';

import 'command.dart';

class Pong extends Command {
  Pong(super.client, super.log);

  @override
  void call(Message message) {
    var currDate = DateTime.now();
    client.currentLatency = (currDate.millisecondsSinceEpoch -
            client.latency.millisecondsSinceEpoch) ~/
        1000;
    client.emit("pong", [client.currentLatency]);
  }
}
