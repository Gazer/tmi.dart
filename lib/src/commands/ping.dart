import 'package:logger/src/logger.dart';
import 'package:tmi/src/message.dart';
import 'package:tmi/tmi.dart';

import 'command.dart';

class Ping extends Command {
  Ping(Client client, Logger log) : super(client, log);

  @override
  void call(Message message) {
    client.emit("ping");
    client.send("PONG");
  }
}
