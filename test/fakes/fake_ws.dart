import 'dart:async';

import 'package:web_socket_client/web_socket_client.dart';

import 'fake_connection.dart';

class FakeWs implements WebSocket {
  FakeConnection conn = FakeConnection();
  var messageController = StreamController<dynamic>.broadcast();

  Map<String, String> _mockResponses = {};

  FakeWs();

  @override
  void close([int? code, String? reason]) {
    // TODO: implement close
  }

  @override
  // TODO: implement connection
  Connection get connection => conn;

  @override
  // TODO: implement messages
  Stream get messages => messageController.stream;

  @override
  void send(message) {
    var response = _mockResponses[message];

    if (response != null) {
      messageController.sink.add(response);
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
