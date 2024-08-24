import 'package:eventify/eventify.dart';

class ClientEmitter {
  final EventEmitter _emitter = new EventEmitter();

  Listener once(String event, Function f) {
    final wrapper = _OnceWrapper(f);
    final listener = on(event, wrapper.call);
    wrapper.listener = listener;
    return listener;
  }

  Listener on(String event, Function f) {
    return _emitter.on(event, this, (ev, context) {
      List params = ev.eventData == null ? [] : ev.eventData as List;
      switch (params.length) {
        case 0:
          f();
          break;
        case 1:
          f(params[0]);
          break;
        case 2:
          f(params[0], params[1]);
          break;
        case 3:
          f(params[0], params[1], params[2]);
          break;
        case 4:
          f(params[0], params[1], params[2], params[3]);
          break;
        case 5:
          f(params[0], params[1], params[2], params[3], params[4]);
          break;
        case 6:
          f(params[0], params[1], params[2], params[3], params[4], params[5]);
          break;
        default:
          throw Exception("Got more params that I can handle");
      }
    });
  }

  int getListenersCount(String event) {
    return _emitter.getListenersCount(event);
  }

  void emits(List<String> types, List values) {
    for (var i = 0; i < types.length; i++) {
      var val = i < values.length ? values[i] : values[values.length - 1];
      emit(types[i], val);
    }
  }

  void emit(String type, [List? params]) {
    _emitter.emit(type, null, params);
  }
}

class _NoParam {
  const _NoParam();
}

// This class is a wrapper for the `on` callback that
// when executed will be removed from the emitter.
// That way, we simulate a `once` call for listen and
// react on promises emited by other commands.
class _OnceWrapper {
  final Function f;
  Listener? listener;

  _OnceWrapper(this.f);

  void call([
    n1 = const _NoParam(),
    n2 = const _NoParam(),
    n3 = const _NoParam(),
    n4 = const _NoParam(),
    n5 = const _NoParam(),
    n6 = const _NoParam(),
  ]) {
    listener?.cancel();
    if (!(n6 is _NoParam)) {
      f(n1, n2, n3, n4, n5, n6);
    } else if (!(n5 is _NoParam)) {
      f(n1, n2, n3, n4, n5);
    } else if (!(n4 is _NoParam)) {
      f(n1, n2, n3, n4);
    } else if (!(n3 is _NoParam)) {
      f(n1, n2, n3);
    } else if (!(n2 is _NoParam)) {
      f(n1, n2);
    } else if (!(n1 is _NoParam)) {
      f(n1);
    } else {
      f();
    }
  }
}
