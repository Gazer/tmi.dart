import 'dart:async';

import 'package:test/test.dart';
import 'package:tmi/src/client.dart';
import 'package:tmi/src/credentials.dart';

import 'fakes/fake_ws.dart';

void main() {
  late FakeWs ws;
  late Client client;

  setUp(() {
    ws = FakeWs();
  });

  test("ban", () async {
    ws
        .when("PRIVMSG #nn :/ban nn spam")
        .thenResponse("@msg-id=ban_success :tmi.twitch.tv NOTICE #nn :nn spam");

    client = Client(
      channels: "Dummy",
      secure: true,
      mock: ws,
    )..connect();
    var result = await client.ban("nn", "nn", "spam");

    assert(result[0] == "#nn");
    assert(result[1] == "nn");
    assert(result[2] == "spam");
  });

  test("anon announce should throw error", () async {
    client = Client(
      channels: "Dummy",
      secure: true,
      mock: ws,
    )..connect();
    Completer<String> completer = Completer();
    client.on("connected", () async {
      try {
        await client.announce("nn", "5 minutes to next event");
        completer.completeError("exception not thrown");
      } catch (e) {
        completer.complete("$e");
      }
    });
    var result = await completer.future;
    assert(result == "Cannot send anonymous messages.");
  });

  test("announce should throw error", () async {
    client = Client(
      channels: "Dummy",
      secure: true,
      credentials: Credentials(
        username: "TestUser",
        password: "goodpassword",
      ),
      mock: ws,
    )..connect();
    Completer<String> completer = Completer();
    client.on("connected", () async {
      try {
        var result = await client.announce("nn", "5 minutes to next event");
        completer.complete(result[1]);
      } catch (e) {
        completer.completeError("$e");
      }
    });
    var result = await completer.future;
    assert(result == "5 minutes to next event");
  });

  test("login with wrong password disconnect the server", () async {
    client = Client(
      channels: "Dummy",
      secure: true,
      credentials: Credentials(
        username: "User",
        password: "BadPassword",
      ),
      mock: ws,
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
