// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:freezed_annotation/freezed_annotation.dart';

// class TimestampConverter implements JsonConverter<DateTime, Object?> {
//   const TimestampConverter();

//   @override
//   DateTime fromJson(Object? json) {
//     if (json == null) return DateTime.now();

//     // في حال كانت القيمة Timestamp من Firestore
//     if (json is Timestamp) {
//       return json.toDate();
//     }

//     // في حال كانت String محفوظة مثلاً "2025-11-13"
//     if (json is String) {
//       return DateTime.tryParse(json) ?? DateTime.now();
//     }

//     throw ArgumentError('Invalid date format: $json');
//   }

//   @override
//   Object toJson(DateTime date) => Timestamp.fromDate(date);
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

class TimestampConverter implements JsonConverter<DateTime, Object?> {
  const TimestampConverter();

  @override
  DateTime fromJson(Object? json) {
    if (json == null) return DateTime.now().toLocal();

    // Timestamp من Firestore
    if (json is Timestamp) {
      return json.toDate().toLocal(); // <-- مهم جدًا
    }

    // String مثل "2025-11-13"
    if (json is String) {
      return DateTime.tryParse(json)?.toLocal() ?? DateTime.now().toLocal();
    }

    throw ArgumentError('Invalid date format: $json');
  }

  @override
  Object toJson(DateTime date) => Timestamp.fromDate(date.toUtc());
}
