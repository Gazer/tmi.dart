import 'package:tmi/tmi.dart' as tmi;

void main() {
  var client = tmi.Client(
    channels: "duendepablo",
    secure: true,
  );
  client.connect();

  client.on("message", (channel, userstate, message, self) {
    print("${channel}| ${userstate['display-name']}: ${message}");
  });
  client.on("join", (channel, username, self) {
    if (!self) {
      print("${channel}> ${username} join");
    }
  });
  client.on("raided", (channel, username, viewers, userstate) {
    print("${channel}> === RAID === ${viewers} from ${username}");
  });
  client.on("resub", (
    channel,
    username,
    streakMonths,
    msg,
    userstate,
    methods,
  ) {
    var streakMonths = userstate['msg-param-streak-months'];
    var cumulativeMonths = userstate['msg-param-cumulative-months'];
    var sharedStreak = userstate['msg-param-should-share-streak'];
    if (sharedStreak) {
      print("${channel}> CAPO $username por sus $streakMonths!: $msg");
    } else {
      print(
          "${channel}> CAPO $username por resuscribirse ya ${cumulativeMonths} meses: $msg");
    }
  });
  client.on("subscription", (channel, username, methods, msg, userstate) {
    print("${channel}>>>> NEW SUB: $username");
  });
  client.on("roomstate", (channel, tags) {
    print("${channel} JOINING $tags");
  });
  client.on("pong", (latency) {
    print("pong delayed by $latency");
  });
  client.on("notice", (channel, msgid, message) {
    print("~~~~ $msgid ----> $message");
  });
}
