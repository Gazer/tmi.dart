import 'package:tmi/src/message.dart';

import 'command.dart';

class Ping extends Command {
  Ping(super.client, super.log);

  @override
  void call(Message message) {
    client.emit("ping");
    client.send("PONG");
  }
}
