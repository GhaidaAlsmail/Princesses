// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appointment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppointmentModel _$AppointmentModelFromJson(Map<String, dynamic> json) =>
    _AppointmentModel(
      id: json['id'] as String? ?? "",
      name: json['name'] as String? ?? "",
      place: json['place'] as String? ?? "",
      mediator: json['mediator'] as String? ?? "",
      city: json['city'] as String? ?? "",
      notes: json['notes'] as String? ?? "",
      phone: json['phone'] as String? ?? "",
      date: const TimestampConverter().fromJson(json['date']),
      number: json['number'] as String? ?? "",
      email: json['email'] as String? ?? "",
      paid: json['paid'] as String? ?? "",
      rest: json['rest'] as String? ?? "",
      hasMemoriesCorner: json['hasMemoriesCorner'] as bool? ?? false,
      hasSafesCorner: json['hasSafesCorner'] as bool? ?? false,
      isRural: json['isRural'] as bool? ?? false,
      ruralLocation: json['ruralLocation'] as String? ?? "",
      transportFees: (json['transportFees'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$AppointmentModelToJson(_AppointmentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'place': instance.place,
      'mediator': instance.mediator,
      'city': instance.city,
      'notes': instance.notes,
      'phone': instance.phone,
      'date': const TimestampConverter().toJson(instance.date),
      'number': instance.number,
      'email': instance.email,
      'paid': instance.paid,
      'rest': instance.rest,
      'hasMemoriesCorner': instance.hasMemoriesCorner,
      'hasSafesCorner': instance.hasSafesCorner,
      'isRural': instance.isRural,
      'ruralLocation': instance.ruralLocation,
      'transportFees': instance.transportFees,
    };
