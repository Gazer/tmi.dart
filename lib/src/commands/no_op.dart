import 'package:tmi/src/message.dart';

import 'command.dart';

class NoOp extends Command {
  NoOp(super.client, super.log);

  @override
  void call(Message message) {
    // No-op
  }
}
