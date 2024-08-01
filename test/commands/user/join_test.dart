import 'package:logger/logger.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:tmi/src/commands/user/join.dart';
import 'package:tmi/src/message.dart';
import 'package:mockito/annotations.dart';
import 'package:tmi/tmi.dart';

import 'join_test.mocks.dart';

@GenerateNiceMocks([MockSpec<Client>(), MockSpec<Logger>()])
void main() {
  var client;
  var logger;
  var message = Message.parse(":ronni!ronni@ronni.tmi.twitch.tv JOIN #dallas")!;

  setUp(() {
    client = MockClient();
    logger = MockLogger();
    when(client.username).thenReturn("justinfan33");
  });

  test("emits when a user join to the chat", () {
    // GIVEN
    var command = Join(client, logger);

    // WHEN
    command.call(message);

    // THEN
    verify(client.emit("join", ["#dallas", "ronni", false]));
  });

  test("detects if the join message if from myself", () {
    // GIVEN
    var message = Message.parse(
        ":justinfan33!justinfan33@ronni.tmi.twitch.tv JOIN #dallas")!;
    when(client.username).thenReturn("justinfan33");
    var command = Join(client, logger);

    // WHEN
    command.call(message);

    // THEN
    verify(client.lastJoined = "#dallas");
    verify(client.emit("join", ["#dallas", "justinfan33", true]));
  });
}
