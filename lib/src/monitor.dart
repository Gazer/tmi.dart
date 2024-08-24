import 'package:tmi/src/client_base.dart';

/// Ping/Pong monitor
class Monitor {
  final ClientBase client;

  bool pingSent = false;
  bool monitoring = false;

  Monitor(this.client) {
    client.on("pong", (_) {
      pingSent = false;
    });
  }

  void loop() async {
    monitoring = true;
    while (monitoring) {
      client.send("PING");
      client.latency = DateTime.now();
      pingSent = true;
      await Future.delayed(Duration(milliseconds: 9999));

      if (pingSent == true) {
        // Pong never received!
        print("NO PONG. Closing ...");
      }

      await Future.delayed(Duration(milliseconds: 60000));
    }
  }

  void stop() {
    monitoring = false;
  }
}

// 				// Set an internal ping timeout check interval..
// 				this.pingLoop = setInterval(() => {
// 					// Make sure the connection is opened before sending the message..
// 					if(!_.isNull(this.ws) && this.ws.readyState === 1) {
// 						this.ws.send("PING");
// 					}
// 					this.latency = new Date();
// 					this.pingTimeout = setTimeout(() => {
// 						if(!_.isNull(this.ws)) {
// 							this.wasCloseCalled = false;
// 							this.log.error("Ping timeout.");
// 							this.ws.close();

// 							clearInterval(this.pingLoop);
// 							clearTimeout(this.pingTimeout);
// 						}
// 					}, _.get(this.opts.connection.timeout, 9999));
// 				}, 60000);

// 				// Join all the channels from the config with an interval..
// 				var joinInterval = _.get(this.opts.options.joinInterval, 2000);
// 				if(joinInterval < 300) joinInterval = 300;
// 				var joinQueue = new timer.queue(joinInterval);
// 				var joinChannels = _.union(this.opts.channels, this.channels);
// 				this.channels = [];

// 				for (var i = 0; i < joinChannels.length; i++) {
// 					let channel = joinChannels[i];
// 					joinQueue.add(() => {
// 						if(!_.isNull(this.ws) && this.ws.readyState === 1) {
// 							this.join(channel).catch(err => this.log.error(err));
// 						}
// 					});
// 				}

// 				joinQueue.run();
// 				break;
