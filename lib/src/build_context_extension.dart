import 'package:flutter/widgets.dart';
import 'package:signal_store/signal_store.dart';

extension SignalStoreContextExtension on BuildContext {
  S read<T, A, S extends ReadonlySignalMixin<T>>(
    SignalFactory<T, A, S> signalFactory, [
    A? args,
  ]) {
    return SignalStoreProvider.of(this, listen: false)(signalFactory, args);
  }

  S watch<T, A, S extends ReadonlySignalMixin<T>>(
    SignalFactory<T, A, S> signalFactory, [
    A? args,
  ]) {
    return SignalStoreProvider.of(this, listen: true)(signalFactory, args);
  }
}
