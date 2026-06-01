// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'firestore_app_user_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(firestoreAppUserRepository)
final firestoreAppUserRepositoryProvider =
    FirestoreAppUserRepositoryProvider._();

final class FirestoreAppUserRepositoryProvider
    extends
        $FunctionalProvider<
          FirestoreAppUserRepository,
          FirestoreAppUserRepository,
          FirestoreAppUserRepository
        >
    with $Provider<FirestoreAppUserRepository> {
  FirestoreAppUserRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'firestoreAppUserRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$firestoreAppUserRepositoryHash();

  @$internal
  @override
  $ProviderElement<FirestoreAppUserRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FirestoreAppUserRepository create(Ref ref) {
    return firestoreAppUserRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FirestoreAppUserRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FirestoreAppUserRepository>(value),
    );
  }
}

String _$firestoreAppUserRepositoryHash() =>
    r'8f09b44f0c4467dbad42b7ecc400ae67acc17e3a';
