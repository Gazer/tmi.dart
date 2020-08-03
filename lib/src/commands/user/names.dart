import 'package:logger/src/logger.dart';
import 'package:tmi/src/commands/command.dart';
import 'package:tmi/src/message.dart';
import 'package:tmi/tmi.dart';

class Names extends Command {
  Names(Client client, Logger log) : super(client, log);

  @override
  void call(Message message) {
    var channel = message.params[2];
    var names = message.params[3].split(" ");
    client.emit("names", [channel, names]);
  }
}
