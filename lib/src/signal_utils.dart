import 'package:signals/signals.dart';

extension SignalStoreSignalUtils<T, S extends ReadonlySignal<T>> on S {
  S liveUntil(ReadonlySignal other) {
    final unsub = subscribe((_) {});
    other.onDispose(unsub);
    return this;
  }
}
