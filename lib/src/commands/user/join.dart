import 'package:logger/src/logger.dart';
import 'package:tmi/src/message.dart';
import 'package:tmi/tmi.dart';
import 'package:tmi/src/utils.dart' as _;

import '../command.dart';

class Join extends Command {
  Join(Client client, Logger log) : super(client, log);

  @override
  void call(Message message) {
    var channel = _.channel(message.params[0]);
    var nick = message.prefix.split("!")[0];

    // Joined a channel as a justinfan (anonymous) user.
    if (_.isJustinfan(client.username) && client.username == nick) {
      client.lastJoined = channel;
      //this.channels.push(channel);
      log.i("Joined ${channel}");
      client.emit("join", [channel, nick, true]);
    }

    // Someone else joined the channel, just emit the join event..
    if (client.username != nick) {
      client.emit("join", [channel, nick, false]);
    }
  }
}
