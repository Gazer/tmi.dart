import 'package:logger/logger.dart';
import 'package:tmi/src/message.dart';
import 'package:tmi/src/utils.dart' as _;
import 'package:tmi/tmi.dart';

export 'no_op.dart';
export 'tmi.twitch.tv/user_notice.dart';
export 'tmi.twitch.tv/connected.dart';
export 'tmi.twitch.tv/host_target.dart';
export 'tmi.twitch.tv/clear_chat.dart';
export 'tmi.twitch.tv/clear_msg.dart';
export 'tmi.twitch.tv/user_state.dart';
export 'tmi.twitch.tv/room_state.dart';
export 'tmi.twitch.tv/username.dart';
export 'tmi.twitch.tv/notice.dart';
export 'user/join.dart';
export 'user/part.dart';
export 'user/whisper.dart';
export 'user/priv_msg.dart';
export 'user/names.dart';

abstract class Command {
  final Client client;
  final Logger log;

  Command(this.client, this.log);

  void call(Message message);
}
