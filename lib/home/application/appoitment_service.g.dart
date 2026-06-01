// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appoitment_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(appoitmentService)
final appoitmentServiceProvider = AppoitmentServiceProvider._();

final class AppoitmentServiceProvider
    extends
        $FunctionalProvider<
          AppoitmentService,
          AppoitmentService,
          AppoitmentService
        >
    with $Provider<AppoitmentService> {
  AppoitmentServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appoitmentServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appoitmentServiceHash();

  @$internal
  @override
  $ProviderElement<AppoitmentService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AppoitmentService create(Ref ref) {
    return appoitmentService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppoitmentService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppoitmentService>(value),
    );
  }
}

String _$appoitmentServiceHash() => r'8ccbe268c28376c2b92afc787943837402670049';
