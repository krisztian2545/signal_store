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
    final (generatorFunction, args) = key;
    // [SignalContainer] cares about removing the disposed signal from the container
    late final S generatedSignal;
    final ref = Ref<T, S>(getContainer(), () => generatedSignal);
    generatedSignal = generatorFunction(ref, args)..onDispose(ref.dispose);
    return generatedSignal;
  }

  S call<T, A, S extends ReadonlySignalMixin<T>>(
    SignalFactory<T, A, S> signalFactory, [
    A? args,
  ]) {
    return container((signalFactory, args)) as S;
  }

  /// Warning: this doesn't dispose the signal!
  S? remove<T, A, S extends ReadonlySignalMixin<T>>(
    SignalFactory<T, A, S> signalFactory, [
    A? args,
  ]) {
    return container.remove((signalFactory, args)) as S;
  }

  S? removeAndDispose<T, A, S extends ReadonlySignalMixin<T>>(
    SignalFactory<T, A, S> signalFactory, [
    A? args,
  ]) {
    final removedSignal = container.remove((signalFactory, args))?..dispose();
    return removedSignal as S;
  }

  bool contains<T, A, S extends ReadonlySignalMixin<T>>(
    SignalFactory<T, A, S> signalFactory, [
    A? args,
  ]) {
    return container.containsKey((signalFactory, args));
  }

  S? existing<T, A, S extends ReadonlySignalMixin<T>>(
    SignalFactory<T, A, S> signalFactory, [
    A? args,
  ]) {
    final key = (signalFactory, args);
    if (container.containsKey(key)) {
      return container(key) as S;
    }
    return null;
  }
}
