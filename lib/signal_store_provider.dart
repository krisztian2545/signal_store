import 'package:flutter/widgets.dart';

import 'signal_store_container.dart';

class SignalStoreProvider extends InheritedWidget {
  SignalStoreProvider({
    super.key,
    required super.child,
  }) {
    container = Ref();
  }

  // ignore: prefer_const_constructors_in_immutables
  SignalStoreProvider.from({
    required this.container,
    required super.child,
    super.key,
  });

  late final Ref container;

  static SignalStoreProvider of(BuildContext context, {bool listen = true}) {
    final provider = listen
        ? context.dependOnInheritedWidgetOfExactType<SignalStoreProvider>()
        : context.getInheritedWidgetOfExactType<SignalStoreProvider>();

    assert(
      provider != null,
      'SignalStoreProvider.of() was called with a context that does not contain a SignalStoreProvider widget.\n'
      'No SignalStoreProvider widget ancestor could be found starting from the context that '
      'was passed to SignalStoreProvider.of(). This can happen because you are using a widget '
      'that looks for a SignalStoreProvider ancestor, but no such ancestor exists.\n'
      'The context used was:\n'
      '  $context',
    );

    return provider!;
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) =>
      oldWidget is SignalStoreProvider && oldWidget.container != container;
}
