import 'package:princesses/home/domain/times_tamp_converter.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'appointment_model.freezed.dart';
part 'appointment_model.g.dart';

@freezed
abstract class AppointmentModel with _$AppointmentModel {
  const factory AppointmentModel({
    @Default("") String id,
    @Default("") String name,
    @Default("") String place,
    @Default("") String mediator,
    @Default("") String city,
    @Default("") String notes,
    @Default("") String phone,

    @TimestampConverter() required DateTime date,

    @Default("") String number,
    @Default("") String email,
    @Default("") String paid,
    @Default("") String rest,
    // الحقول الجديدة المضافة والمعدلة مع القيم الافتراضية
    @Default(false) bool hasMemoriesCorner, // ركن الذكريات (كفرات)
    @Default(false) bool hasSafesCorner, // ركن الأمانات
    @Default(false) bool isRural, // هل الموقع ريف؟
    @Default("") String ruralLocation, // اسم منطقة الريف (لحساب النقل)
    @Default(0.0) double transportFees,
  }) = _AppointmentModel;

  factory AppointmentModel.fromJson(Map<String, dynamic> json) =>
      _$AppointmentModelFromJson(json);
}
