import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:tmi/src/commands/user/priv_msg.dart';
import 'package:tmi/src/message.dart';

import '../../mocks.dart';

void main() {
  var client;
  var logger;

  setUp(() {
    client = MockClient();
    logger = MockLogger();
    when(client.username).thenReturn("justinfan33");
  });

  test("emits a chat message from a user", () {
    // GIVEN
    var expectedTags = {
      "username": "ronni",
      "message-type": "chat",
    };
    var expectedMessage = "this is the message";
    var message = Message.parse(
        ":ronni!ronni@ronni.tmi.twitch.tv PRIVMSG #dallas :$expectedMessage");
    var command = PrivMsg(client, logger);

    // WHEN
    command.call(message);

    // THEN
    verify(
      client.emit("message", ["#dallas", expectedTags, expectedMessage, false]),
    );
    verify(
      client.emit("chat", ["#dallas", expectedTags, expectedMessage, false]),
    );
  });

  test("emits a cheer when a user send bits", () {
    // GIVEN
    var expectedTags = {
      "username": "ronni",
      "message-type": "chat",
      "badges": "staff/1,bits/1000",
      "bits": "100",
      "display-name": "ronni"
    };
    var expectedMessage = "cheer100";
    var message = Message.parse(
        "@badges=staff/1,bits/1000;bits=100;display-name=ronni :ronni!ronni@ronni.tmi.twitch.tv PRIVMSG #ronni :$expectedMessage");
    var command = PrivMsg(client, logger);

    // WHEN
    command.call(message);

    // THEN
    verify(
      client.emit("cheer", ["#ronni", expectedTags, expectedMessage]),
    );
  });
}
