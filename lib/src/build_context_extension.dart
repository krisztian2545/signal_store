import 'package:flutter/widgets.dart';
import 'package:signal_store/signal_store.dart';

extension SignalStoreContextExtension on BuildContext {
  SignalStoreContainer get readStore =>
      SignalStoreProvider.of(this, listen: false);

  SignalStoreContainer get store => SignalStoreProvider.of(this, listen: true);
}
