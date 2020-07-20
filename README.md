# tmi.dart

Dart library for the Twitch Messaging Interface. (Twitch.tv) 

🚨🚨 THIS IS A WORK IN PROGRESS - PLEASE DO NOT USE IT IN PRODUCTION YET 🚨🚨

---
>Made with 💙 by Ricardo Markiewicz // [@gazeria](https://twitter.com/gazeria).

This project was heavily inspired by the [TMI.js](https://tmijs.com/) project, a Node.js Package for Twitch Chat.

## Getting Started

Install the dependency, create a client and start listening for chat events:

```dart
import 'package:tmidart/tmi.dart' as tmi;

var client = tmi.Client(
    channels: "androidedelvalle",
    secure: true,
);
client.connect();

client.on("message", (channel, userstate, message, self) {
    if (self) return;

    print("${channel}| ${userstate['display-name']}: ${message}");
});
```

Each event type can have different type por parameters. Check the current documentation to see how many events have the event.

In the future we may change this syntax to use a more type-safe event registration but for now this will work.

## Current Events

This is the current supported events. To know which parameters you will receive please check the source code or the [TMI.js Documentation](https://github.com/tmijs/docs/blob/gh-pages/_posts/v1.4.2/2019-03-03-Events.md) as a good reference.

This is the events that this library currently support (more will be added in the future):

* connecting
* logon
* ping
* pong
* connected
* resub
* subanniversary
* subscription
* subgift
* anonsubgift
* submysterygift
* anonsubmysterygift
* primepaidupgrade
* giftpaidupgrade
* anongiftpaidupgrade
* raided
* unhost
* hosting
* messagedeleted
* roomstate
* names
* join
* part
* whisper
* message
* hosted
* cheer
* action
* chat