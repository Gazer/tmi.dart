import 'package:logger/src/logger.dart';
import 'package:eventify/eventify.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:tmi/src/commands/command.dart';
import 'package:tmi/src/commands/ping.dart';
import 'package:tmi/src/message.dart';
import 'package:tmi/tmi.dart';

class MockClient extends Mock implements Client {}

class MockLogger extends Mock implements Logger {}

void main() {
  var client;
  var logger;

  setUp(() {
    client = MockClient();
    logger = MockLogger();
  });

  test("ensure emit ping event", () {
    // GIVEN
    var message = Message();
    var command = Ping(client, logger);

    // WHEN
    command.call(message);

    // THEN
    verify(client.emit("ping"));
  });

  test("should send PONG response", () {
    var message = Message();
    var command = Ping(client, logger);

    // WHEN
    command.call(message);

    // THEN
    verify(client.send("PONG"));
  });
}
