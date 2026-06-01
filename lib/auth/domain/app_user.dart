import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_user.freezed.dart';
part 'app_user.g.dart';

@freezed
abstract class AppUser with _$AppUser {
  factory AppUser({
    String? id,
    required String name,
    required String email,
    required String city,
    String? notes,
    String? password,
    DateTime? birthDate,
    String? profilePictureUrl,
    List<String>? nickNames,
    String? phone,
    @Default(false) bool isAdmin,
    @Default(0) int stars,
  }) = _AppUser;

  factory AppUser.fromJson(Map<String, dynamic> json) =>
      _$AppUserFromJson(json);
}
