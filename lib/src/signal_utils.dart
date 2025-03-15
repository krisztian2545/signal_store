import 'package:signals/signals.dart';

final _subscriptions = <(Object, Object)>{};

extension SignalStoreSignalUtils<T, S extends ReadonlySignal<T>> on S {
  S liveUntil(ReadonlySignal other) {
    final pair = (this, other);
    if (_subscriptions.contains(pair)) return this;
    _subscriptions.add(pair);

    final unsub = subscribe((_) {});
    other.onDispose(() {
      unsub();
      _subscriptions.remove(pair);
    });
    return this;
  }
}

extension SignalStoreObjectUtils<T extends Object> on T {
  T disposeWithSignal(ReadonlySignal s, [void Function(T)? dispose]) {
    final pair = (this, s);
    if (_subscriptions.contains(pair)) return this;
    _subscriptions.add(pair);

    s.onDispose(() {
      if (dispose != null) {
        dispose(this);
      } else {
        (this as dynamic).dispose();
      }
      _subscriptions.remove(pair);
    });
    return this;
  }

  T disposeWith(Object o, [void Function(T)? dispose]) {
    final pair = (this, o);
    if (_subscriptions.contains(pair)) return this;
    _subscriptions.add(pair);

    (o as dynamic).onDispose(() {
      if (dispose != null) {
        dispose(this);
      } else {
        (this as dynamic).dispose();
      }
      _subscriptions.remove(pair);
    });
    return this;
  }
}
