import 'package:flutter/widgets.dart';
import 'package:signal_store/signal_store.dart';

class _SignalStoreInheritedWidget extends InheritedWidget {
  const _SignalStoreInheritedWidget({
    required this.container,
    required super.child,
    super.key,
  });

  final SignalStoreContainer container;

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) =>
      oldWidget is _SignalStoreInheritedWidget &&
      oldWidget.container != container;
}

class SignalStoreProvider extends StatefulWidget {
  const SignalStoreProvider({
    super.key,
    this.child,
    this.builder,
    this.disposeBehavior = const DoNotDisposeGivenSignalStore(),
  })  : store = null,
        assert(
          child != null || builder != null,
          "Either child or builder must be given.",
        );

  const SignalStoreProvider.value({
    super.key,
    required SignalStoreContainer this.store,
    this.child,
    this.builder,
    this.disposeBehavior = const DoNotDisposeGivenSignalStore(),
  }) : assert(
          child != null || builder != null,
          "Either child or builder must be given.",
        );

  final SignalStoreContainer? store;

  final Widget? child;
  final Widget Function(BuildContext context, Widget? child)? builder;

  final SignalStoreProviderDisposeBehavior disposeBehavior;

  @override
  State<SignalStoreProvider> createState() => _SignalStoreProviderState();

  static SignalStoreContainer of(BuildContext context, {bool listen = true}) {
    final provider = listen
        ? context
            .dependOnInheritedWidgetOfExactType<_SignalStoreInheritedWidget>()
        : context.getInheritedWidgetOfExactType<_SignalStoreInheritedWidget>();

    assert(
      provider != null,
      'SignalStoreProvider.of() was called with a context that does not contain a SignalStoreProvider widget.\n'
      'No SignalStoreProvider widget ancestor could be found starting from the context that '
      'was passed to SignalStoreProvider.of(). This can happen because you are using a widget '
      'that looks for a SignalStoreProvider ancestor, but no such ancestor exists.\n'
      'The context used was:\n'
      '  $context',
    );

    return provider!.container;
  }
}

class _SignalStoreProviderState extends State<SignalStoreProvider> {
  late SignalStoreContainer _store = _getStore();

  SignalStoreContainer _getStore() => widget.store ?? SignalStoreContainer();

  @override
  void didUpdateWidget(covariant SignalStoreProvider oldWidget) {
    if (oldWidget.store != widget.store) {
      _store = _getStore();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return _SignalStoreInheritedWidget(
      container: _store,
      child: widget.builder?.call(context, widget.child) ?? widget.child!,
    );
  }

  @override
  void dispose() {
    widget.disposeBehavior.dispose(widget, _store);
    super.dispose();
  }
}

typedef SignalStoreDisposeBehaviorCallback = void Function(
    SignalStoreProvider widget, SignalStoreContainer store);

abstract class SignalStoreProviderDisposeBehavior {
  const SignalStoreProviderDisposeBehavior();
  void dispose(SignalStoreProvider widget, SignalStoreContainer store);
}

class SignalStoreDisposeBehaviorDelegate
    extends SignalStoreProviderDisposeBehavior {
  const SignalStoreDisposeBehaviorDelegate._(this.callback);

  const SignalStoreDisposeBehaviorDelegate.from(this.callback);

  final SignalStoreDisposeBehaviorCallback callback;

  @override
  void dispose(SignalStoreProvider widget, SignalStoreContainer store) =>
      callback(widget, store);
}

class AlwaysDisposeSignalStore extends SignalStoreProviderDisposeBehavior {
  const AlwaysDisposeSignalStore();
  @override
  void dispose(SignalStoreProvider widget, SignalStoreContainer store) {
    store.dispose();
  }
}

class DoNotDisposeGivenSignalStore extends SignalStoreProviderDisposeBehavior {
  const DoNotDisposeGivenSignalStore();
  @override
  void dispose(SignalStoreProvider widget, SignalStoreContainer store) {
    // dispose store if it wasn't injected from outside
    if (widget.store == null) {
      store.dispose();
    }
  }
}
