import 'package:signals/signals.dart';

typedef SignalFactory<T, A, S extends ReadonlySignalMixin<T>> = S Function(
  Ref ref,
  A args,
);

// class SignalStoreContainer extends SignalContainer {
//   SignalStoreContainer._hidden({
//     required SignalStoreContainer Function() getSelf,
//   }) : super(
//           (k) => _create(getSelf, k),
//           cache: true,
//         );

//   factory SignalStoreContainer() {
//     late final SignalStoreContainer ref;
//     ref = SignalStoreContainer._hidden(getSelf: () => ref);
//     return ref;
//   }

//   static S _create<T, S extends ReadonlySignalMixin<T>>(
//     SignalStoreContainer Function() getContainer,
//     key,
//   ) {
//     try {
//       final (constructor, args) = key;
//       // [SignalContainer] cares about removing the disposed signal from the container
//       return constructor(getContainer(), args);
//     } catch (e) {
//       // TODO
//       rethrow;
//     }
//   }
// }

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
    try {
      final (constructor, args) = key;
      // [SignalContainer] cares about removing the disposed signal from the container
      return constructor(getContainer(), args);
    } catch (e) {
      // TODO
      rethrow;
    }
  }

  S call<T, A, S extends ReadonlySignalMixin<T>>(
    SignalFactory<T, A, S> signalFactory, [
    A? args,
  ]) {
    return container((signalFactory, args)) as S;
  }
}
