// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_user_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(appUserService)
final appUserServiceProvider = AppUserServiceProvider._();

final class AppUserServiceProvider
    extends $FunctionalProvider<AppUserService, AppUserService, AppUserService>
    with $Provider<AppUserService> {
  AppUserServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appUserServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appUserServiceHash();

  @$internal
  @override
  $ProviderElement<AppUserService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppUserService create(Ref ref) {
    return appUserService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppUserService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppUserService>(value),
    );
  }
}

String _$appUserServiceHash() => r'11a88d3da09b530824f395be5907f2d27a0f9ce1';
