import 'package:flutter_test/flutter_test.dart';

import 'package:signal_store/signal_store.dart';

void main() {
  test('create and get', () {
    final ref = SignalStoreContainer();

    Signal<String> testFactory(ref, args) => signal('$args');

    const value = 'hi';
    final result = ref(testFactory, value);

    expect(result.value, value);
    expect(ref.containsKey((testFactory, value)), true);
  });

  test('reference other signal', () {
    final ref = SignalStoreContainer();

    Signal<String> greeting(_, __) => signal('hello');
    Signal<String> greetPerson(Ref ref, String name) {
      final greetText = ref(greeting).value;
      return signal('$greetText $name');
    }

    final result = ref(greetPerson, 'John');

    expect(result.value, 'hello John');
    expect(ref.containsKey((greeting, null)), true);
    expect(ref.containsKey((greetPerson, 'John')), true);
  });

  test('update signal when referenced signal changes', () {
    final ref = SignalStoreContainer();

    Signal<String> greeting(_, __) => signal('hello');
    Computed<String> greetPerson(Ref ref, String name) {
      final greetSignal = ref(greeting);
      return computed(() => '${greetSignal.value} $name');
    }

    final result = ref(greetPerson, 'John');

    expect(result.value, 'hello John');
    expect(ref.containsKey((greeting, null)), true);
    expect(ref.containsKey((greetPerson, 'John')), true);

    ref(greeting).value = 'hi';

    expect(result.value, 'hi John');
    expect(ref.containsKey((greeting, null)), true);
    expect(ref.containsKey((greetPerson, 'John')), true);
  });

  test('auto dispose signals', () {
    final ref = SignalStoreContainer();

    Signal<String> greeting(_, __) => signal('hello', autoDispose: true);
    Computed<String> greetPerson(Ref ref, String name) {
      final greetSignal = ref(greeting);
      return computed(() => '${greetSignal.value} $name', autoDispose: true);
    }

    final result = ref(greetPerson, 'John');
    final unsub = effect(() => result.value);

    expect(result.value, 'hello John');
    expect(ref.containsKey((greeting, null)), true);
    expect(ref.containsKey((greetPerson, 'John')), true);

    ref(greeting).value = 'hi';

    expect(result.value, 'hi John');
    expect(ref.containsKey((greeting, null)), true);
    expect(ref.containsKey((greetPerson, 'John')), true);

    unsub();

    expect(ref.containsKey((greeting, null)), false);
    expect(ref.containsKey((greetPerson, 'John')), false);
  });

  test('liveUntilSignal', () {
    final ref = SignalStoreContainer();

    Signal<String> greeting(_, __) => signal('hello', autoDispose: true);
    Computed<String> greetPerson(Ref ref, String name) {
      final greetSignal = ref(greeting);
      return computed(() => '${greetSignal.value} $name', autoDispose: true);
    }

    Signal last(_, __) => signal(null);

    final result = ref(greetPerson, 'John');
    final unsub = effect(() => result.value);

    expect(result.value, 'hello John');
    expect(ref.containsKey((greeting, null)), true);
    expect(ref.containsKey((greetPerson, 'John')), true);

    ref(greeting).value = 'hi';

    expect(result.value, 'hi John');
    expect(ref.containsKey((greeting, null)), true);
    expect(ref.containsKey((greetPerson, 'John')), true);

    ref(greeting).liveUntilSignal(ref(last));
    unsub();

    expect(ref.containsKey((greeting, null)), true);
    expect(ref.containsKey((greetPerson, 'John')), false);
    expect(ref.containsKey((last, null)), true);

    ref(last).dispose();

    expect(ref.containsKey((greeting, null)), false);
    expect(ref.containsKey((greetPerson, 'John')), false);
    expect(ref.containsKey((last, null)), false);
  });

  test('liveUntilRef', () {
    final ref = SignalStoreContainer();
    final autoDisposeSignal = signal(0, autoDispose: true);

    controlSignalProvider(Ref ref, _) {
      autoDisposeSignal.liveUntilRef(ref);
      return signal(0);
    }

    ref(controlSignalProvider);

    expect(ref.contains(controlSignalProvider), true);
    expect(autoDisposeSignal.disposed, false);

    ref(controlSignalProvider).dispose();

    expect(ref.contains(controlSignalProvider), false);
    expect(autoDisposeSignal.disposed, true);
  });

  test('disposeWithSignal with object having a dispose function', () {
    final ref = SignalStoreContainer();

    Signal<String> greeting(_, __) => signal('hello', autoDispose: true);
    Computed<String> greetPerson(Ref ref, String name) {
      final greetSignal = ref(greeting);
      return computed(() => '${greetSignal.value} $name', autoDispose: true);
    }

    final greetPersonSignal = ref(greetPerson, 'John');
    final unsub = effect(() => greetPersonSignal.value);

    final data = ['0', '1'];
    final testObject = (
      data,
      dispose: () => data.clear(),
    )..disposeWithSignal(greetPersonSignal);

    expect(greetPersonSignal.value, 'hello John');
    expect(ref.containsKey((greeting, null)), true);
    expect(ref.containsKey((greetPerson, 'John')), true);
    expect(testObject.$1.isNotEmpty, true);

    ref(greeting).value = 'hi';

    expect(greetPersonSignal.value, 'hi John');
    expect(ref.containsKey((greeting, null)), true);
    expect(ref.containsKey((greetPerson, 'John')), true);
    expect(testObject.$1.isNotEmpty, true);

    unsub();

    expect(ref.containsKey((greeting, null)), false);
    expect(ref.containsKey((greetPerson, 'John')), false);
    expect(testObject.$1.isEmpty, true);
  });

  test('disposeWithSignal with a provided dispose function', () {
    final ref = SignalStoreContainer();

    Signal<String> greeting(_, __) => signal('hello', autoDispose: true);
    Computed<String> greetPerson(Ref ref, String name) {
      final greetSignal = ref(greeting);
      return computed(() => '${greetSignal.value} $name', autoDispose: true);
    }

    final greetPersonSignal = ref(greetPerson, 'John');
    final unsub = effect(() => greetPersonSignal.value);

    final data = ['0', '1'];
    final testObject = (data,)
      ..disposeWithSignal(greetPersonSignal, (o) => o.$1.clear());

    expect(greetPersonSignal.value, 'hello John');
    expect(ref.containsKey((greeting, null)), true);
    expect(ref.containsKey((greetPerson, 'John')), true);
    expect(testObject.$1.isNotEmpty, true);

    ref(greeting).value = 'hi';

    expect(greetPersonSignal.value, 'hi John');
    expect(ref.containsKey((greeting, null)), true);
    expect(ref.containsKey((greetPerson, 'John')), true);
    expect(testObject.$1.isNotEmpty, true);

    unsub();

    expect(ref.containsKey((greeting, null)), false);
    expect(ref.containsKey((greetPerson, 'John')), false);
    expect(testObject.$1.isEmpty, true);
  });

  test('disposeWith(ref)', () {
    final ref = SignalStoreContainer();
    bool isDisposed = false;
    testSignalProvider(Ref ref, _) {
      (dispose: () => isDisposed = true,).disposeWith(ref);
      return signal(0);
    }

    ref(testSignalProvider);

    expect(ref.contains(testSignalProvider), true);
    expect(isDisposed, false);

    ref(testSignalProvider).dispose();

    expect(ref.contains(testSignalProvider), false);
    expect(isDisposed, true);
  });

  test('ref.generatedSignal', () {
    final ref = SignalStoreContainer();
    late final ReadonlySignal Function() getSignal;

    Signal<String> testSignalProvider(Ref ref, __) {
      getSignal = () => ref.generatedSignal;
      return signal('hello');
    }

    final testSignal = ref(testSignalProvider);

    expect(testSignal, getSignal());
  });

  test('existing', () {
    final ref = SignalStoreContainer();
    testFactory(ref, args) => signal(0);

    expect(ref.containsKey((testFactory, null)), false);
    expect(ref.existing(testFactory), null);

    final data = ref(testFactory);

    expect(ref.containsKey((testFactory, null)), true);
    expect(ref.existing(testFactory), data);
  });
}
