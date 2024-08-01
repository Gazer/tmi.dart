import 'dart:async';

import 'package:logger/src/logger.dart';
import 'package:tmi/src/commands/command.dart';
import 'package:tmi/src/message.dart';
import 'package:tmi/tmi.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:tmi/src/utils.dart' as _;

class GlobalUserState extends Command {
  Timer? _emotesUpdater;

  GlobalUserState(Client client, Logger log) : super(client, log);

  @override
  void call(Message message) {
    client.globaluserstate = message.tags;

    // Received emote-sets..
    if (message.tags["emote-sets"] != null) {
      _updateEmoteset(message.tags["emote-sets"]);
    }
  }

  void _updateEmoteset(sets) async {
    client.emotes = sets;

    _emotesUpdater?.cancel();

    _emotesUpdater =
        Timer.periodic(Duration(milliseconds: 60000), (timer) async {
      var token = client.getToken();

      var url = Uri.parse(
        "https://api.twitch.tv/kraken/chat/emoticon_images?emotesets=${sets}",
      );
      var headers = {
        "Authorization": "OAuth ${_.token(token)}",
        "Client-ID": client.clientId,
      };

      var response = await http.get(url, headers: headers);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        var jsonResponse = convert.jsonDecode(response.body);
        client.emotesets = jsonResponse["emoticon_sets"] ?? {};
        client.emit("emotesets", [sets, client.emotesets]);
      }
    });
  }
}
