import 'dart:async';

import 'package:web_socket_client/web_socket_client.dart';

import 'fake_connection.dart';

class FakeWs implements WebSocket {
  late FakeConnection conn;
  var messageController = StreamController<dynamic>.broadcast();

  Map<String, String> _mockResponses = {};
  bool? isPasswordGood;

  FakeWs() {
    conn = FakeConnection();
    conn.mock.sink.add(Connected());
  }

  @override
  void close([int? code, String? reason]) {
    conn.mock.sink.add(Disconnected());
  }

  @override
  Connection get connection => conn;

  @override
  Stream get messages => messageController.stream;

  @override
  void send(message) {
    var response = _mockResponses[message];

    if (response != null) {
      messageController.sink.add(response);
    }

    if (message is String && message.startsWith("NICK")) {
      if (isPasswordGood == true) {
        var username = message.split(" ")[1];
        [
          ":tmi.twitch.tv 001 $username :Welcome, GLHF!",
          ":tmi.twitch.tv 002 androidedelvalle :Your host is tmi.twitch.tv",
          ":tmi.twitch.tv 003 androidedelvalle :This server is rather new",
          ":tmi.twitch.tv 004 androidedelvalle :-",
          ":tmi.twitch.tv 375 androidedelvalle :-",
          ":tmi.twitch.tv 372 androidedelvalle :You are in a maze of twisty passages, all alike.",
          ":tmi.twitch.tv 376 androidedelvalle :> ",
        ].forEach(messageController.sink.add);
      } else {
        messageController.sink
            .add(":tmi.twitch.tv NOTICE * :Login authentication failed");
      }
    }
    if (message is String && message.startsWith("PASS")) {
      var password = message.split(" ")[1];
      isPasswordGood =
          password == "oauth:goodpassword" || password == "SCHMOOPIIE";
      print("are good?: $isPasswordGood / $password");
    }
  }

  FakeWsRequest when(String request) {
    return FakeWsRequest(request, this);
  }

  clear() {
    _mockResponses.clear();
  }
}

class FakeWsRequest {
  final String request;
  final FakeWs ws;

  FakeWsRequest(this.request, this.ws);

  thenResponse(String response) {
    ws._mockResponses[request] = response;
  }
}
