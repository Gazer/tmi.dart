import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:tmi/src/commands/pong.dart';
import 'package:tmi/src/message.dart';

import '../mocks.dart';

void main() {
  var client;
  var logger;
  var message = Message();

  setUp(() {
    client = MockClient();
    logger = MockLogger();
    when(client.latency).thenReturn(DateTime.now());
  });

  test("emits a pong event", () {
    // GIVEN
    var command = Pong(client, logger);

    // WHEN
    command.call(message);

    // THEN
    verify(client.emit("pong", any));
  });

  test("should set curreny latency on the client", () {
    var command = Pong(client, logger);

    // WHEN
    command.call(message);

    // THEN
    verify(client.currentLatency).called(1);
  });
}
