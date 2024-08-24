import 'package:tmi/src/commands/command.dart';
import 'package:tmi/src/message.dart';
import 'package:tmi/src/utils.dart' as _;

class Connected extends Command {
  Connected(super.client, super.log);

  @override
  void call(Message message) {
    client.emit("connected");
    client.startMonitor();

    _join(client.channels);
  }

  Future _join(String channel) async {
    channel = _.channel(channel);

    client.sendCommand<bool>(null, "JOIN $channel", () {
      // no-op
      return true;
    });

    client.on("_promiseJoin", (error, joinedChannel) {
      if (channel == _.channel(joinedChannel)) {
        //emitter.removeListener("_promiseJoin", listener);
      }
    });

    // TODO: Race timeout and return future
    //Future.delayed(Duration(seconds: 10))
    //.then((value) => if (!hasFulfilled) return false);
  }
}
