import 'package:logger/logger.dart';
import 'package:tmi/src/message.dart';
import 'package:tmi/src/utils.dart' as _;
import 'package:tmi/tmi.dart';

export 'no_op.dart';
export 'user_notice.dart';
export 'connected.dart';
export 'host_target.dart';
export 'clear_chat.dart';
export 'clear_msg.dart';
export 'user_state.dart';
export 'room_state.dart';

abstract class Command {
  final Client client;
  final Logger log;

  Command(this.client, this.log);

  void call(Message message);
}
