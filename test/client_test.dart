import 'package:test/test.dart';
import 'package:tmi/src/client.dart';

import 'fakes/fake_ws.dart';

void main() {
  FakeWs ws = FakeWs();
  Client client = Client(
    channels: "Dummy",
    secure: true,
    mock: ws,
  )..connect();

  setUp(() {
    ws.clear();
  });

  test("ban", () async {
    ws
        .when("PRIVMSG #nn :/ban nn spam")
        .thenResponse("@msg-id=ban_success :tmi.twitch.tv NOTICE #nn :nn spam");

    var result = await client.ban("nn", "nn", "spam");

    assert(result[0] == "#nn");
    assert(result[1] == "nn");
    assert(result[2] == "spam");
  });
}
