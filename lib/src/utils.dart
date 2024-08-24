import 'dart:math';

String channel(String? str) {
  var channel = (str ?? "").toLowerCase();
  return channel[0] == "#" ? channel : "#" + channel;
}

String username(String? str) {
  var channel = (str ?? "").toLowerCase();
  return channel[0] == "#" ? channel.substring(1) : channel;
}

String? get(List<String> list, int index) {
  if (index >= list.length) return null;

  return list[index];
}

int extractNumber(String str) {
  return str
          .split(" ")
          .map((n) => int.tryParse(n))
          .where((element) => element != null)
          .first ??
      0;
}

// Escaping values:
// http://ircv3.net/specs/core/message-tags-3.2.html#escaping-values
String? unescapeIRC(String? msg) {
  var unescapeIRCRegex = RegExp(r"\\([sn:r\\])", caseSensitive: false);
  var ircEscapedChars = {'s': ' ', 'n': '', ':': ';', 'r': ''};

  if (msg == null || !msg.contains('\\')) return msg;

  return msg.replaceAllMapped(
    unescapeIRCRegex,
    (match) => ircEscapedChars[match[1]] ?? match[1] ?? "",
  );
}

String escapeIRC(String msg) {
  var escapeIRCRegex = RegExp(r"([ \n;\r\\])", caseSensitive: false);
  const ircUnescapedChars = {' ': 's', '\n': 'n', ';': ':', '\r': 'r'};

  return msg.replaceAllMapped(
    escapeIRCRegex,
    (match) => ircUnescapedChars[match[1]] ?? match[1] ?? "",
  );
}

Map<String, dynamic> emotes(Map<String, dynamic> tags) {
  return _parseComplexTag(tags, "emotes", "/", ":", ",");
}

// Parse Twitch badges..
Map<String, dynamic> badges(Map<String, dynamic> tags) {
  return _parseComplexTag(tags, "badges");
}

// Parse Twitch badge-info..
Map<String, dynamic> badgeInfo(Map<String, dynamic> tags) {
  return _parseComplexTag(tags, "badge-info");
}

Map<String, dynamic> _parseComplexTag(
  Map<String, dynamic> tags,
  String tagKey, [
  String splA = ",",
  String splB = "/",
  String? splC = null,
]) {
  var raw = tags[tagKey];

  if (raw == null) {
    return tags;
  }

  var tagIsString = raw.runtimeType == String;
  tags[tagKey + "-raw"] = tagIsString ? raw : null;

  if (raw == true) {
    tags[tagKey] = null;
    return tags;
  }

  tags[tagKey] = {};

  if (tagIsString) {
    var spl = (raw as String).split(splA);

    for (var i = 0; i < spl.length; i++) {
      var parts = spl[i].split(splB);
      if (parts.length > 1) {
        dynamic val = parts[1];
        if (splC != null && val.isNotEmpty) {
          val = val.split(splC);
        }
        tags[tagKey][parts[0]] = val ?? null;
      }
    }
  }
  return tags;
}

Random random = Random();
String justinfan() {
  return "justinfan${random.nextInt(80000) + 1000}";
}

RegExp justinFanRegex = new RegExp(r"^justinfan\d+$");
bool isJustinfan(String username) {
  return justinFanRegex.hasMatch(username);
}

RegExp tokenRegEx = new RegExp(r'oauth:');
String token(String? str) =>
    str != null ? str.toLowerCase().replaceFirst(tokenRegEx, "") : "";

var actionMessageRegex = RegExp(r'\u0001ACTION (.*?)\u0001');
String? actionMessage(String message) {
  return actionMessageRegex.firstMatch(message)?.group(1);
}

String? formTags(Map<String, String> tags) {
  var result = tags.entries
      .map((entry) => "${escapeIRC(entry.key)}=${escapeIRC(entry.value)}");
  return result.length == 0 ? null : result.join(";");
}

// Return a valid token
String password(String? str) {
  final t = token(str);
  return t.isNotEmpty ? "oauth:${t}" : '';
}
