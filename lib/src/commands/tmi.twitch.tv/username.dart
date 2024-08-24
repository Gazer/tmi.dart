import 'package:tmi/src/message.dart';

import '../command.dart';

class Username extends Command {
  Username(super.client, super.log);

  @override
  void call(Message message) {
    client.username = message.params[0];
  }
}
