import 'package:logger/src/logger.dart';
import 'package:tmi/src/message.dart';
import 'package:tmi/tmi.dart';

import 'command.dart';

class Pong extends Command {
  Pong(Client client, Logger log) : super(client, log);

  @override
  void call(Message message) {
    var currDate = DateTime.now();
    client.currentLatency = (currDate.millisecondsSinceEpoch -
            client.latency.millisecondsSinceEpoch) ~/
        1000;
    client.emit("pong", [client.currentLatency]);
  }
}
