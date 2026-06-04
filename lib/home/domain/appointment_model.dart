// import 'package:princesses/home/domain/times_tamp_converter.dart';

// class AppointmentModel {
//   final String id;
//   final String name;
//   final String place;
//   final String mediator;
//   final String city;
//   final String notes;
//   final String phone;
//   final DateTime date;
//   final String number;
//   final String email;
//   final String paid;
//   final String rest;
//   final bool hasMemoriesCorner;
//   final bool hasCoversService;
//   final bool hasSafesCorner;
//   final bool isRural;
//   final String ruralLocation;
//   final double transportFees;

//   // 1. Constructor الموديل مع تحديد القيم الافتراضية بدلاً من @Default
//   const AppointmentModel({
//     this.id = "",
//     this.name = "",
//     this.place = "",
//     this.mediator = "",
//     this.city = "",
//     this.notes = "",
//     this.phone = "",
//     required this.date,
//     this.number = "",
//     this.email = "",
//     this.paid = "",
//     this.rest = "",
//     this.hasMemoriesCorner = false,
//     this.hasCoversService = false,
//     this.hasSafesCorner = false,
//     this.isRural = false,
//     this.ruralLocation = "",
//     this.transportFees = 0.0,
//   });

//   // 2. دالة التحويل من Map/JSON إلى Object (تستخدم الـ TimestampConverter الخاص بكِ)
//   factory AppointmentModel.fromJson(Map<String, dynamic> json) {
//     const timestampConverter = TimestampConverter();
//     return AppointmentModel(
//       id: json['id'] as String? ?? "",
//       name: json['name'] as String? ?? "",
//       place: json['place'] as String? ?? "",
//       mediator: json['mediator'] as String? ?? "",
//       city: json['city'] as String? ?? "",
//       notes: json['notes'] as String? ?? "",
//       phone: json['phone'] as String? ?? "",
//       date: timestampConverter.fromJson(json['date']),
//       number: json['number'] as String? ?? "",
//       email: json['email'] as String? ?? "",
//       paid: json['paid'] as String? ?? "",
//       rest: json['rest'] as String? ?? "",
//       hasMemoriesCorner: json['hasMemoriesCorner'] as bool? ?? false,
//       hasCoversService: json['hasCoversService'] as bool? ?? false,
//       hasSafesCorner: json['hasSafesCorner'] as bool? ?? false,
//       isRural: json['isRural'] as bool? ?? false,
//       ruralLocation: json['ruralLocation'] as String? ?? "",
//       transportFees: (json['transportFees'] as num?)?.toDouble() ?? 0.0,
//     );
//   }

//   // 3. دالة التحويل من Object إلى Map/JSON لحفظه في Firestore
//   Map<String, dynamic> toJson() {
//     const timestampConverter = TimestampConverter();
//     return {
//       'id': id,
//       'name': name,
//       'place': place,
//       'mediator': mediator,
//       'city': city,
//       'notes': notes,
//       'phone': phone,
//       'date': timestampConverter.toJson(date),
//       'number': number,
//       'email': email,
//       'paid': paid,
//       'rest': rest,
//       'hasMemoriesCorner': hasMemoriesCorner,
//       'hasCoversService': hasCoversService,
//       'hasSafesCorner': hasSafesCorner,
//       'isRural': isRural,
//       'ruralLocation': ruralLocation,
//       'transportFees': transportFees,
//     };
//   }

//   // 4. دالة copyWith لتعديل حقول معينة داخل الـ Object دون إعادة إنشائه من الصفر
//   AppointmentModel copyWith({
//     String? id,
//     String? name,
//     String? place,
//     String? mediator,
//     String? city,
//     String? notes,
//     String? phone,
//     DateTime? date,
//     String? number,
//     String? email,
//     String? paid,
//     String? rest,
//     bool? hasMemoriesCorner,
//     bool? hasCoversService,
//     bool? hasSafesCorner,
//     bool? isRural,
//     String? ruralLocation,
//     double? transportFees,
//   }) {
//     return AppointmentModel(
//       id: id ?? this.id,
//       name: name ?? this.name,
//       place: place ?? this.place,
//       mediator: mediator ?? this.mediator,
//       city: city ?? this.city,
//       notes: notes ?? this.notes,
//       phone: phone ?? this.phone,
//       date: date ?? this.date,
//       number: number ?? this.number,
//       email: email ?? this.email,
//       paid: paid ?? this.paid,
//       rest: rest ?? this.rest,
//       hasMemoriesCorner: hasMemoriesCorner ?? this.hasMemoriesCorner,
//       hasCoversService: hasCoversService ?? this.hasCoversService,
//       hasSafesCorner: hasSafesCorner ?? this.hasSafesCorner,
//       isRural: isRural ?? this.isRural,
//       ruralLocation: ruralLocation ?? this.ruralLocation,
//       transportFees: transportFees ?? this.transportFees,
//     );
//   }
// }
import 'package:princesses/home/domain/times_tamp_converter.dart';

class AppointmentModel {
  final String id;
  final String name;
  final String place;
  final String mediator;
  final String city;
  final String notes;
  final String phone;
  final DateTime date;
  final String number;
  final String email;
  final String paid;
  final String rest;
  final bool hasMemoriesCorner;
  final bool hasCoversService;
  final bool hasSafesCorner;
  final bool isRural;
  final String ruralLocation;
  final double transportFees;

  // 🌟 الحقول الجديدة المضافة لحفظ أسعار الأركان وقت الحجز
  final double memoriesCornerPrice;
  final double safesCornerPrice;
  final double coversServicePrice;

  // 1. Constructor الموديل مع تحديد القيم الافتراضية
  const AppointmentModel({
    this.id = "",
    this.name = "",
    this.place = "",
    this.mediator = "",
    this.city = "",
    this.notes = "",
    this.phone = "",
    required this.date,
    this.number = "",
    this.email = "",
    this.paid = "",
    this.rest = "",
    this.hasMemoriesCorner = false,
    this.hasCoversService = false,
    this.hasSafesCorner = false,
    this.isRural = false,
    this.ruralLocation = "",
    this.transportFees = 0.0,
    this.memoriesCornerPrice = 0.0, // 👈
    this.safesCornerPrice = 0.0, // 👈
    this.coversServicePrice = 0.0, // 👈
  });

  // 2. دالة التحويل من Map/JSON إلى Object
  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    const timestampConverter = TimestampConverter();
    return AppointmentModel(
      id: json['id'] as String? ?? "",
      name: json['name'] as String? ?? "",
      place: json['place'] as String? ?? "",
      mediator: json['mediator'] as String? ?? "",
      city: json['city'] as String? ?? "",
      notes: json['notes'] as String? ?? "",
      phone: json['phone'] as String? ?? "",
      date: timestampConverter.fromJson(json['date']),
      number: json['number'] as String? ?? "",
      email: json['email'] as String? ?? "",
      paid: json['paid'] as String? ?? "",
      rest: json['rest'] as String? ?? "",
      hasMemoriesCorner: json['hasMemoriesCorner'] as bool? ?? false,
      hasCoversService: json['hasCoversService'] as bool? ?? false,
      hasSafesCorner: json['hasSafesCorner'] as bool? ?? false,
      isRural: json['isRural'] as bool? ?? false,
      ruralLocation: json['ruralLocation'] as String? ?? "",
      transportFees: (json['transportFees'] as num?)?.toDouble() ?? 0.0,
      memoriesCornerPrice:
          (json['memoriesCornerPrice'] as num?)?.toDouble() ?? 0.0, // 👈
      safesCornerPrice:
          (json['safesCornerPrice'] as num?)?.toDouble() ?? 0.0, // 👈
      coversServicePrice:
          (json['coversServicePrice'] as num?)?.toDouble() ?? 0.0, // 👈
    );
  }

  // 3. دالة التحويل من Object إلى Map/JSON لحفظه في Firestore
  Map<String, dynamic> toJson() {
    const timestampConverter = TimestampConverter();
    return {
      'id': id,
      'name': name,
      'place': place,
      'mediator': mediator,
      'city': city,
      'notes': notes,
      'phone': phone,
      'date': timestampConverter.toJson(date),
      'number': number,
      'email': email,
      'paid': paid,
      'rest': rest,
      'hasMemoriesCorner': hasMemoriesCorner,
      'hasCoversService': hasCoversService,
      'hasSafesCorner': hasSafesCorner,
      'isRural': isRural,
      'ruralLocation': ruralLocation,
      'transportFees': transportFees,
      'memoriesCornerPrice': memoriesCornerPrice, // 👈
      'safesCornerPrice': safesCornerPrice, // 👈
      'coversServicePrice': coversServicePrice, // 👈
    };
  }

  // 4. دالة copyWith لتعديل حقول معينة
  AppointmentModel copyWith({
    String? id,
    String? name,
    String? place,
    String? mediator,
    String? city,
    String? notes,
    String? phone,
    DateTime? date,
    String? number,
    String? email,
    String? paid,
    String? rest,
    bool? hasMemoriesCorner,
    bool? hasCoversService,
    bool? hasSafesCorner,
    bool? isRural,
    String? ruralLocation,
    double? transportFees,
    double? memoriesCornerPrice, // 👈
    double? safesCornerPrice, // 👈
    double? coversServicePrice, // 👈
  }) {
    return AppointmentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      place: place ?? this.place,
      mediator: mediator ?? this.mediator,
      city: city ?? this.city,
      notes: notes ?? this.notes,
      phone: phone ?? this.phone,
      date: date ?? this.date,
      number: number ?? this.number,
      email: email ?? this.email,
      paid: paid ?? this.paid,
      rest: rest ?? this.rest,
      hasMemoriesCorner: hasMemoriesCorner ?? this.hasMemoriesCorner,
      hasCoversService: hasCoversService ?? this.hasCoversService,
      hasSafesCorner: hasSafesCorner ?? this.hasSafesCorner,
      isRural: isRural ?? this.isRural,
      ruralLocation: ruralLocation ?? this.ruralLocation,
      transportFees: transportFees ?? this.transportFees,
      memoriesCornerPrice: memoriesCornerPrice ?? this.memoriesCornerPrice, //
      safesCornerPrice: safesCornerPrice ?? this.safesCornerPrice, //
      coversServicePrice: coversServicePrice ?? this.coversServicePrice, //
    );
  }
}
