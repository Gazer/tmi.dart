import 'package:tmi/src/message.dart';
import 'package:tmi/src/utils.dart' as _;

import '../command.dart';

class UserState extends Command {
  UserState(super.client, super.log);

  @override
  void call(Message message) {
    var channel = _.channel(message.params[0]);

    message.tags['username'] = client.username;

    // Add the client to the moderators of this room..
    if (message.tags["user-type"] == "mod") {
      if (!client.moderators.containsKey(client.lastJoined)) {
        client.moderators[client.lastJoined] = [];
      }

      var moderators = client.moderators[client.lastJoined];
      if (moderators != null && !moderators.contains(client.username)) {
        moderators.add(client.username);
      }
    }

    // Logged in and username doesn't start with justinfan..
    if (!_.isJustinfan(client.username) && client.userstate[channel] == null) {
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
