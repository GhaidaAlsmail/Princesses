// import 'package:freezed_annotation/freezed_annotation.dart';

// part 'app_user.freezed.dart';
// part 'app_user.g.dart';

// @freezed
// abstract class AppUser with _$AppUser {
//   factory AppUser({
//     String? id,
//     required String name,
//     required String email,
//     required String city,
//     String? notes,
//     String? password,
//     DateTime? birthDate,
//     String? profilePictureUrl,
//     List<String>? nickNames,
//     String? phone,
//     @Default(false) bool isAdmin,
//     @Default(0) int stars,
//   }) = _AppUser;

//   factory AppUser.fromJson(Map<String, dynamic> json) =>
//       _$AppUserFromJson(json);
// }
class AppUser {
  final String? id;
  final String name;
  final String email;
  final String city;
  final String? notes;
  final String? password;
  final DateTime? birthDate;
  final String? profilePictureUrl;
  final List<String>? nickNames;
  final String? phone;
  final bool isAdmin;
  final int stars;

  // 1. Constructor الموديل مع تحديد القيم الافتراضية للـ isAdmin والـ stars
  const AppUser({
    this.id,
    required this.name,
    required this.email,
    required this.city,
    this.notes,
    this.password,
    this.birthDate,
    this.profilePictureUrl,
    this.nickNames,
    this.phone,
    this.isAdmin = false,
    this.stars = 0,
  });

  // 2. دالة التحويل من Map/JSON إلى Object
  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String?,
      name: json['name'] as String? ?? "",
      email: json['email'] as String? ?? "",
      city: json['city'] as String? ?? "",
      notes: json['notes'] as String?,
      password: json['password'] as String?,
      birthDate: json['birthDate'] != null
          ? DateTime.parse(json['birthDate'] as String)
          : null,
      profilePictureUrl: json['profilePictureUrl'] as String?,
      nickNames: (json['nickNames'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      phone: json['phone'] as String?,
      isAdmin: json['isAdmin'] as bool? ?? false,
      stars: json['stars'] as int? ?? 0,
    );
  }

  // 3. دالة التحويل من Object إلى Map/JSON للحفظ في قاعدة البيانات
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'city': city,
      'notes': notes,
      'password': password,
      'birthDate': birthDate?.toIso8601String(),
      'profilePictureUrl': profilePictureUrl,
      'nickNames': nickNames,
      'phone': phone,
      'isAdmin': isAdmin,
      'stars': stars,
    };
  }

  // 4. دالة copyWith لتعديل الحقول بسهولة
  AppUser copyWith({
    String? id,
    String? name,
    String? email,
    String? city,
    String? notes,
    String? password,
    DateTime? birthDate,
    String? profilePictureUrl,
    List<String>? nickNames,
    String? phone,
    bool? isAdmin,
    int? stars,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      city: city ?? this.city,
      notes: notes ?? this.notes,
      password: password ?? this.password,
      birthDate: birthDate ?? this.birthDate,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      nickNames: nickNames ?? this.nickNames,
      phone: phone ?? this.phone,
      isAdmin: isAdmin ?? this.isAdmin,
      stars: stars ?? this.stars,
    );
  }
}
