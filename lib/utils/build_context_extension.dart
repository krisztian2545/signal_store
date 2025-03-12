import 'package:flutter/widgets.dart';
import 'package:signal_store/model/model.dart';
import 'package:signal_store/widgets/signal_store_provider.dart';
import 'package:signals/signals.dart';

extension SignalStoreContextExtension on BuildContext {
  S ref<T, A, S extends ReadonlySignalMixin<T>>(
    SignalFactory<T, A, S> signalFactory,
    A args, {
    bool listen = true,
  }) {
    return SignalStoreProvider.of(this, listen: listen)
        .container(signalFactory, args);
  }
}
