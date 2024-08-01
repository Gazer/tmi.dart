import 'package:logger/src/logger.dart';
import 'package:tmi/src/message.dart';
import 'package:tmi/tmi.dart';
import 'package:tmi/src/utils.dart' as _;

import '../command.dart';

class Notice extends Command {
  Notice(Client client, Logger log) : super(client, log);

  @override
  void call(Message message) {
    var channel = _.channel(message.params[0]);
    var msg = _.get(message.params, 1);
    if (msg == null) {
      return;
    }
    var msgid = message.tags["msg-id"];

    var nullArr = [null];
    var noticeArr = [channel, msgid, msg];
    var msgidArr = [msgid];
    var channelTrueArr = [channel, true];
    var channelFalseArr = [channel, false];
    var noticeAndNull = [noticeArr, nullArr];
    var noticeAndMsgid = [noticeArr, msgidArr];
    var basicLog = "[${channel}] ${msg}";

    switch (msgid) {
      // This room is now in subscribers-only mode.
      case "subs_on":
        client.log.i("[${channel}] This room is now in subscribers-only mode.");
        client.emits(["subscriber", "subscribers", "_promiseSubscribers"],
            [channelTrueArr, channelTrueArr, nullArr]);
        break;

      // This room is no longer in subscribers-only mode.
      case "subs_off":
        client.log
            .i("[${channel}] This room is no longer in subscribers-only mode.");
        client.emits(["subscriber", "subscribers", "_promiseSubscribersoff"],
            [channelFalseArr, channelFalseArr, nullArr]);
        break;

      // This room is now in emote-only mode.
      case "emote_only_on":
        client.log.i("[${channel}] This room is now in emote-only mode.");
        client.emits(
            ["emoteonly", "_promiseEmoteonly"], [channelTrueArr, nullArr]);
        break;

      // This room is no longer in emote-only mode.
      case "emote_only_off":
        client.log.i("[${channel}] This room is no longer in emote-only mode.");
        client.emits(
            ["emoteonly", "_promiseEmoteonlyoff"], [channelFalseArr, nullArr]);
        break;

      // Do not handle slow_on/off here, listen to the ROOMSTATE notice instead as it returns the delay.
      case "slow_on":
      case "slow_off":
        break;

      // Do not handle followers_on/off here, listen to the ROOMSTATE notice instead as it returns the delay.
      case "followers_on_zero":
      case "followers_on":
      case "followers_off":
        break;

      // This room is now in r9k mode.
      case "r9k_on":
        client.log.i("[${channel}] This room is now in r9k mode.");
        client.emits(["r9kmode", "r9kbeta", "_promiseR9kbeta"],
            [channelTrueArr, channelTrueArr, nullArr]);
        break;

      // This room is no longer in r9k mode.
      case "r9k_off":
        client.log.i("[${channel}] This room is no longer in r9k mode.");
        client.emits(["r9kmode", "r9kbeta", "_promiseR9kbetaoff"],
            [channelFalseArr, channelFalseArr, nullArr]);
        break;

      // The moderators of this room are: [..., ...]
      case "room_mods":
        var mods = msg
            .split(": ")[1]
            .toLowerCase()
            .split(", ")
            .where((String n) => n.isNotEmpty);

        client.emits([
          "_promiseMods",
          "mods"
        ], [
          [null, mods],
          [channel, mods]
        ]);
        break;

      // There are no moderators for this room.
      case "no_mods":
        client.emits([
          "_promiseMods",
          "mods"
        ], [
          [null, []],
          [channel, []]
        ]);
        break;

      // The VIPs of this channel are: [..., ...]
      case "vips_success":
        if (msg.endsWith(".")) {
          msg = msg.substring(0, msg.length - 1);
        }
        var vips = msg
            .split(": ")[1]
            .toLowerCase()
            .split(", ")
            .where((String n) => n.isNotEmpty);

        client.emits([
          "_promiseVips",
          "vips"
        ], [
          [null, vips],
          [channel, vips]
        ]);
        break;

      // There are no VIPs for this room.
      case "no_vips":
        client.emits([
          "_promiseVips",
          "vips"
        ], [
          [null, []],
          [channel, []]
        ]);
        break;

      // Ban command failed..
      case "already_banned":
      case "bad_ban_admin":
      case "bad_ban_broadcaster":
      case "bad_ban_global_mod":
      case "bad_ban_self":
      case "bad_ban_staff":
      case "usage_ban":
        client.log.i(basicLog);
        client.emits(["notice", "_promiseBan"], noticeAndMsgid);
        break;

      // Ban command success..
      case "ban_success":
        client.log.i(basicLog);
        client.emits(["notice", "_promiseBan"], noticeAndNull);
        break;

      // Clear command failed..
      case "usage_clear":
        client.log.i(basicLog);
        client.emits(["notice", "_promiseClear"], noticeAndMsgid);
        break;

      // Mods command failed..
      case "usage_mods":
        client.log.i(basicLog);
        client.emits([
          "notice",
          "_promiseMods"
        ], [
          noticeArr,
          [msgid, []]
        ]);
        break;

      // Mod command success..
      case "mod_success":
        client.log.i(basicLog);
        client.emits(["notice", "_promiseMod"], noticeAndNull);
        break;

      // VIPs command failed..
      case "usage_vips":
        client.log.i(basicLog);
        client.emits([
          "notice",
          "_promiseVips"
        ], [
          noticeArr,
          [msgid, []]
        ]);
        break;

      // VIP command failed..
      case "usage_vip":
      case "bad_vip_grantee_banned":
      case "bad_vip_grantee_already_vip":
      case "bad_vip_achievement_incomplete":
        client.log.i(basicLog);
        client.emits([
          "notice",
          "_promiseVip"
        ], [
          noticeArr,
          [msgid, []]
        ]);
        break;

      // VIP command success..
      case "vip_success":
        client.log.i(basicLog);
        client.emits(["notice", "_promiseVip"], noticeAndNull);
        break;

      // Mod command failed..
      case "usage_mod":
      case "bad_mod_banned":
      case "bad_mod_mod":
        client.log.i(basicLog);
        client.emits(["notice", "_promiseMod"], noticeAndMsgid);
        break;

      // Unmod command success..
      case "unmod_success":
        client.log.i(basicLog);
        client.emits(["notice", "_promiseUnmod"], noticeAndNull);
        break;

      // Unvip command success...
      case "unvip_success":
        client.log.i(basicLog);
        client.emits(["notice", "_promiseUnvip"], noticeAndNull);
        break;

      // Unmod command failed..
      case "usage_unmod":
      case "bad_unmod_mod":
        client.log.i(basicLog);
        client.emits(["notice", "_promiseUnmod"], noticeAndMsgid);
        break;

      // Unvip command failed..
      case "usage_unvip":
      case "bad_unvip_grantee_not_vip":
        client.log.i(basicLog);
        client.emits(["notice", "_promiseUnvip"], noticeAndMsgid);
        break;

      // Color command success..
      case "color_changed":
        client.log.i(basicLog);
        client.emits(["notice", "_promiseColor"], noticeAndNull);
        break;

      // Color command failed..
      case "usage_color":
      case "turbo_only_color":
        client.log.i(basicLog);
        client.emits(["notice", "_promiseColor"], noticeAndMsgid);
        break;

      // Commercial command success..
      case "commercial_success":
        client.log.i(basicLog);
        client.emits(["notice", "_promiseCommercial"], noticeAndNull);
        break;

      // Commercial command failed..
      case "usage_commercial":
      case "bad_commercial_error":
        client.log.i(basicLog);
        client.emits(["notice", "_promiseCommercial"], noticeAndMsgid);
        break;

      // Host command success..
      case "hosts_remaining":
        client.log.i(basicLog);
        var remainingHost = int.tryParse(msg[0]) ?? 0;
        client.emits([
          "notice",
          "_promiseHost"
        ], [
          noticeArr,
          [null, remainingHost]
        ]);
        break;

      // Host command failed..
      case "bad_host_hosting":
      case "bad_host_rate_exceeded":
      case "bad_host_error":
      case "usage_host":
        client.log.i(basicLog);
        client.emits([
          "notice",
          "_promiseHost"
        ], [
          noticeArr,
          [msgid, null]
        ]);
        break;

      // r9kbeta command failed..
      case "already_r9k_on":
      case "usage_r9k_on":
        client.log.i(basicLog);
        client.emits(["notice", "_promiseR9kbeta"], noticeAndMsgid);
        break;

      // r9kbetaoff command failed..
      case "already_r9k_off":
      case "usage_r9k_off":
        client.log.i(basicLog);
        client.emits(["notice", "_promiseR9kbetaoff"], noticeAndMsgid);
        break;

      // Timeout command success..
      case "timeout_success":
        client.log.i(basicLog);
        client.emits(["notice", "_promiseTimeout"], noticeAndNull);
        break;

      case "delete_message_success":
        client.log.i("[${channel} ${msg}]");
        client.emits(["notice", "_promiseDeletemessage"], noticeAndNull);
        break;

      // Subscribersoff command failed..
      case "already_subs_off":
      case "usage_subs_off":
        client.log.i(basicLog);
        client.emits(["notice", "_promiseSubscribersoff"], noticeAndMsgid);
        break;

      // Subscribers command failed..
      case "already_subs_on":
      case "usage_subs_on":
        client.log.i(basicLog);
        client.emits(["notice", "_promiseSubscribers"], noticeAndMsgid);
        break;

      // Emoteonlyoff command failed..
      case "already_emote_only_off":
      case "usage_emote_only_off":
        client.log.i(basicLog);
        client.emits(["notice", "_promiseEmoteonlyoff"], noticeAndMsgid);
        break;

      // Emoteonly command failed..
      case "already_emote_only_on":
      case "usage_emote_only_on":
        client.log.i(basicLog);
        client.emits(["notice", "_promiseEmoteonly"], noticeAndMsgid);
        break;

      // Slow command failed..
      case "usage_slow_on":
        client.log.i(basicLog);
        client.emits(["notice", "_promiseSlow"], noticeAndMsgid);
        break;

      // Slowoff command failed..
      case "usage_slow_off":
        client.log.i(basicLog);
        client.emits(["notice", "_promiseSlowoff"], noticeAndMsgid);
        break;

      // Timeout command failed..
      case "usage_timeout":
      case "bad_timeout_admin":
      case "bad_timeout_broadcaster":
      case "bad_timeout_duration":
      case "bad_timeout_global_mod":
      case "bad_timeout_self":
      case "bad_timeout_staff":
        client.log.i(basicLog);
        client.emits(["notice", "_promiseTimeout"], noticeAndMsgid);
        break;

      // Unban command success..
      // Unban can also be used to cancel an active timeout.
      case "untimeout_success":
      case "unban_success":
        client.log.i(basicLog);
        client.emits(["notice", "_promiseUnban"], noticeAndNull);
        break;

      // Unban command failed..
      case "usage_unban":
      case "bad_unban_no_ban":
        client.log.i(basicLog);
        client.emits(["notice", "_promiseUnban"], noticeAndMsgid);
        break;

      // Delete command failed..
      case "usage_delete":
      case "bad_delete_message_error":
      case "bad_delete_message_broadcaster":
      case "bad_delete_message_mod":
        client.log.i(basicLog);
        client.emits(["notice", "_promiseDeletemessage"], noticeAndMsgid);
        break;

      // Unhost command failed..
      case "usage_unhost":
      case "not_hosting":
        client.log.i(basicLog);
        client.emits(["notice", "_promiseUnhost"], noticeAndMsgid);
        break;

      // Whisper command failed..
      case "whisper_invalid_login":
      case "whisper_invalid_self":
      case "whisper_limit_per_min":
      case "whisper_limit_per_sec":
      case "whisper_restricted":
      case "whisper_restricted_recipient":
        client.log.i(basicLog);
        client.emits(["notice", "_promiseWhisper"], noticeAndMsgid);
        break;

      // Permission error..
      case "no_permission":
      case "msg_banned":
      case "msg_room_not_found":
      case "msg_channel_suspended":
      case "tos_ban":
      case "invalid_user":
        client.log.i(basicLog);
        client.emits([
          "notice",
          "_promiseBan",
          "_promiseClear",
          "_promiseUnban",
          "_promiseTimeout",
          "_promiseDeletemessage",
          "_promiseMods",
          "_promiseMod",
          "_promiseUnmod",
          "_promiseVips",
          "_promiseVip",
          "_promiseUnvip",
          "_promiseCommercial",
          "_promiseHost",
          "_promiseUnhost",
          "_promiseJoin",
          "_promisePart",
          "_promiseR9kbeta",
          "_promiseR9kbetaoff",
          "_promiseSlow",
          "_promiseSlowoff",
          "_promiseFollowers",
          "_promiseFollowersoff",
          "_promiseSubscribers",
          "_promiseSubscribersoff",
          "_promiseEmoteonly",
          "_promiseEmoteonlyoff"
        ], [
          noticeArr,
          [msgid, channel]
        ]);
        break;

      // Automod-related..
      case "msg_rejected":
      case "msg_rejected_mandatory":
        client.log.i(basicLog);
        client.emit("automod", [channel, msgid, msg]);
        break;

      // Unrecognized command..
      case "unrecognized_cmd":
        client.log.i(basicLog);
        client.emit("notice", [channel, msgid, msg]);
        break;

      // Send the following msg-ids to the notice event listener..
      case "cmds_available":
      case "host_target_went_offline":
      case "msg_censored_broadcaster":
      case "msg_duplicate":
      case "msg_emoteonly":
      case "msg_verified_email":
      case "msg_ratelimit":
      case "msg_subsonly":
      case "msg_timedout":
      case "msg_bad_characters":
      case "msg_channel_blocked":
      case "msg_facebook":
      case "msg_followersonly":
      case "msg_followersonly_followed":
      case "msg_followersonly_zero":
      case "msg_slowmode":
      case "msg_suspended":
      case "no_help":
      case "usage_disconnect":
      case "usage_help":
      case "usage_me":
      case "unavailable_command":
        client.log.i(basicLog);
        client.emit("notice", [channel, msgid, msg]);
        break;

      // Ignore this because we are already listening to HOSTTARGET..
      case "host_on":
      case "host_off":
        break;

      default:
        if (msg.contains("Login unsuccessful") ||
            msg.contains("Login authentication failed")) {
          client.wasCloseCalled = false;
          client.reconnect = false;
          client.reason = msg;
          client.log.e(client.reason);
          client.close();
        } else if (msg.contains("Error logging in") ||
            msg.contains("Improperly formatted auth")) {
          client.wasCloseCalled = false;
          client.reconnect = false;
          client.reason = msg;
          client.log.e(client.reason);
          client.close();
        } else if (msg.contains("Invalid NICK")) {
          client.wasCloseCalled = false;
          client.reconnect = false;
          client.reason = "Invalid NICK.";
          client.log.e(client.reason);
          client.close();
        } else {
          client.log
              .w("Could not parse NOTICE from tmi.twitch.tv:\n${message}");
          client.emit("notice", [channel, msgid, msg]);
        }
        break;
    }
  }
}
