import 'package:signals/signals.dart';

typedef SignalFactory<T, A, S extends ReadonlySignalMixin<T>> = S Function(
  Ref ref,
  A args,
);

extension type Ref._(SignalContainer container) implements SignalContainer {
  factory Ref() {
    late final Ref ref;
    ref = Ref._(SignalContainer(
      (k) => _create(() => ref, k),
      cache: true,
    ));
    return ref;
  }

  static S _create<T, S extends ReadonlySignalMixin<T>>(
    Ref Function() getContainer,
    key,
  ) {
    final (constructor, args) = key;
    // [SignalContainer] cares about removing the disposed signal from the container
    return constructor(getContainer(), args);
  }

  S call<T, A, S extends ReadonlySignalMixin<T>>(
    SignalFactory<T, A, S> signalFactory, [
    A? args,
  ]) {
    return container((signalFactory, args)) as S;
  }

  S? remove<T, A, S extends ReadonlySignalMixin<T>>(
    SignalFactory<T, A, S> signalFactory, [
    A? args,
  ]) {
    return store.remove((signalFactory, args)) as S;
  }

  bool contains<T, A, S extends ReadonlySignalMixin<T>>(
    SignalFactory<T, A, S> signalFactory, [
    A? args,
  ]) {
    return store.containsKey((signalFactory, args));
  }
}
