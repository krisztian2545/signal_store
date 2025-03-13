import 'package:flutter/widgets.dart';
import 'package:signal_store/model/model.dart';
import 'package:signal_store/widgets/signal_store_provider.dart';
import 'package:signals/signals.dart';

extension SignalStoreContextExtension on BuildContext {
  S read<T, A, S extends ReadonlySignalMixin<T>>(
    SignalFactory<T, A, S> signalFactory, [
    A? args,
  ]) {
    return SignalStoreProvider.of(this, listen: false)
        .container(signalFactory, args);
  }

  S watch<T, A, S extends ReadonlySignalMixin<T>>(
    SignalFactory<T, A, S> signalFactory, [
    A? args,
  ]) {
    return SignalStoreProvider.of(this, listen: true)
        .container(signalFactory, args);
  }
}
