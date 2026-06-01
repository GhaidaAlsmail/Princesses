// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AppUser {

 String? get id; String get name; String get email; String get city; String? get notes; String? get password; DateTime? get birthDate; String? get profilePictureUrl; List<String>? get nickNames; String? get phone; bool get isAdmin; int get stars;
/// Create a copy of AppUser
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppUserCopyWith<AppUser> get copyWith => _$AppUserCopyWithImpl<AppUser>(this as AppUser, _$identity);

  /// Serializes this AppUser to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppUser&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.city, city) || other.city == city)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.password, password) || other.password == password)&&(identical(other.birthDate, birthDate) || other.birthDate == birthDate)&&(identical(other.profilePictureUrl, profilePictureUrl) || other.profilePictureUrl == profilePictureUrl)&&const DeepCollectionEquality().equals(other.nickNames, nickNames)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.isAdmin, isAdmin) || other.isAdmin == isAdmin)&&(identical(other.stars, stars) || other.stars == stars));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,email,city,notes,password,birthDate,profilePictureUrl,const DeepCollectionEquality().hash(nickNames),phone,isAdmin,stars);

@override
String toString() {
  return 'AppUser(id: $id, name: $name, email: $email, city: $city, notes: $notes, password: $password, birthDate: $birthDate, profilePictureUrl: $profilePictureUrl, nickNames: $nickNames, phone: $phone, isAdmin: $isAdmin, stars: $stars)';
}


}

/// @nodoc
abstract mixin class $AppUserCopyWith<$Res>  {
  factory $AppUserCopyWith(AppUser value, $Res Function(AppUser) _then) = _$AppUserCopyWithImpl;
@useResult
$Res call({
 String? id, String name, String email, String city, String? notes, String? password, DateTime? birthDate, String? profilePictureUrl, List<String>? nickNames, String? phone, bool isAdmin, int stars
});




}
/// @nodoc
class _$AppUserCopyWithImpl<$Res>
    implements $AppUserCopyWith<$Res> {
  _$AppUserCopyWithImpl(this._self, this._then);

  final AppUser _self;
  final $Res Function(AppUser) _then;

/// Create a copy of AppUser
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? name = null,Object? email = null,Object? city = null,Object? notes = freezed,Object? password = freezed,Object? birthDate = freezed,Object? profilePictureUrl = freezed,Object? nickNames = freezed,Object? phone = freezed,Object? isAdmin = null,Object? stars = null,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,password: freezed == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String?,birthDate: freezed == birthDate ? _self.birthDate : birthDate // ignore: cast_nullable_to_non_nullable
as DateTime?,profilePictureUrl: freezed == profilePictureUrl ? _self.profilePictureUrl : profilePictureUrl // ignore: cast_nullable_to_non_nullable
as String?,nickNames: freezed == nickNames ? _self.nickNames : nickNames // ignore: cast_nullable_to_non_nullable
as List<String>?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,isAdmin: null == isAdmin ? _self.isAdmin : isAdmin // ignore: cast_nullable_to_non_nullable
as bool,stars: null == stars ? _self.stars : stars // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [AppUser].
extension AppUserPatterns on AppUser {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppUser value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppUser() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppUser value)  $default,){
final _that = this;
switch (_that) {
case _AppUser():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppUser value)?  $default,){
final _that = this;
switch (_that) {
case _AppUser() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String name,  String email,  String city,  String? notes,  String? password,  DateTime? birthDate,  String? profilePictureUrl,  List<String>? nickNames,  String? phone,  bool isAdmin,  int stars)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppUser() when $default != null:
return $default(_that.id,_that.name,_that.email,_that.city,_that.notes,_that.password,_that.birthDate,_that.profilePictureUrl,_that.nickNames,_that.phone,_that.isAdmin,_that.stars);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String name,  String email,  String city,  String? notes,  String? password,  DateTime? birthDate,  String? profilePictureUrl,  List<String>? nickNames,  String? phone,  bool isAdmin,  int stars)  $default,) {final _that = this;
switch (_that) {
case _AppUser():
return $default(_that.id,_that.name,_that.email,_that.city,_that.notes,_that.password,_that.birthDate,_that.profilePictureUrl,_that.nickNames,_that.phone,_that.isAdmin,_that.stars);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String name,  String email,  String city,  String? notes,  String? password,  DateTime? birthDate,  String? profilePictureUrl,  List<String>? nickNames,  String? phone,  bool isAdmin,  int stars)?  $default,) {final _that = this;
switch (_that) {
case _AppUser() when $default != null:
return $default(_that.id,_that.name,_that.email,_that.city,_that.notes,_that.password,_that.birthDate,_that.profilePictureUrl,_that.nickNames,_that.phone,_that.isAdmin,_that.stars);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppUser implements AppUser {
   _AppUser({this.id, required this.name, required this.email, required this.city, this.notes, this.password, this.birthDate, this.profilePictureUrl, final  List<String>? nickNames, this.phone, this.isAdmin = false, this.stars = 0}): _nickNames = nickNames;
  factory _AppUser.fromJson(Map<String, dynamic> json) => _$AppUserFromJson(json);

@override final  String? id;
@override final  String name;
@override final  String email;
@override final  String city;
@override final  String? notes;
@override final  String? password;
@override final  DateTime? birthDate;
@override final  String? profilePictureUrl;
 final  List<String>? _nickNames;
@override List<String>? get nickNames {
  final value = _nickNames;
  if (value == null) return null;
  if (_nickNames is EqualUnmodifiableListView) return _nickNames;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  String? phone;
@override@JsonKey() final  bool isAdmin;
@override@JsonKey() final  int stars;

/// Create a copy of AppUser
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppUserCopyWith<_AppUser> get copyWith => __$AppUserCopyWithImpl<_AppUser>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppUserToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppUser&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.city, city) || other.city == city)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.password, password) || other.password == password)&&(identical(other.birthDate, birthDate) || other.birthDate == birthDate)&&(identical(other.profilePictureUrl, profilePictureUrl) || other.profilePictureUrl == profilePictureUrl)&&const DeepCollectionEquality().equals(other._nickNames, _nickNames)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.isAdmin, isAdmin) || other.isAdmin == isAdmin)&&(identical(other.stars, stars) || other.stars == stars));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,email,city,notes,password,birthDate,profilePictureUrl,const DeepCollectionEquality().hash(_nickNames),phone,isAdmin,stars);

@override
String toString() {
  return 'AppUser(id: $id, name: $name, email: $email, city: $city, notes: $notes, password: $password, birthDate: $birthDate, profilePictureUrl: $profilePictureUrl, nickNames: $nickNames, phone: $phone, isAdmin: $isAdmin, stars: $stars)';
}


}

/// @nodoc
abstract mixin class _$AppUserCopyWith<$Res> implements $AppUserCopyWith<$Res> {
  factory _$AppUserCopyWith(_AppUser value, $Res Function(_AppUser) _then) = __$AppUserCopyWithImpl;
@override @useResult
$Res call({
 String? id, String name, String email, String city, String? notes, String? password, DateTime? birthDate, String? profilePictureUrl, List<String>? nickNames, String? phone, bool isAdmin, int stars
});




}
/// @nodoc
class __$AppUserCopyWithImpl<$Res>
    implements _$AppUserCopyWith<$Res> {
  __$AppUserCopyWithImpl(this._self, this._then);

  final _AppUser _self;
  final $Res Function(_AppUser) _then;

/// Create a copy of AppUser
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? name = null,Object? email = null,Object? city = null,Object? notes = freezed,Object? password = freezed,Object? birthDate = freezed,Object? profilePictureUrl = freezed,Object? nickNames = freezed,Object? phone = freezed,Object? isAdmin = null,Object? stars = null,}) {
  return _then(_AppUser(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,password: freezed == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String?,birthDate: freezed == birthDate ? _self.birthDate : birthDate // ignore: cast_nullable_to_non_nullable
as DateTime?,profilePictureUrl: freezed == profilePictureUrl ? _self.profilePictureUrl : profilePictureUrl // ignore: cast_nullable_to_non_nullable
as String?,nickNames: freezed == nickNames ? _self._nickNames : nickNames // ignore: cast_nullable_to_non_nullable
as List<String>?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,isAdmin: null == isAdmin ? _self.isAdmin : isAdmin // ignore: cast_nullable_to_non_nullable
as bool,stars: null == stars ? _self.stars : stars // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
