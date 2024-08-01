import 'package:logger/logger.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:tmi/src/commands/user/part.dart';
import 'package:tmi/src/message.dart';
import 'package:mockito/annotations.dart';
import 'package:tmi/tmi.dart';

import 'part_test.mocks.dart';

@GenerateNiceMocks([MockSpec<Client>(), MockSpec<Logger>()])
void main() {
  var client;
  var logger;
  var message = Message.parse(":ronni!ronni@ronni.tmi.twitch.tv PART #dallas")!;

  setUp(() {
    client = MockClient();
    logger = MockLogger();
    when(client.username).thenReturn("justinfan33");
  });

  test("emits when a user leave the chat", () {
    // GIVEN
    var command = Part(client, logger);

    // WHEN
    command.call(message);

    // THEN
    verify(client.emit("part", ["#dallas", "ronni", false]));
  });

  test("detects if I leave the chat", () {
    // GIVEN
    var message = Message.parse(
        ":justinfan33!justinfan33@ronni.tmi.twitch.tv PART #dallas")!;
    when(client.username).thenReturn("justinfan33");
    when(client.userstate).thenReturn({"dallas": []});
    when(client.channels).thenReturn("dallas");
    var command = Part(client, logger);

    // WHEN
    command.call(message);

    // THEN
    verify(client.emit("part", ["#dallas", "justinfan33", true]));
  });
}
