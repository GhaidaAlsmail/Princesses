// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'firestore_appointment_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(firestoreAppoitmentRepository)
final firestoreAppoitmentRepositoryProvider =
    FirestoreAppoitmentRepositoryProvider._();

final class FirestoreAppoitmentRepositoryProvider
    extends
        $FunctionalProvider<
          FirestoreAppoitmentRepository,
          FirestoreAppoitmentRepository,
          FirestoreAppoitmentRepository
        >
    with $Provider<FirestoreAppoitmentRepository> {
  FirestoreAppoitmentRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'firestoreAppoitmentRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$firestoreAppoitmentRepositoryHash();

  @$internal
  @override
  $ProviderElement<FirestoreAppoitmentRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FirestoreAppoitmentRepository create(Ref ref) {
    return firestoreAppoitmentRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FirestoreAppoitmentRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FirestoreAppoitmentRepository>(
        value,
      ),
    );
  }
}

String _$firestoreAppoitmentRepositoryHash() =>
    r'2f7e8798ae150598699511dcd6cb7bd8f4136b82';
