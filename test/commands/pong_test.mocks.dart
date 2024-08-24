// Mocks generated by Mockito 5.4.4 from annotations
// in tmi/test/commands/pong_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i3;

import 'package:eventify/eventify.dart' as _i4;
import 'package:logger/logger.dart' as _i2;
import 'package:mockito/mockito.dart' as _i1;
import 'package:mockito/src/dummies.dart' as _i6;
import 'package:tmi/src/client.dart' as _i5;
import 'package:tmi/src/commands/command.dart' as _i7;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeLogger_0 extends _i1.SmartFake implements _i2.Logger {
  _FakeLogger_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeDateTime_1 extends _i1.SmartFake implements DateTime {
  _FakeDateTime_1(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeFuture_2<T1> extends _i1.SmartFake implements _i3.Future<T1> {
  _FakeFuture_2(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeListener_3 extends _i1.SmartFake implements _i4.Listener {
  _FakeListener_3(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [Client].
///
/// See the documentation for Mockito's code generation for more information.
class MockClient extends _i1.Mock implements _i5.Client {
  @override
  _i2.Logger get log => (super.noSuchMethod(
        Invocation.getter(#log),
        returnValue: _FakeLogger_0(
          this,
          Invocation.getter(#log),
        ),
        returnValueForMissingStub: _FakeLogger_0(
          this,
          Invocation.getter(#log),
        ),
      ) as _i2.Logger);

  @override
  set log(_i2.Logger? _log) => super.noSuchMethod(
        Invocation.setter(
          #log,
          _log,
        ),
        returnValueForMissingStub: null,
      );

  @override
  String get channels => (super.noSuchMethod(
        Invocation.getter(#channels),
        returnValue: _i6.dummyValue<String>(
          this,
          Invocation.getter(#channels),
        ),
        returnValueForMissingStub: _i6.dummyValue<String>(
          this,
          Invocation.getter(#channels),
        ),
      ) as String);

  @override
  bool get secure => (super.noSuchMethod(
        Invocation.getter(#secure),
        returnValue: false,
        returnValueForMissingStub: false,
      ) as bool);

  @override
  String get clientId => (super.noSuchMethod(
        Invocation.getter(#clientId),
        returnValue: _i6.dummyValue<String>(
          this,
          Invocation.getter(#clientId),
        ),
        returnValueForMissingStub: _i6.dummyValue<String>(
          this,
          Invocation.getter(#clientId),
        ),
      ) as String);

  @override
  set clientId(String? _clientId) => super.noSuchMethod(
        Invocation.setter(
          #clientId,
          _clientId,
        ),
        returnValueForMissingStub: null,
      );

  @override
  set token(String? _token) => super.noSuchMethod(
        Invocation.setter(
          #token,
          _token,
        ),
        returnValueForMissingStub: null,
      );

  @override
  int get currentLatency => (super.noSuchMethod(
        Invocation.getter(#currentLatency),
        returnValue: 0,
        returnValueForMissingStub: 0,
      ) as int);

  @override
  set currentLatency(int? _currentLatency) => super.noSuchMethod(
        Invocation.setter(
          #currentLatency,
          _currentLatency,
        ),
        returnValueForMissingStub: null,
      );

  @override
  DateTime get latency => (super.noSuchMethod(
        Invocation.getter(#latency),
        returnValue: _FakeDateTime_1(
          this,
          Invocation.getter(#latency),
        ),
        returnValueForMissingStub: _FakeDateTime_1(
          this,
          Invocation.getter(#latency),
        ),
      ) as DateTime);

  @override
  set latency(DateTime? _latency) => super.noSuchMethod(
        Invocation.setter(
          #latency,
          _latency,
        ),
        returnValueForMissingStub: null,
      );

  @override
  String get username => (super.noSuchMethod(
        Invocation.getter(#username),
        returnValue: _i6.dummyValue<String>(
          this,
          Invocation.getter(#username),
        ),
        returnValueForMissingStub: _i6.dummyValue<String>(
          this,
          Invocation.getter(#username),
        ),
      ) as String);

  @override
  set username(String? _username) => super.noSuchMethod(
        Invocation.setter(
          #username,
          _username,
        ),
        returnValueForMissingStub: null,
      );

  @override
  set globaluserstate(Map<String, dynamic>? _globaluserstate) =>
      super.noSuchMethod(
        Invocation.setter(
          #globaluserstate,
          _globaluserstate,
        ),
        returnValueForMissingStub: null,
      );

  @override
  Map<String, dynamic> get userstate => (super.noSuchMethod(
        Invocation.getter(#userstate),
        returnValue: <String, dynamic>{},
        returnValueForMissingStub: <String, dynamic>{},
      ) as Map<String, dynamic>);

  @override
  set userstate(Map<String, dynamic>? _userstate) => super.noSuchMethod(
        Invocation.setter(
          #userstate,
          _userstate,
        ),
        returnValueForMissingStub: null,
      );

  @override
  String get lastJoined => (super.noSuchMethod(
        Invocation.getter(#lastJoined),
        returnValue: _i6.dummyValue<String>(
          this,
          Invocation.getter(#lastJoined),
        ),
        returnValueForMissingStub: _i6.dummyValue<String>(
          this,
          Invocation.getter(#lastJoined),
        ),
      ) as String);

  @override
  set lastJoined(String? _lastJoined) => super.noSuchMethod(
        Invocation.setter(
          #lastJoined,
          _lastJoined,
        ),
        returnValueForMissingStub: null,
      );

  @override
  Map<String, List<String>> get moderators => (super.noSuchMethod(
        Invocation.getter(#moderators),
        returnValue: <String, List<String>>{},
        returnValueForMissingStub: <String, List<String>>{},
      ) as Map<String, List<String>>);

  @override
  set moderators(Map<String, List<String>>? _moderators) => super.noSuchMethod(
        Invocation.setter(
          #moderators,
          _moderators,
        ),
        returnValueForMissingStub: null,
      );

  @override
  String get emotes => (super.noSuchMethod(
        Invocation.getter(#emotes),
        returnValue: _i6.dummyValue<String>(
          this,
          Invocation.getter(#emotes),
        ),
        returnValueForMissingStub: _i6.dummyValue<String>(
          this,
          Invocation.getter(#emotes),
        ),
      ) as String);

  @override
  set emotes(String? _emotes) => super.noSuchMethod(
        Invocation.setter(
          #emotes,
          _emotes,
        ),
        returnValueForMissingStub: null,
      );

  @override
  Map<String, String> get emotesets => (super.noSuchMethod(
        Invocation.getter(#emotesets),
        returnValue: <String, String>{},
        returnValueForMissingStub: <String, String>{},
      ) as Map<String, String>);

  @override
  set emotesets(Map<String, String>? _emotesets) => super.noSuchMethod(
        Invocation.setter(
          #emotesets,
          _emotesets,
        ),
        returnValueForMissingStub: null,
      );

  @override
  bool get wasCloseCalled => (super.noSuchMethod(
        Invocation.getter(#wasCloseCalled),
        returnValue: false,
        returnValueForMissingStub: false,
      ) as bool);

  @override
  set wasCloseCalled(bool? _wasCloseCalled) => super.noSuchMethod(
        Invocation.setter(
          #wasCloseCalled,
          _wasCloseCalled,
        ),
        returnValueForMissingStub: null,
      );

  @override
  bool get reconnect => (super.noSuchMethod(
        Invocation.getter(#reconnect),
        returnValue: false,
        returnValueForMissingStub: false,
      ) as bool);

  @override
  set reconnect(bool? _reconnect) => super.noSuchMethod(
        Invocation.setter(
          #reconnect,
          _reconnect,
        ),
        returnValueForMissingStub: null,
      );

  @override
  set reason(String? _reason) => super.noSuchMethod(
        Invocation.setter(
          #reason,
          _reason,
        ),
        returnValueForMissingStub: null,
      );

  @override
  Map<String, _i7.Command> get twitchCommands => (super.noSuchMethod(
        Invocation.getter(#twitchCommands),
        returnValue: <String, _i7.Command>{},
        returnValueForMissingStub: <String, _i7.Command>{},
      ) as Map<String, _i7.Command>);

  @override
  set twitchCommands(Map<String, _i7.Command>? _twitchCommands) =>
      super.noSuchMethod(
        Invocation.setter(
          #twitchCommands,
          _twitchCommands,
        ),
        returnValueForMissingStub: null,
      );

  @override
  Map<String, _i7.Command> get noScopeCommands => (super.noSuchMethod(
        Invocation.getter(#noScopeCommands),
        returnValue: <String, _i7.Command>{},
        returnValueForMissingStub: <String, _i7.Command>{},
      ) as Map<String, _i7.Command>);

  @override
  set noScopeCommands(Map<String, _i7.Command>? _noScopeCommands) =>
      super.noSuchMethod(
        Invocation.setter(
          #noScopeCommands,
          _noScopeCommands,
        ),
        returnValueForMissingStub: null,
      );

  @override
  Map<String, _i7.Command> get userCommands => (super.noSuchMethod(
        Invocation.getter(#userCommands),
        returnValue: <String, _i7.Command>{},
        returnValueForMissingStub: <String, _i7.Command>{},
      ) as Map<String, _i7.Command>);

  @override
  set userCommands(Map<String, _i7.Command>? _userCommands) =>
      super.noSuchMethod(
        Invocation.setter(
          #userCommands,
          _userCommands,
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i3.Future<String> action(
    String? channel,
    String? message,
    Map<String, String>? tags,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #action,
          [
            channel,
            message,
            tags,
          ],
        ),
        returnValue: _i3.Future<String>.value(_i6.dummyValue<String>(
          this,
          Invocation.method(
            #action,
            [
              channel,
              message,
              tags,
            ],
          ),
        )),
        returnValueForMissingStub:
            _i3.Future<String>.value(_i6.dummyValue<String>(
          this,
          Invocation.method(
            #action,
            [
              channel,
              message,
              tags,
            ],
          ),
        )),
      ) as _i3.Future<String>);

  @override
  _i3.Future<List<String>> announce(
    dynamic channel,
    dynamic message,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #announce,
          [
            channel,
            message,
          ],
        ),
        returnValue: _i3.Future<List<String>>.value(<String>[]),
        returnValueForMissingStub: _i3.Future<List<String>>.value(<String>[]),
      ) as _i3.Future<List<String>>);

  @override
  _i3.Future<List<String>> ban(
    String? channel,
    String? username,
    String? reason,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #ban,
          [
            channel,
            username,
            reason,
          ],
        ),
        returnValue: _i3.Future<List<String>>.value(<String>[]),
        returnValueForMissingStub: _i3.Future<List<String>>.value(<String>[]),
      ) as _i3.Future<List<String>>);

  @override
  void connect() => super.noSuchMethod(
        Invocation.method(
          #connect,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void close() => super.noSuchMethod(
        Invocation.method(
          #close,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void startMonitor() => super.noSuchMethod(
        Invocation.method(
          #startMonitor,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i3.Future<T> sendCommand<T>(
    String? channel,
    dynamic command,
    _i3.FutureOr<T> Function()? fn,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #sendCommand,
          [
            channel,
            command,
            fn,
          ],
        ),
        returnValue: _i6.ifNotNull(
              _i6.dummyValueOrNull<T>(
                this,
                Invocation.method(
                  #sendCommand,
                  [
                    channel,
                    command,
                    fn,
                  ],
                ),
              ),
              (T v) => _i3.Future<T>.value(v),
            ) ??
            _FakeFuture_2<T>(
              this,
              Invocation.method(
                #sendCommand,
                [
                  channel,
                  command,
                  fn,
                ],
              ),
            ),
        returnValueForMissingStub: _i6.ifNotNull(
              _i6.dummyValueOrNull<T>(
                this,
                Invocation.method(
                  #sendCommand,
                  [
                    channel,
                    command,
                    fn,
                  ],
                ),
              ),
              (T v) => _i3.Future<T>.value(v),
            ) ??
            _FakeFuture_2<T>(
              this,
              Invocation.method(
                #sendCommand,
                [
                  channel,
                  command,
                  fn,
                ],
              ),
            ),
      ) as _i3.Future<T>);

  @override
  _i3.Future<T> sendMessage<T>(
    String? channel,
    String? message,
    Map<String, String>? tags,
    T Function()? fn,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #sendMessage,
          [
            channel,
            message,
            tags,
            fn,
          ],
        ),
        returnValue: _i6.ifNotNull(
              _i6.dummyValueOrNull<T>(
                this,
                Invocation.method(
                  #sendMessage,
                  [
                    channel,
                    message,
                    tags,
                    fn,
                  ],
                ),
              ),
              (T v) => _i3.Future<T>.value(v),
            ) ??
            _FakeFuture_2<T>(
              this,
              Invocation.method(
                #sendMessage,
                [
                  channel,
                  message,
                  tags,
                  fn,
                ],
              ),
            ),
        returnValueForMissingStub: _i6.ifNotNull(
              _i6.dummyValueOrNull<T>(
                this,
                Invocation.method(
                  #sendMessage,
                  [
                    channel,
                    message,
                    tags,
                    fn,
                  ],
                ),
              ),
              (T v) => _i3.Future<T>.value(v),
            ) ??
            _FakeFuture_2<T>(
              this,
              Invocation.method(
                #sendMessage,
                [
                  channel,
                  message,
                  tags,
                  fn,
                ],
              ),
            ),
      ) as _i3.Future<T>);

  @override
  void send(String? command) => super.noSuchMethod(
        Invocation.method(
          #send,
          [command],
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i4.Listener once(
    String? event,
    Function? f,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #once,
          [
            event,
            f,
          ],
        ),
        returnValue: _FakeListener_3(
          this,
          Invocation.method(
            #once,
            [
              event,
              f,
            ],
          ),
        ),
        returnValueForMissingStub: _FakeListener_3(
          this,
          Invocation.method(
            #once,
            [
              event,
              f,
            ],
          ),
        ),
      ) as _i4.Listener);

  @override
  _i4.Listener on(
    String? event,
    Function? f,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #on,
          [
            event,
            f,
          ],
        ),
        returnValue: _FakeListener_3(
          this,
          Invocation.method(
            #on,
            [
              event,
              f,
            ],
          ),
        ),
        returnValueForMissingStub: _FakeListener_3(
          this,
          Invocation.method(
            #on,
            [
              event,
              f,
            ],
          ),
        ),
      ) as _i4.Listener);

  @override
  int getListenersCount(String? event) => (super.noSuchMethod(
        Invocation.method(
          #getListenersCount,
          [event],
        ),
        returnValue: 0,
        returnValueForMissingStub: 0,
      ) as int);

  @override
  void emits(
    List<String>? types,
    List<dynamic>? values,
  ) =>
      super.noSuchMethod(
        Invocation.method(
          #emits,
          [
            types,
            values,
          ],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void emit(
    String? type, [
    List<dynamic>? params,
  ]) =>
      super.noSuchMethod(
        Invocation.method(
          #emit,
          [
            type,
            params,
          ],
        ),
        returnValueForMissingStub: null,
      );
}

/// A class which mocks [Logger].
///
/// See the documentation for Mockito's code generation for more information.
class MockLogger extends _i1.Mock implements _i2.Logger {
  @override
  _i3.Future<void> get init => (super.noSuchMethod(
        Invocation.getter(#init),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);

  @override
  void v(
    dynamic message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) =>
      super.noSuchMethod(
        Invocation.method(
          #v,
          [message],
          {
            #time: time,
            #error: error,
            #stackTrace: stackTrace,
          },
        ),
        returnValueForMissingStub: null,
      );

  @override
  void t(
    dynamic message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) =>
      super.noSuchMethod(
        Invocation.method(
          #t,
          [message],
          {
            #time: time,
            #error: error,
            #stackTrace: stackTrace,
          },
        ),
        returnValueForMissingStub: null,
      );

  @override
  void d(
    dynamic message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) =>
      super.noSuchMethod(
        Invocation.method(
          #d,
          [message],
          {
            #time: time,
            #error: error,
            #stackTrace: stackTrace,
          },
        ),
        returnValueForMissingStub: null,
      );

  @override
  void i(
    dynamic message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) =>
      super.noSuchMethod(
        Invocation.method(
          #i,
          [message],
          {
            #time: time,
            #error: error,
            #stackTrace: stackTrace,
          },
        ),
        returnValueForMissingStub: null,
      );

  @override
  void w(
    dynamic message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) =>
      super.noSuchMethod(
        Invocation.method(
          #w,
          [message],
          {
            #time: time,
            #error: error,
            #stackTrace: stackTrace,
          },
        ),
        returnValueForMissingStub: null,
      );

  @override
  void e(
    dynamic message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) =>
      super.noSuchMethod(
        Invocation.method(
          #e,
          [message],
          {
            #time: time,
            #error: error,
            #stackTrace: stackTrace,
          },
        ),
        returnValueForMissingStub: null,
      );

  @override
  void wtf(
    dynamic message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) =>
      super.noSuchMethod(
        Invocation.method(
          #wtf,
          [message],
          {
            #time: time,
            #error: error,
            #stackTrace: stackTrace,
          },
        ),
        returnValueForMissingStub: null,
      );

  @override
  void f(
    dynamic message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) =>
      super.noSuchMethod(
        Invocation.method(
          #f,
          [message],
          {
            #time: time,
            #error: error,
            #stackTrace: stackTrace,
          },
        ),
        returnValueForMissingStub: null,
      );

  @override
  void log(
    _i2.Level? level,
    dynamic message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) =>
      super.noSuchMethod(
        Invocation.method(
          #log,
          [
            level,
            message,
          ],
          {
            #time: time,
            #error: error,
            #stackTrace: stackTrace,
          },
        ),
        returnValueForMissingStub: null,
      );

  @override
  bool isClosed() => (super.noSuchMethod(
        Invocation.method(
          #isClosed,
          [],
        ),
        returnValue: false,
        returnValueForMissingStub: false,
      ) as bool);

  @override
  _i3.Future<void> close() => (super.noSuchMethod(
        Invocation.method(
          #close,
          [],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);
}
