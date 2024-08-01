import 'package:logger/logger.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:tmi/src/commands/pong.dart';
import 'package:tmi/src/message.dart';
import 'package:mockito/annotations.dart';
import 'package:tmi/tmi.dart';

import 'pong_test.mocks.dart';

@GenerateNiceMocks([MockSpec<Client>(), MockSpec<Logger>()])
void main() {
  var client;
  var logger;
  var message = Message(raw: "", tags: {}, prefix: "", command: "", params: []);

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
