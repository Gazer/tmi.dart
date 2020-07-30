import 'package:logger/src/logger.dart';
import 'package:tmi/src/message.dart';
import 'package:tmi/tmi.dart';
import 'package:tmi/src/utils.dart' as _;

import 'command.dart';

class UserState extends Command {
  UserState(Client client, Logger log) : super(client, log);

  @override
  void call(Message message) {
    var channel = _.channel(message.params[0]);

    message.tags['username'] = client.username;

    // Add the client to the moderators of this room..
    if (message.tags["user-type"] == "mod") {
      if (!client.moderators.containsKey(client.lastJoined)) {
        client.moderators[client.lastJoined] = [];
      }
      if (!client.moderators[client.lastJoined].contains(client.username)) {
        client.moderators[client.lastJoined].add(client.username);
      }
    }

    // Logged in and username doesn't start with justinfan..
    if (!client.username.contains("justinfan") &&
        client.userstate[channel] == null) {
      client.userstate[channel] = message.tags;
      client.lastJoined = channel;
      // this.channels.push(channel);
      log.i("Joined ${channel}");
      client.emit("join", [channel, _.username(client.username), true]);
    }

    // Emote-sets has changed, update it..
    if (message.tags["emote-sets"] != client.emotes) {
      _updateEmoteset(message.tags["emote-sets"]);
    }

    client.userstate[channel] = message.tags;
  }

  _updateEmoteset(String sets) {
    // this.emotes = sets;
  }
}
