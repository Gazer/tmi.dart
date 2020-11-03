import 'package:logger/src/logger.dart';
import 'package:eventify/eventify.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:tmi/src/commands/command.dart';
import 'package:tmi/src/commands/ping.dart';
import 'package:tmi/src/message.dart';
import 'package:tmi/tmi.dart';

class FakeClient implements Client {
  bool _wasEmitCalled = false;

  @override
  int currentLatency;

  @override
  String emotes;

  @override
  Map<String, String> emotesets = {};

  @override
  Map<String, dynamic> globaluserstate;

  @override
  String lastJoined;

  @override
  DateTime latency;

  @override
  Logger log;

  @override
  Map<String, List<String>> moderators;

  @override
  Map<String, Command> noScopeCommands;

  @override
  String reason;

  @override
  bool reconnect;

  @override
  Map<String, Command> twitchCommands;

  @override
  Map<String, Command> userCommands;

  @override
  String username;

  @override
  Map<String, dynamic> userstate;

  @override
  bool wasCloseCalled;

  @override
  String get channels => "";

  @override
  void close() {}

  @override
  void connect() {}

  @override
  void emit(String type, [List params]) {
    _wasEmitCalled = true;
  }

  @override
  void emits(List<String> types, List values) {
    // TODO: implement emits
  }

  @override
  // TODO: implement emitter
  EventEmitter get emitter => throw UnimplementedError();

  @override
  Listener on(String event, Function f) {
    // TODO: implement on
    throw UnimplementedError();
  }

  @override
  // TODO: implement secure
  bool get secure => throw UnimplementedError();

  @override
  void send(String command) {
    // TODO: implement send
  }

  @override
  Future<bool> sendCommand(delay, String channel, command, Function fn) {
    // TODO: implement sendCommand
    throw UnimplementedError();
  }

  @override
  void startMonitor() {
    // TODO: implement startMonitor
  }

  bool wasEmitCalled() {
    return _wasEmitCalled;
  }

  @override
  String clientId;

  @override
  String token;

  @override
  String getToken() {
    // TODO: implement getToken
    throw UnimplementedError();
  }
}

class FakeLogger implements Logger {
  @override
  void close() {
    // TODO: implement close
  }

  @override
  void d(message, [error, StackTrace stackTrace]) {
    // TODO: implement d
  }

  @override
  void e(message, [error, StackTrace stackTrace]) {
    // TODO: implement e
  }

  @override
  void i(message, [error, StackTrace stackTrace]) {
    // TODO: implement i
  }

  @override
  void log(Level level, message, [error, StackTrace stackTrace]) {
    // TODO: implement log
  }

  @override
  void v(message, [error, StackTrace stackTrace]) {
    // TODO: implement v
  }

  @override
  void w(message, [error, StackTrace stackTrace]) {
    // TODO: implement w
  }

  @override
  void wtf(message, [error, StackTrace stackTrace]) {
    // TODO: implement wtf
  }
}

class MockClient extends Mock implements Client {}

void main() {
  test("ensure emit ping event", () {
    // GIVEN
    var fakeClient = FakeClient();
    var logger = FakeLogger();
    var message = Message();
    var command = Ping(fakeClient, logger);

    // WHEN
    command.call(message);

    // THEN
    expect(true, fakeClient.wasEmitCalled());
  });

  test("should send PONG response", () {
    var mockClient = MockClient();
    var logger = FakeLogger();
    var message = Message();
    var command = Ping(mockClient, logger);

    // WHEN
    command.call(message);

    // THEN
    verify(mockClient.send("PONG"));
  });
}
