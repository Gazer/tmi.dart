import 'dart:async';

import 'client_base.dart';
import 'utils.dart' as _;

class Client extends ClientBase {
  Client({
    required super.channels,
    required super.secure,
    super.credentials,
    super.mock,
  });

  Future<String> action(
    String channel,
    String message,
    Map<String, String> tags,
  ) async {
    message = "\u0001ACTION ${message}\u0001";
    return sendMessage<String>(channel, message, tags, () {
      // The message is assumed to be sent and recieved by Twitch. The "client-nonce" tag can be used to
      // detect a response on a USERNOTICE command, but it's not yet implemented here.
      return _.channel(channel);
    });
  }

  // Announce a message on a channel
  Future<List<String>> announce(channel, message) async {
    return sendMessage<List<String>>(channel, "/announce ${message}", {}, () {
      return [_.channel(channel), message];
    });
  }

  /// Ban username on channel
  Future<List<String>> ban(
    String channel,
    String username,
    String? reason,
  ) async {
    username = _.username(username);

    // Send the command and wait for the server response.
    //
    // When a ban is applied or an error occour, a NOTICE will be received,
    // so we need to wait until we get that from the server to return.
    return await sendCommand<List<String>>(
      channel,
      "/ban ${username} ${reason}",
      () async {
        // Here we listen to the server response, by waiting the emit of
        // _promiseBan that is send by the Notice command.
        //  We clear the callback when we get the event.
        Completer<List<String>> completer = Completer();
        this.once('_promiseBan', (String? err) {
          if (err == null) {
            completer.complete([_.channel(channel), username, reason ?? '']);
          } else {
            completer.completeError(err);
          }
        });
        return completer.future;
      },
    );
  }

  // clear(channel) {
  // 	return this._sendCommand({ channel, command: '/clear' }, (res, rej) =>
  // 		this.once('_promiseClear', err => !err ? res([ _.channel(channel) ]) : rej(err))
  // 	);
  // }
  // color(newColor, _oldNewColor) {
  // 	newColor = _oldNewColor ?? newColor;
  // 	return this._sendCommand({ channel: this._globalDefaultChannel, command: `/color ${newColor}` }, (res, rej) =>
  // 		this.once('_promiseColor', err => !err ? res([ newColor ]) : rej(err))
  // 	);
  // }
  // commercial(channel, seconds) {
  // 	seconds = seconds ?? 30;
  // 	return this._sendCommand({ channel, command: `/commercial ${seconds}` }, (res, rej) =>
  // 		this.once('_promiseCommercial', err => !err ? res([ _.channel(channel), ~~seconds ]) : rej(err))
  // 	);
  // }
  // deletemessage(channel, messageUUID) {
  // 	return this._sendCommand({ channel, command: `/delete ${messageUUID}` }, (res, rej) =>
  // 		this.once('_promiseDeletemessage', err => !err ? res([ _.channel(channel) ]) : rej(err))
  // 	);
  // }
  // emoteonly(channel) {
  // 	return this._sendCommand({ channel, command: '/emoteonly' }, (res, rej) =>
  // 		this.once('_promiseEmoteonly', err => !err ? res([ _.channel(channel) ]) : rej(err))
  // 	);
  // }
  // emoteonlyoff(channel) {
  // 	return this._sendCommand({ channel, command: '/emoteonlyoff' }, (res, rej) =>
  // 		this.once('_promiseEmoteonlyoff', err => !err ? res([ _.channel(channel) ]) : rej(err))
  // 	);
  // }
  // followersonly(channel, minutes) {
  // 	minutes = minutes ?? 30;
  // 	return this._sendCommand({ channel, command: `/followers ${minutes}` }, (res, rej) =>
  // 		this.once('_promiseFollowers', err => !err ? res([ _.channel(channel), ~~minutes ]) : rej(err))
  // 	);
  // }
  // followersonlyoff(channel) {
  // 	return this._sendCommand({ channel, command: '/followersoff' }, (res, rej) =>
  // 		this.once('_promiseFollowersoff', err => !err ? res([ _.channel(channel) ]) : rej(err))
  // 	);
  // }
  // host(channel, target) {
  // 	target = _.username(target);
  // 	return this._sendCommand({ delay: 2000, channel, command: `/host ${target}` }, (res, rej) =>
  // 		this.once('_promiseHost', (err, remaining) => !err ? res([ _.channel(channel), target, ~~remaining ]) : rej(err))
  // 	);
  // }
  // join(channel) {
  // 	channel = _.channel(channel);
  // 	return this._sendCommand({ delay: undefined, channel: null, command: `JOIN ${channel}` }, (res, rej) => {
  // 		const eventName = '_promiseJoin';
  // 		let hasFulfilled = false;
  // 		const listener = (err, joinedChannel) => {
  // 			if(channel === _.channel(joinedChannel)) {
  // 				// Received _promiseJoin event for the target channel
  // 				this.removeListener(eventName, listener);
  // 				hasFulfilled = true;
  // 				!err ? res([ channel ]) : rej(err);
  // 			}
  // 		};
  // 		this.on(eventName, listener);
  // 		// Race the Promise against a delay
  // 		const delay = this._getPromiseDelay();
  // 		_.promiseDelay(delay).then(() => {
  // 			if(!hasFulfilled) {
  // 				this.emit(eventName, 'No response from Twitch.', channel);
  // 			}
  // 		});
  // 	});
  // }
  // mod(channel, username) {
  // 	username = _.username(username);
  // 	return this._sendCommand({ channel, command: `/mod ${username}` }, (res, rej) =>
  // 		this.once('_promiseMod', err => !err ? res([ _.channel(channel), username ]) : rej(err))
  // 	);
  // }

  // // Get list of mods on a channel
  // mods(channel) {
  // 	channel = _.channel(channel);
  // 	return this._sendCommand({ channel, command: '/mods' }, (resolve, reject) => {
  // 		this.once('_promiseMods', (err, mods) => {
  // 			if(!err) {
  // 				// Update the internal list of moderators
  // 				mods.forEach(username => {
  // 					if(!this.moderators[channel]) {
  // 						this.moderators[channel] = [];
  // 					}
  // 					if(!this.moderators[channel].includes(username)) {
  // 						this.moderators[channel].push(username);
  // 					}
  // 				});
  // 				resolve(mods);
  // 			}
  // 			else {
  // 				reject(err);
  // 			}
  // 		});
  // 	});
  // }
  // part(channel) {
  // 	return this._sendCommand({ delay: null, channel: null, command: `PART ${channel}` }, (res, rej) =>
  // 		this.once('_promisePart', err => !err ? res([ _.channel(channel) ]) : rej(err))
  // 	);
  // }
  // ping() {
  // 	return this._sendCommand({ delay: null, command: 'PING' }, (res, _rej) => {
  // 		// Update the internal ping timeout check interval
  // 		this.latency = new Date();
  // 		this.pingTimeout = setTimeout(() => {
  // 			if(this.ws !== null) {
  // 				this.wasCloseCalled = false;
  // 				this.log.error('Ping timeout.');
  // 				this.ws.close();

  // 				clearInterval(this.pingLoop);
  // 				clearTimeout(this.pingTimeout);
  // 			}
  // 		}, this.opts.connection.timeout ?? 9999);
  // 		this.once('_promisePing', latency => res([ parseFloat(latency) ]));
  // 	});
  // }
  // r9kbeta(channel) {
  // 	return this._sendCommand({ channel, command: '/r9kbeta' }, (res, rej) =>
  // 		this.once('_promiseR9kbeta', err => !err ? res([ _.channel(channel) ]) : rej(err))
  // 	);
  // }
  // r9kbetaoff(channel) {
  // 	return this._sendCommand({ channel, command: '/r9kbetaoff' }, (res, rej) =>
  // 		this.once('_promiseR9kbetaoff', err => !err ? res([ _.channel(channel) ]) : rej(err))
  // 	);
  // }
  // raw(command, tags) {
  // 	return this._sendCommand({ channel: null, command, tags }, (res, _rej) => res([ command ]));
  // }
  // reply(channel, message, replyParentMsgId, tags = {}) {
  // 	if(typeof replyParentMsgId === 'object') {
  // 		replyParentMsgId = replyParentMsgId.id;
  // 	}
  // 	if(!replyParentMsgId || typeof replyParentMsgId !== 'string') {
  // 		throw new Error('replyParentMsgId is required.');
  // 	}
  // 	return this.say(channel, message, { ...tags, 'reply-parent-msg-id': replyParentMsgId });
  // }
  // say(channel, message, tags) {
  // 	channel = _.channel(channel);
  // 	if((message.startsWith('.') && !message.startsWith('..')) || message.startsWith('/') || message.startsWith('\\')) {
  // 		// Check if the message is an action message
  // 		if(message.slice(1, 4) === 'me ') {
  // 			return this.action(channel, message.slice(4));
  // 		}
  // 		else {
  // 			return this._sendCommand({ channel, command: message, tags }, (res, _rej) =>
  // 				// The message is assumed to be sent and recieved by Twitch. The "client-nonce" tag can be used to
  // 				// detect a response on a USERNOTICE command, but it's not yet implemented here.
  // 				res([ channel, message ])
  // 			);
  // 		}
  // 	}
  // 	return this._sendMessage({ channel, message, tags }, (res, _rej) =>
  // 		// The message is assumed to be sent and recieved by Twitch. The "client-nonce" tag can be used to
  // 		// detect a response on a USERNOTICE command, but it's not yet implemented here.
  // 		res([ channel, message ])
  // 	);
  // }
  // slow(channel, seconds) {
  // 	seconds = seconds ?? 300;
  // 	return this._sendCommand({ channel, command: `/slow ${seconds}` }, (res, rej) =>
  // 		this.once('_promiseSlow', err => !err ? res([ _.channel(channel), ~~seconds ]) : rej(err))
  // 	);
  // }
  // slowoff(channel) {
  // 	return this._sendCommand({ channel, command: '/slowoff' }, (res, rej) =>
  // 		this.once('_promiseSlowoff', err => !err ? res([ _.channel(channel) ]) : rej(err))
  // 	);
  // }
  // subscribers(channel) {
  // 	return this._sendCommand({ channel, command: '/subscribers' }, (res, rej) =>
  // 		this.once('_promiseSubscribers', err => !err ? res([ _.channel(channel) ]) : rej(err))
  // 	);
  // }
  // subscribersoff(channel) {
  // 	return this._sendCommand({ channel, command: '/subscribersoff' }, (res, rej) =>
  // 		this.once('_promiseSubscribersoff', err => !err ? res([ _.channel(channel) ]) : rej(err))
  // 	);
  // }
  // timeout(channel, username, seconds, reason) {
  // 	username = _.username(username);

  // 	if((seconds ?? false) && !_.isInteger(seconds)) {
  // 		reason = seconds;
  // 		seconds = 300;
  // 	}

  // 	seconds = seconds ?? 300;
  // 	reason = reason ?? '';
  // 	return this._sendCommand({ channel, command: `/timeout ${username} ${seconds} ${reason}` }, (res, rej) =>
  // 		this.once('_promiseTimeout', err => !err ? res([ _.channel(channel), username, ~~seconds, reason ]) : rej(err))
  // 	);
  // }
  // unban(channel, username) {
  // 	username = _.username(username);
  // 	return this._sendCommand({ channel, command: `/unban ${username}` }, (res, rej) =>
  // 		this.once('_promiseUnban', err => !err ? res([ _.channel(channel), username ]) : rej(err))
  // 	);
  // }

  // // End the current hosting
  // unhost(channel) {
  // 	return this._sendCommand({ delay: 2000, channel, command: '/unhost' }, (res, rej) =>
  // 		this.once('_promiseUnhost', err => !err ? res([ _.channel(channel) ]) : rej(err))
  // 	);
  // }
  // unmod(channel, username) {
  // 	username = _.username(username);
  // 	return this._sendCommand({ channel, command: `/unmod ${username}` }, (res, rej) =>
  // 		this.once('_promiseUnmod', err => !err ? res([ _.channel(channel), username ]) : rej(err))
  // 	);
  // }
  // unvip(channel, username) {
  // 	username = _.username(username);
  // 	return this._sendCommand({ channel, command: `/unvip ${username}` }, (res, rej) =>
  // 		this.once('_promiseUnvip', err => !err ? res([ _.channel(channel), username ]) : rej(err))
  // 	);
  // }
  // vip(channel, username) {
  // 	username = _.username(username);
  // 	return this._sendCommand({ channel, command: `/vip ${username}` }, (res, rej) =>
  // 		this.once('_promiseVip', err => !err ? res([ _.channel(channel), username ]) : rej(err))
  // 	);
  // }
  // vips(channel) {
  // 	return this._sendCommand({ channel, command: '/vips' }, (res, rej) =>
  // 		this.once('_promiseVips', (err, vips) => !err ? res(vips) : rej(err))
  // 	);
  // }
  // whisper(username, message) {
  // 	username = _.username(username);

  // 	// The server will not send a whisper to the account that sent it.
  // 	if(username === this.getUsername()) {
  // 		return Promise.reject('Cannot send a whisper to the same account.');
  // 	}
  // 	return this._sendCommand({ delay: null, channel: this._globalDefaultChannel, command: `/w ${username} ${message}` }, (_res, rej) =>
  // 		this.once('_promiseWhisper', err => err && rej(err))
  // 	).catch(err => {
  // 		// Either an "actual" error occured or the timeout triggered
  // 		// the latter means no errors have occured and we can resolve
  // 		// else just elevate the error
  // 		if(err && typeof err === 'string' && err.indexOf('No response from Twitch.') !== 0) {
  // 			throw err;
  // 		}
  // 		const from = _.channel(username);
  // 		const userstate = Object.assign({
  // 			'message-type': 'whisper',
  // 			'message-id': null,
  // 			'thread-id': null,
  // 			username: this.getUsername()
  // 		}, this.globaluserstate);

  // 		// Emit for both, whisper and message
  // 		this.emits([ 'whisper', 'message' ], [
  // 			[ from, userstate, message, true ]
  // 		]);
  // 		return [ username, message ];
  // 	});
  // }}
}
