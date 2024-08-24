import 'dart:async';

import 'package:test/test.dart';
import 'package:tmi/src/client.dart';
import 'package:tmi/src/credentials.dart';

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

  test("anon announce should throw error", () async {
    try {
      await client.announce("nn", "5 minutes to next event");
      fail("exception not thrown");
    } catch (e) {
      assert(e == "Cannot send anonymous messages.");
    }
  });

  test("login with wrong password disconnect the server", () async {
    FakeWs ws1 = FakeWs();
    client = Client(
      channels: "Dummy",
      secure: true,
      credentials: Credentials(
        username: "User",
        password: "BadPassword",
      ),
      mock: ws1,
    );

    Completer<String> reasonCompleter = Completer();
    client.on("disconnected", (reason) {
      reasonCompleter.complete(reason);
    });
    client.connect();

    var result = await reasonCompleter.future;
    assert(result == "Login authentication failed");
  });
}
