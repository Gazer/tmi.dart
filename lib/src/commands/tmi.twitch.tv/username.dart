import 'package:logger/src/logger.dart';
import 'package:tmi/src/message.dart';
import 'package:tmi/tmi.dart';

import '../command.dart';

class Username extends Command {
  Username(Client client, Logger log) : super(client, log);

  @override
  void call(Message message) {
    client.username = message.params[0];
  }
}
