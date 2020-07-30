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
    // TODO: Check logic for time out and multichannel
    _join(client.channels);
  }

  Future _join(String channel) async {
    channel = _.channel(channel);

    client.sendCommand(null, null, "JOIN $channel", () {
      // no-op
    });

    var hasFulfilled = false;
    client.on("_promiseJoin", (eventChannel) {
      if (channel == _.channel(eventChannel)) {
        hasFulfilled = true;
        //emitter.removeListener("_promiseJoin", listener);
        print("JOINED!");
      }
    });

    // TODO: Race timeout and return future
    //Future.delayed(Duration(seconds: 10))
    //.then((value) => if (!hasFulfilled) return false);
  }
}
