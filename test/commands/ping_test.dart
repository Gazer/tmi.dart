import 'package:logger/logger.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:tmi/src/commands/ping.dart';
import 'package:tmi/src/message.dart';
import 'package:mockito/annotations.dart';
import 'package:tmi/tmi.dart';

import 'ping_test.mocks.dart';

@GenerateNiceMocks([MockSpec<Client>(), MockSpec<Logger>()])
void main() {
  var client;
  var logger;

  setUp(() {
    client = MockClient();
    logger = MockLogger();
  });

  test("ensure emit ping event", () {
    // GIVEN
    var message =
        Message(raw: "", tags: {}, prefix: "", command: "", params: []);
    var command = Ping(client, logger);

    // WHEN
    command.call(message);

    // THEN
    verify(client.emit("ping"));
  });

  test("should send PONG response", () {
    var message =
        Message(raw: "", tags: {}, prefix: "", command: "", params: []);
    var command = Ping(client, logger);

    // WHEN
    command.call(message);

    // THEN
    verify(client.send("PONG"));
  });
}
