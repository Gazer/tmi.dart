import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:tmi/src/commands/user/names.dart';
import 'package:tmi/src/message.dart';

import '../../mocks.dart';

void main() {
  var client;
  var logger;
  var message = Message.parse(
      ":justinfan64481.tmi.twitch.tv 353 justinfan64481 = #dallas :justinfan64481");

  setUp(() {
    client = MockClient();
    logger = MockLogger();
    when(client.username).thenReturn("justinfan33");
  });

  test("emits names of users in the chat", () {
    // GIVEN
    var command = Names(client, logger);

    // WHEN
    command.call(message);

    // THEN
    verify(client.emit("names", [
      "#dallas",
      ["justinfan64481"]
    ]));
  });
}
