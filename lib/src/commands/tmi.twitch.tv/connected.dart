import 'package:logger/logger.dart';
import 'package:tmi/src/commands/command.dart';
import 'package:tmi/src/message.dart';
import 'package:tmi/tmi.dart';
import 'package:tmi/src/utils.dart' as _;

class Connected extends Command {
  Connected(Client client, Logger log) : super(client, log);

  @override
  void call(Message message) {
    client.emit("connected");
    client.startMonitor();

    _join(client.channels);
  }

  Future _join(String channel) async {
    channel = _.channel(channel);

    client.sendCommand(null, null, "JOIN $channel", () {
      // no-op
      return true;
    });

    client.on("_promiseJoin", (error, joinedChannel) {
      if (channel == _.channel(joinedChannel)) {
        //emitter.removeListener("_promiseJoin", listener);
        print("JOINED!");
      }
    });

    // TODO: Race timeout and return future
    //Future.delayed(Duration(seconds: 10))
    //.then((value) => if (!hasFulfilled) return false);
  }
}
