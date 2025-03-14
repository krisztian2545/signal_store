import 'package:flutter_test/flutter_test.dart';

import 'package:signal_store/signal_store.dart';
import 'package:signals/signals.dart';

void main() {
  test('create and get', () {
    final ref = Ref();

    Signal<String> testFactory(ref, args) => signal('$args');

    const value = 'hi';
    final result = ref(testFactory, value);

    expect(result.value, value);
    expect(ref.containsKey((testFactory, value)), true);
  });

  test('reference other signal', () {
    final ref = Ref();

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
    final ref = Ref();

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
    final ref = Ref();

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

  test('liveUntil', () {
    final ref = Ref();

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

    ref(greeting).liveUntil(ref(last));
    unsub();

    expect(ref.containsKey((greeting, null)), true);
    expect(ref.containsKey((greetPerson, 'John')), false);
    expect(ref.containsKey((last, null)), true);

    ref(last).dispose();

    expect(ref.containsKey((greeting, null)), false);
    expect(ref.containsKey((greetPerson, 'John')), false);
    expect(ref.containsKey((last, null)), false);
  });

  test('disposeWithSignal with object having a dispose function', () {
    final ref = Ref();

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
    final ref = Ref();

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
}
