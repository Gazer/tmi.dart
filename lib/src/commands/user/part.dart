import 'package:logger/src/logger.dart';
import 'package:tmi/src/message.dart';
import 'package:tmi/tmi.dart';
import 'package:tmi/src/utils.dart' as _;

import '../command.dart';

class Part extends Command {
  Part(Client client, Logger log) : super(client, log);

  @override
  void call(Message message) {
    var channel = _.channel(message.params[0]);
    var isSelf = false;
    var nick = message.prefix.split("!")[0];

    // Client left a channel..
    if (client.username == nick) {
      isSelf = true;
      if (client.userstate[channel] != null) {
        client.userstate.remove(channel);
      }

      var index = client.channels.indexOf(channel);
      //if(index != -1) { this.channels.splice(index, 1); }

      //var index = this.opts.channels.indexOf(channel);
      //if(index !== -1) { this.opts.channels.splice(index, 1); }

      log.i("Left ${channel}");
      client.emit("_promisePart");
    }

    // Client or someone else left the channel, emit the part event..
    client.emit("part", [channel, nick, isSelf]);
  }
}
