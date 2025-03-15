import 'package:signal_store/signal_store.dart';

typedef SignalFactory<T, A, S extends ReadonlySignalMixin<T>> = S Function(
  Ref<T, S> ref,
  A args,
);

extension type SignalStoreContainer._(SignalContainer container)
    implements SignalContainer {
  factory SignalStoreContainer() {
    late final SignalStoreContainer ref;
    ref = SignalStoreContainer._(SignalContainer(
      (k) => _create(() => ref, k),
      cache: true,
    ));
    return ref;
  }

  static S _create<T, A, S extends ReadonlySignalMixin<T>>(
    SignalStoreContainer Function() getContainer,
    (SignalFactory<T, A, S>, A) key,
  ) {
    final (constructor, args) = key;
    // [SignalContainer] cares about removing the disposed signal from the container
    late final S generatedSignal;
    return generatedSignal = constructor(
      Ref(getContainer(), () => generatedSignal),
      args,
    );
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
