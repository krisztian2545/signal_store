import 'package:signal_store/signal_store.dart';

class Ref<T, S extends ReadonlySignalMixin<T>> {
  Ref(this.store, this.getGeneratedSignal);

  final SignalStoreContainer store;
  final S Function() getGeneratedSignal;

  /// Don't use right inside the generator function, only in a code
  /// that runs after generating the signal. So in callbacks and sync code.
  ReadonlySignal<T> get generatedSignal =>
      getGeneratedSignal() as ReadonlySignal<T>;

  final List<void Function()> _disposeCallbacks = [];

  void onDispose(void Function() callback) {
    _disposeCallbacks.add(callback);
  }

  bool removeDisposeCallback(void Function() callback) {
    return _disposeCallbacks.remove(callback);
  }

  void dispose() {
    for (int i = 0; i < _disposeCallbacks.length; i++) {
      _disposeCallbacks[i]();
    }
  }

  // [SignalStoreContainer] proxy API

  CS call<CT, CA, CS extends ReadonlySignalMixin<CT>>(
    SignalFactory<CT, CA, CS> signalFactory, [
    CA? args,
  ]) {
    return store(signalFactory, args);
  }

  /// Warning: this doesn't dispose the signal!
  CS? remove<CT, CA, CS extends ReadonlySignalMixin<CT>>(
    SignalFactory<CT, CA, CS> signalFactory, [
    CA? args,
  ]) {
    return store.remove(signalFactory, args);
  }

  CS? removeAndDispose<CT, CA, CS extends ReadonlySignalMixin<CT>>(
    SignalFactory<CT, CA, CS> signalFactory, [
    CA? args,
  ]) {
    return store.removeAndDispose(signalFactory, args);
  }

  bool contains<CT, CA, CS extends ReadonlySignalMixin<CT>>(
    SignalFactory<CT, CA, CS> signalFactory, [
    CA? args,
  ]) {
    return store.contains(signalFactory, args);
  }
}
