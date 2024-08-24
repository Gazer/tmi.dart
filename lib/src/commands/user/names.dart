import 'package:tmi/src/commands/command.dart';
import 'package:tmi/src/message.dart';

class Names extends Command {
  Names(super.client, super.log);

  @override
  void call(Message message) {
    var channel = message.params[2];
    var names = message.params[3].split(" ");
    client.emit("names", [channel, names]);
  }
}
