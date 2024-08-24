import 'dart:async';

import 'package:web_socket_client/web_socket_client.dart';

class FakeConnection extends Connection {
  StreamController<ConnectionState> mock = StreamController<ConnectionState>();

  @override
  StreamSubscription<ConnectionState> listen(
      void Function(ConnectionState event)? onData,
      {Function? onError,
      void Function()? onDone,
      bool? cancelOnError}) {
    return mock.stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  ConnectionState get state => Connected();
}
