import 'package:logger/logger.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:tmi/src/commands/no_op.dart';
import 'package:tmi/src/message.dart';
import 'package:mockito/annotations.dart';
import 'package:tmi/tmi.dart';

import 'no_op_test.mocks.dart';

@GenerateNiceMocks([MockSpec<Client>(), MockSpec<Logger>()])
void main() {
  var client;
  var logger;
  var message = Message(raw: "", tags: {}, prefix: "", command: "", params: []);

  setUp(() {
    client = MockClient();
    logger = MockLogger();
  });

  test("do nothing on client", () {
    // GIVEN
    var command = NoOp(client, logger);

    // WHEN
    command.call(message);

    // THEN
    verifyNever(client.emit(any));
    verifyNever(client.send(any));
  });

  test("should not log anything", () {
    var command = NoOp(client, logger);

    // WHEN
    command.call(message);

    // THEN
    verifyNever(logger.i(any));
    verifyNever(logger.d(any));
    verifyNever(logger.v(any));
    verifyNever(logger.w(any));
    verifyNever(logger.e(any));
    verifyNever(logger.wtf(any));
    verifyNever(logger.log(any));
  });
}
