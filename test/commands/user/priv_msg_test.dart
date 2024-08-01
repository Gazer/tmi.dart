import 'package:logger/logger.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:tmi/src/commands/user/priv_msg.dart';
import 'package:tmi/src/message.dart';
import 'package:mockito/annotations.dart';
import 'package:tmi/tmi.dart';

import 'priv_msg_test.mocks.dart';

@GenerateNiceMocks([MockSpec<Client>(), MockSpec<Logger>()])
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
        ":ronni!ronni@ronni.tmi.twitch.tv PRIVMSG #dallas :$expectedMessage")!;
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
        "@badges=staff/1,bits/1000;bits=100;display-name=ronni :ronni!ronni@ronni.tmi.twitch.tv PRIVMSG #ronni :$expectedMessage")!;
    var command = PrivMsg(client, logger);

    // WHEN
    command.call(message);

    // THEN
    verify(
      client.emit("cheer", ["#ronni", expectedTags, expectedMessage]),
    );
  });

  test("emits an action for /me actions", () {
    // GIVEN
    var expectedTags = {
      "username": "ronni",
      "message-type": "action",
      "badges": "staff/1",
      "display-name": "ronni"
    };
    var expectedMessage = "jumps";
    var message = Message.parse(
        "@badges=staff/1;display-name=ronni :ronni!ronni@ronni.tmi.twitch.tv PRIVMSG #ronni :\u0001ACTION ${expectedMessage}\u0001")!;
    var command = PrivMsg(client, logger);

    // WHEN
    command.call(message);

    // THEN
    verify(
      client.emit("message", ["#ronni", expectedTags, expectedMessage, false]),
    );
    verify(
      client.emit("action", ["#ronni", expectedTags, expectedMessage, false]),
    );
  });

  test("emits hosted with user count", () {
    // GIVEN
    var message = Message.parse(
        ":jtv!jtv@jtv.tmi.twitch.tv PRIVMSG #ronni :otherUser hosting you for 4")!;
    var command = PrivMsg(client, logger);

    // WHEN
    command.call(message);

    // THEN
    verify(client.emit("hosted", ["#ronni", "otheruser", 4, false]));
  });

  test("emits hosted without user count", () {
    // GIVEN
    var message = Message.parse(
        ":jtv!jtv@jtv.tmi.twitch.tv PRIVMSG #ronni :otherUser hosting you")!;
    var command = PrivMsg(client, logger);

    // WHEN
    command.call(message);

    // THEN
    verify(client.emit("hosted", ["#ronni", "otheruser", 0, false]));
  });
}
