// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'appointment_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AppointmentModel {

 String get id; String get name; String get place; String get mediator; String get city; String get notes; String get phone;@TimestampConverter() DateTime get date; String get number; String get email; String get paid; String get rest;// الحقول الجديدة المضافة والمعدلة مع القيم الافتراضية
 bool get hasMemoriesCorner;// ركن الذكريات (كفرات)
 bool get hasSafesCorner;// ركن الأمانات
 bool get isRural;// هل الموقع ريف؟
 String get ruralLocation;// اسم منطقة الريف (لحساب النقل)
 double get transportFees;
/// Create a copy of AppointmentModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppointmentModelCopyWith<AppointmentModel> get copyWith => _$AppointmentModelCopyWithImpl<AppointmentModel>(this as AppointmentModel, _$identity);

  /// Serializes this AppointmentModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppointmentModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.place, place) || other.place == place)&&(identical(other.mediator, mediator) || other.mediator == mediator)&&(identical(other.city, city) || other.city == city)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.date, date) || other.date == date)&&(identical(other.number, number) || other.number == number)&&(identical(other.email, email) || other.email == email)&&(identical(other.paid, paid) || other.paid == paid)&&(identical(other.rest, rest) || other.rest == rest)&&(identical(other.hasMemoriesCorner, hasMemoriesCorner) || other.hasMemoriesCorner == hasMemoriesCorner)&&(identical(other.hasSafesCorner, hasSafesCorner) || other.hasSafesCorner == hasSafesCorner)&&(identical(other.isRural, isRural) || other.isRural == isRural)&&(identical(other.ruralLocation, ruralLocation) || other.ruralLocation == ruralLocation)&&(identical(other.transportFees, transportFees) || other.transportFees == transportFees));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,place,mediator,city,notes,phone,date,number,email,paid,rest,hasMemoriesCorner,hasSafesCorner,isRural,ruralLocation,transportFees);

@override
String toString() {
  return 'AppointmentModel(id: $id, name: $name, place: $place, mediator: $mediator, city: $city, notes: $notes, phone: $phone, date: $date, number: $number, email: $email, paid: $paid, rest: $rest, hasMemoriesCorner: $hasMemoriesCorner, hasSafesCorner: $hasSafesCorner, isRural: $isRural, ruralLocation: $ruralLocation, transportFees: $transportFees)';
}


}

/// @nodoc
abstract mixin class $AppointmentModelCopyWith<$Res>  {
  factory $AppointmentModelCopyWith(AppointmentModel value, $Res Function(AppointmentModel) _then) = _$AppointmentModelCopyWithImpl;
@useResult
$Res call({
 String id, String name, String place, String mediator, String city, String notes, String phone,@TimestampConverter() DateTime date, String number, String email, String paid, String rest, bool hasMemoriesCorner, bool hasSafesCorner, bool isRural, String ruralLocation, double transportFees
});




}
/// @nodoc
class _$AppointmentModelCopyWithImpl<$Res>
    implements $AppointmentModelCopyWith<$Res> {
  _$AppointmentModelCopyWithImpl(this._self, this._then);

  final AppointmentModel _self;
  final $Res Function(AppointmentModel) _then;

/// Create a copy of AppointmentModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? place = null,Object? mediator = null,Object? city = null,Object? notes = null,Object? phone = null,Object? date = null,Object? number = null,Object? email = null,Object? paid = null,Object? rest = null,Object? hasMemoriesCorner = null,Object? hasSafesCorner = null,Object? isRural = null,Object? ruralLocation = null,Object? transportFees = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,place: null == place ? _self.place : place // ignore: cast_nullable_to_non_nullable
as String,mediator: null == mediator ? _self.mediator : mediator // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,paid: null == paid ? _self.paid : paid // ignore: cast_nullable_to_non_nullable
as String,rest: null == rest ? _self.rest : rest // ignore: cast_nullable_to_non_nullable
as String,hasMemoriesCorner: null == hasMemoriesCorner ? _self.hasMemoriesCorner : hasMemoriesCorner // ignore: cast_nullable_to_non_nullable
as bool,hasSafesCorner: null == hasSafesCorner ? _self.hasSafesCorner : hasSafesCorner // ignore: cast_nullable_to_non_nullable
as bool,isRural: null == isRural ? _self.isRural : isRural // ignore: cast_nullable_to_non_nullable
as bool,ruralLocation: null == ruralLocation ? _self.ruralLocation : ruralLocation // ignore: cast_nullable_to_non_nullable
as String,transportFees: null == transportFees ? _self.transportFees : transportFees // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [AppointmentModel].
extension AppointmentModelPatterns on AppointmentModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppointmentModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppointmentModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppointmentModel value)  $default,){
final _that = this;
switch (_that) {
case _AppointmentModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppointmentModel value)?  $default,){
final _that = this;
switch (_that) {
case _AppointmentModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String place,  String mediator,  String city,  String notes,  String phone, @TimestampConverter()  DateTime date,  String number,  String email,  String paid,  String rest,  bool hasMemoriesCorner,  bool hasSafesCorner,  bool isRural,  String ruralLocation,  double transportFees)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppointmentModel() when $default != null:
return $default(_that.id,_that.name,_that.place,_that.mediator,_that.city,_that.notes,_that.phone,_that.date,_that.number,_that.email,_that.paid,_that.rest,_that.hasMemoriesCorner,_that.hasSafesCorner,_that.isRural,_that.ruralLocation,_that.transportFees);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String place,  String mediator,  String city,  String notes,  String phone, @TimestampConverter()  DateTime date,  String number,  String email,  String paid,  String rest,  bool hasMemoriesCorner,  bool hasSafesCorner,  bool isRural,  String ruralLocation,  double transportFees)  $default,) {final _that = this;
switch (_that) {
case _AppointmentModel():
return $default(_that.id,_that.name,_that.place,_that.mediator,_that.city,_that.notes,_that.phone,_that.date,_that.number,_that.email,_that.paid,_that.rest,_that.hasMemoriesCorner,_that.hasSafesCorner,_that.isRural,_that.ruralLocation,_that.transportFees);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String place,  String mediator,  String city,  String notes,  String phone, @TimestampConverter()  DateTime date,  String number,  String email,  String paid,  String rest,  bool hasMemoriesCorner,  bool hasSafesCorner,  bool isRural,  String ruralLocation,  double transportFees)?  $default,) {final _that = this;
switch (_that) {
case _AppointmentModel() when $default != null:
return $default(_that.id,_that.name,_that.place,_that.mediator,_that.city,_that.notes,_that.phone,_that.date,_that.number,_that.email,_that.paid,_that.rest,_that.hasMemoriesCorner,_that.hasSafesCorner,_that.isRural,_that.ruralLocation,_that.transportFees);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppointmentModel implements AppointmentModel {
  const _AppointmentModel({this.id = "", this.name = "", this.place = "", this.mediator = "", this.city = "", this.notes = "", this.phone = "", @TimestampConverter() required this.date, this.number = "", this.email = "", this.paid = "", this.rest = "", this.hasMemoriesCorner = false, this.hasSafesCorner = false, this.isRural = false, this.ruralLocation = "", this.transportFees = 0.0});
  factory _AppointmentModel.fromJson(Map<String, dynamic> json) => _$AppointmentModelFromJson(json);

@override@JsonKey() final  String id;
@override@JsonKey() final  String name;
@override@JsonKey() final  String place;
@override@JsonKey() final  String mediator;
@override@JsonKey() final  String city;
@override@JsonKey() final  String notes;
@override@JsonKey() final  String phone;
@override@TimestampConverter() final  DateTime date;
@override@JsonKey() final  String number;
@override@JsonKey() final  String email;
@override@JsonKey() final  String paid;
@override@JsonKey() final  String rest;
// الحقول الجديدة المضافة والمعدلة مع القيم الافتراضية
@override@JsonKey() final  bool hasMemoriesCorner;
// ركن الذكريات (كفرات)
@override@JsonKey() final  bool hasSafesCorner;
// ركن الأمانات
@override@JsonKey() final  bool isRural;
// هل الموقع ريف؟
@override@JsonKey() final  String ruralLocation;
// اسم منطقة الريف (لحساب النقل)
@override@JsonKey() final  double transportFees;

/// Create a copy of AppointmentModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppointmentModelCopyWith<_AppointmentModel> get copyWith => __$AppointmentModelCopyWithImpl<_AppointmentModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppointmentModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppointmentModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.place, place) || other.place == place)&&(identical(other.mediator, mediator) || other.mediator == mediator)&&(identical(other.city, city) || other.city == city)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.date, date) || other.date == date)&&(identical(other.number, number) || other.number == number)&&(identical(other.email, email) || other.email == email)&&(identical(other.paid, paid) || other.paid == paid)&&(identical(other.rest, rest) || other.rest == rest)&&(identical(other.hasMemoriesCorner, hasMemoriesCorner) || other.hasMemoriesCorner == hasMemoriesCorner)&&(identical(other.hasSafesCorner, hasSafesCorner) || other.hasSafesCorner == hasSafesCorner)&&(identical(other.isRural, isRural) || other.isRural == isRural)&&(identical(other.ruralLocation, ruralLocation) || other.ruralLocation == ruralLocation)&&(identical(other.transportFees, transportFees) || other.transportFees == transportFees));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,place,mediator,city,notes,phone,date,number,email,paid,rest,hasMemoriesCorner,hasSafesCorner,isRural,ruralLocation,transportFees);

@override
String toString() {
  return 'AppointmentModel(id: $id, name: $name, place: $place, mediator: $mediator, city: $city, notes: $notes, phone: $phone, date: $date, number: $number, email: $email, paid: $paid, rest: $rest, hasMemoriesCorner: $hasMemoriesCorner, hasSafesCorner: $hasSafesCorner, isRural: $isRural, ruralLocation: $ruralLocation, transportFees: $transportFees)';
}


}

/// @nodoc
abstract mixin class _$AppointmentModelCopyWith<$Res> implements $AppointmentModelCopyWith<$Res> {
  factory _$AppointmentModelCopyWith(_AppointmentModel value, $Res Function(_AppointmentModel) _then) = __$AppointmentModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String place, String mediator, String city, String notes, String phone,@TimestampConverter() DateTime date, String number, String email, String paid, String rest, bool hasMemoriesCorner, bool hasSafesCorner, bool isRural, String ruralLocation, double transportFees
});




}
/// @nodoc
class __$AppointmentModelCopyWithImpl<$Res>
    implements _$AppointmentModelCopyWith<$Res> {
  __$AppointmentModelCopyWithImpl(this._self, this._then);

  final _AppointmentModel _self;
  final $Res Function(_AppointmentModel) _then;

/// Create a copy of AppointmentModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? place = null,Object? mediator = null,Object? city = null,Object? notes = null,Object? phone = null,Object? date = null,Object? number = null,Object? email = null,Object? paid = null,Object? rest = null,Object? hasMemoriesCorner = null,Object? hasSafesCorner = null,Object? isRural = null,Object? ruralLocation = null,Object? transportFees = null,}) {
  return _then(_AppointmentModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,place: null == place ? _self.place : place // ignore: cast_nullable_to_non_nullable
as String,mediator: null == mediator ? _self.mediator : mediator // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,paid: null == paid ? _self.paid : paid // ignore: cast_nullable_to_non_nullable
as String,rest: null == rest ? _self.rest : rest // ignore: cast_nullable_to_non_nullable
as String,hasMemoriesCorner: null == hasMemoriesCorner ? _self.hasMemoriesCorner : hasMemoriesCorner // ignore: cast_nullable_to_non_nullable
as bool,hasSafesCorner: null == hasSafesCorner ? _self.hasSafesCorner : hasSafesCorner // ignore: cast_nullable_to_non_nullable
as bool,isRural: null == isRural ? _self.isRural : isRural // ignore: cast_nullable_to_non_nullable
as bool,ruralLocation: null == ruralLocation ? _self.ruralLocation : ruralLocation // ignore: cast_nullable_to_non_nullable
as String,transportFees: null == transportFees ? _self.transportFees : transportFees // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
