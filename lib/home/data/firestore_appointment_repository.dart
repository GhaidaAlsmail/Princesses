// // ignore_for_file: avoid_print

// import 'package:flutter/material.dart';
// import 'package:princesses/home/data/appointment_repository.dart';
// import 'package:princesses/home/domain/appointment_model.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:riverpod_annotation/riverpod_annotation.dart';
// part 'firestore_appointment_repository.g.dart';

// @riverpod
// FirestoreAppoitmentRepository firestoreAppoitmentRepository(Ref ref) {
//   return FirestoreAppoitmentRepository();
// }

// class FirestoreAppoitmentRepository implements AppoitmentRepository {
//   FirestoreAppoitmentRepository() {
//     _firebase = FirebaseFirestore.instance;
//   }

//   late FirebaseFirestore _firebase;
//   final String collectionName = "appointments";
//   final Duration _networkTimeout = const Duration(seconds: 8);
//   @override
//   Future<void> addAppointment({required AppointmentModel app}) async {
//     try {
//       // 1. تحويل اسم المحافظة إلى حروف صغيرة لضمان مطابقة اسم المستند
//       final cityDoc = app.city.toLowerCase().trim();

//       // 🌟 2. نضع الكود هنا: لإنشاء/تحديث مستند المحافظة الأساسي حتى لا يظهر باللون الرمادي المائل
//       await FirebaseFirestore.instance.collection('cities').doc(cityDoc).set(
//         {'name': app.city},
//         SetOptions(merge: true), // تمزيج البيانات لتجنب مسح أي أسطر سابقة
//       );

//       // 3. إضافة الحجز داخل الفرع المخصص لهذه المحافظة
//       await FirebaseFirestore.instance
//           .collection('cities')
//           .doc(cityDoc)
//           .collection('appointments')
//           .doc(app.id)
//           .set(app.toJson());
//     } catch (e) {
//       debugPrint("خطأ في حفظ الحجز بالمحافظة: $e");
//       rethrow;
//     }
//   }

//   @override
//   Future<List<AppointmentModel>> getAppointments() async {
//     try {
//       final querySnapshot = await _firebase
//           .collection(collectionName)
//           .get()
//           .timeout(_networkTimeout);

//       return querySnapshot.docs.map((doc) {
//         final data = doc.data();
//         return AppointmentModel.fromJson({
//           'id': doc.id,
//           ...data,
//           'transportFees': (data['transportFees'] ?? 0.0).toDouble(),
//           'memoriesCornerPrice': (data['memoriesCornerPrice'] ?? 0.0)
//               .toDouble(),
//           'safesCornerPrice': (data['safesCornerPrice'] ?? 0.0).toDouble(),
//           'coversServicePrice': (data['coversServicePrice'] ?? 0.0).toDouble(),
//         });
//       }).toList();
//     } catch (e) {
//       print("خطأ أثناء جلب الحجوزات: $e");
//       rethrow;
//     }
//   }
//   // Future<void> addAppointment({required AppointmentModel app}) async {
//   //   try {
//   //     final docId = app.id;
//   //     final createdApp = app.copyWith(id: docId);

//   //     await _firebase
//   //         .collection(collectionName)
//   //         .doc(docId)
//   //         .set(createdApp.toJson())
//   //         .timeout(_networkTimeout);
//   //   } catch (e) {
//   //     rethrow;
//   //   }
//   // }

//   @override
//   Stream<List<AppointmentModel>> streamAppointments() {
//     return _firebase.collection(collectionName).snapshots().map((
//       QuerySnapshot querySnapshot,
//     ) {
//       return querySnapshot.docs.map((doc) {
//         final data = doc.data() as Map<String, dynamic>? ?? {};
//         return AppointmentModel.fromJson({
//           'id': doc.id,
//           'name': data['name'] ?? "",
//           'place': data['place'] ?? "",
//           'mediator': data['mediator'] ?? "",
//           'city': data['city'] ?? "",
//           'notes': data['notes'] ?? "",
//           'phone': data['phone'] ?? "",
//           'date': data['date'] ?? "",
//           'number': data['number'] ?? "",
//           'email': data['email'] ?? "",
//           'paid': data['paid'] ?? "",
//           'rest': data['rest'] ?? "",
//           // تضمين الحقول الجديدة لكي لا تضيع أثناء الـ Mapping
//           'hasMemoriesCorner': data['hasMemoriesCorner'] ?? false,
//           'hasSafesCorner': data['hasSafesCorner'] ?? false,
//           'hasCoversService': data['hasCoversService'] ?? false,
//           'isRural': data['isRural'] ?? false,
//           'ruralLocation': data['ruralLocation'] ?? "",
//           'transportFees': (data['transportFees'] ?? 0.0).toDouble(),

//           //  إضافة قيم الأسعار الفردية لكي لا تضيع أثناء الـ Mapping والـ Stream
//           'memoriesCornerPrice': (data['memoriesCornerPrice'] ?? 0.0)
//               .toDouble(),
//           'safesCornerPrice': (data['safesCornerPrice'] ?? 0.0).toDouble(),
//           'coversServicePrice': (data['coversServicePrice'] ?? 0.0).toDouble(),
//           // 'isRural': data['isRural'] ?? false,
//           // 'ruralLocation': data['ruralLocation'] ?? "",
//           // 'transportFees': (data['transportFees'] ?? 0.0).toDouble(),
//         });
//       }).toList();
//     });
//   }

//   Stream<AppointmentModel?> streamAppointment({required String id}) {
//     return _firebase.collection(collectionName).doc(id).snapshots().map((snap) {
//       final data = snap.data();
//       if (data == null) return null;
//       // دمج الـ ID مع البيانات لضمان عدم فقده
//       return AppointmentModel.fromJson(data..['id'] = snap.id);
//     });
//   }

//   @override
//   Stream<List<AppointmentModel>> streamAppointmentsByCity(String city) {
//     return _firebase
//         .collection(collectionName)
//         .where('city', isEqualTo: city)
//         .snapshots()
//         .map((QuerySnapshot querySnapshot) {
//           return querySnapshot.docs.map((doc) {
//             final data = doc.data() as Map<String, dynamic>? ?? {};
//             return AppointmentModel.fromJson({
//               'id': doc.id,
//               'name': data['name'] ?? "",
//               'place': data['place'] ?? "",
//               'mediator': data['mediator'] ?? "",
//               'city': data['city'] ?? "",
//               'notes': data['notes'] ?? "",
//               'phone': data['phone'] ?? "",
//               'date': data['date'] ?? "",
//               'number': data['number'] ?? "",
//               'email': data['email'] ?? "",
//               'paid': data['paid'] ?? "",
//               'rest': data['rest'] ?? "",
//               // تضمين الحقول الجديدة هنا أيضاً
//               'hasMemoriesCorner': data['hasMemoriesCorner'] ?? false,
//               'hasSafesCorner': data['hasSafesCorner'] ?? false,
//               // 'isRural': data['isRural'] ?? false,
//               // 'ruralLocation': data['ruralLocation'] ?? "",
//               // 'transportFees': (data['transportFees'] ?? 0.0).toDouble(),
//               'hasCoversService':
//                   data['hasCoversService'] ?? false, // 👈 تم إضافته
//               'isRural': data['isRural'] ?? false,
//               'ruralLocation': data['ruralLocation'] ?? "",
//               'transportFees': (data['transportFees'] ?? 0.0).toDouble(),

//               // 🌟 إضافة قيم الأسعار الفردية هنا أيضاً لحجوزات المدن المخصصة
//               'memoriesCornerPrice': (data['memoriesCornerPrice'] ?? 0.0)
//                   .toDouble(),
//               'safesCornerPrice': (data['safesCornerPrice'] ?? 0.0).toDouble(),
//               'coversServicePrice': (data['coversServicePrice'] ?? 0.0)
//                   .toDouble(),
//             });
//           }).toList();
//         });
//   }

//   @override
//   Future<void> deleteAppoitment({required String id}) async {
//     try {
//       final docRef = _firebase.collection(collectionName).doc(id);

//       final snapshot = await docRef.get();
//       if (!snapshot.exists) {
//         throw Exception("الموعد غير موجود أو تم حذفه مسبقًا.");
//       }

//       await docRef.delete();
//       print("تم حذف الموعد بنجاح (ID: $id)");
//     } catch (e) {
//       print("خطأ أثناء حذف الموعد: $e");
//       rethrow;
//     }
//   }

//   @override
//   Future<AppointmentModel?> readAppointment({required String id}) async {
//     try {
//       var appointment = await _firebase
//           .collection(collectionName)
//           .doc(id)
//           .get();

//       final data = appointment.data();
//       if (data != null) {
//         // تمرير الـ id للتأكد من بناء الموديل بشكل كامل وصحيح عند التعديل
//         return AppointmentModel.fromJson(data..['id'] = appointment.id);
//       } else {
//         return null;
//       }
//     } catch (e) {
//       rethrow;
//     }
//   }

//   @override
//   Future<void> updateAppoitment({required AppointmentModel app}) async {
//     try {
//       await _firebase
//           .collection(collectionName)
//           .doc(app.id)
//           .update(app.toJson());
//     } catch (e) {
//       rethrow;
//     }
//   }

//   Future<bool> isAppointmentExists(String date) async {
//     try {
//       final query = await _firebase
//           .collection(collectionName)
//           .where('date', isEqualTo: date)
//           .get();

//       return query.docs.isNotEmpty;
//     } catch (e) {
//       print("خطأ أثناء التحقق من وجود الحجز: $e");
//       return false;
//     }
//   }
// }
// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:princesses/home/data/appointment_repository.dart';
import 'package:princesses/home/domain/appointment_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'firestore_appointment_repository.g.dart';

// 🌟 جلب قائمة المحافظات من Firestore
final citiesStreamProvider = StreamProvider.autoDispose<List<String>>((ref) {
  return FirebaseFirestore.instance
      .collection('cities')
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList());
});

// 🌟 جلب الحجوزات الخاصة بمحافظة محددة من الـ Sub-collection
final cityAppointmentsProvider = StreamProvider.family
    .autoDispose<List<AppointmentModel>, String>((ref, cityName) {
      final cityDoc = cityName.toLowerCase().trim();
      return FirebaseFirestore.instance
          .collection('cities')
          .doc(cityDoc)
          .collection('appointments')
          .orderBy('date', descending: true)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => AppointmentModel.fromFirestore(doc))
                .toList(),
          );
    });

@riverpod
FirestoreAppoitmentRepository firestoreAppoitmentRepository(Ref ref) {
  return FirestoreAppoitmentRepository();
}

class FirestoreAppoitmentRepository implements AppoitmentRepository {
  FirestoreAppoitmentRepository() {
    _firebase = FirebaseFirestore.instance;
  }

  late FirebaseFirestore _firebase;
  final String collectionName = "appointments";
  final Duration _networkTimeout = const Duration(seconds: 8);

  @override
  Future<void> addAppointment({required AppointmentModel app}) async {
    try {
      final cityDoc = app.city.toLowerCase().trim();

      // 1. إنشاء/تحديث مستند المحافظة بحقل حقيقي لمنع الـ Virtual Document (Italic)
      await _firebase.collection('cities').doc(cityDoc).set({
        'name': app.city,
        'id': cityDoc,
      }, SetOptions(merge: true));

      // 2. إضافة الحجز داخل collection الحجوزات الخاصة بالمحافظة
      await _firebase
          .collection('cities')
          .doc(cityDoc)
          .collection('appointments')
          .doc(app.id)
          .set(app.toJson());
    } catch (e) {
      debugPrint("خطأ في حفظ الحجز بالمحافظة: $e");
      rethrow;
    }
  }

  @override
  Future<List<AppointmentModel>> getAppointments() async {
    try {
      final querySnapshot = await _firebase
          .collectionGroup(collectionName)
          .get()
          .timeout(_networkTimeout);

      return querySnapshot.docs.map((doc) {
        return AppointmentModel.fromFirestore(doc);
      }).toList();
    } catch (e) {
      print("خطأ أثناء جلب الحجوزات: $e");
      rethrow;
    }
  }

  @override
  Stream<List<AppointmentModel>> streamAppointments() {
    return _firebase.collectionGroup(collectionName).snapshots().map((
      snapshot,
    ) {
      return snapshot.docs
          .map((doc) => AppointmentModel.fromFirestore(doc))
          .toList();
    });
  }

  Stream<AppointmentModel?> streamAppointment({required String id}) {
    return _firebase.collectionGroup(collectionName).snapshots().map((snap) {
      final docs = snap.docs.where((doc) => doc.id == id);
      if (docs.isEmpty) return null;
      return AppointmentModel.fromFirestore(docs.first);
    });
  }

  @override
  Stream<List<AppointmentModel>> streamAppointmentsByCity(String city) {
    final cityDoc = city.toLowerCase().trim();
    return _firebase
        .collection('cities')
        .doc(cityDoc)
        .collection(collectionName)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => AppointmentModel.fromFirestore(doc))
              .toList();
        });
  }

  @override
  Future<void> deleteAppoitment({required String id}) async {
    try {
      // البحث عن المستند عبر جميع المحافظات لحذفه
      final query = await _firebase.collectionGroup(collectionName).get();
      final matchingDocs = query.docs.where((doc) => doc.id == id);

      if (matchingDocs.isEmpty) {
        throw Exception("الموعد غير موجود أو تم حذفه مسبقًا.");
      }

      await matchingDocs.first.reference.delete();
      print("تم حذف الموعد بنجاح (ID: $id)");
    } catch (e) {
      print("خطأ أثناء حذف الموعد: $e");
      rethrow;
    }
  }

  @override
  Future<AppointmentModel?> readAppointment({required String id}) async {
    try {
      final query = await _firebase.collectionGroup(collectionName).get();
      final matchingDocs = query.docs.where((doc) => doc.id == id);

      if (matchingDocs.isNotEmpty) {
        return AppointmentModel.fromFirestore(matchingDocs.first);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateAppoitment({required AppointmentModel app}) async {
    try {
      final cityDoc = app.city.toLowerCase().trim();
      await _firebase
          .collection('cities')
          .doc(cityDoc)
          .collection(collectionName)
          .doc(app.id)
          .update(app.toJson());
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> isAppointmentExists(String date) async {
    try {
      final query = await _firebase
          .collectionGroup(collectionName)
          .where('date', isEqualTo: date)
          .get();

      return query.docs.isNotEmpty;
    } catch (e) {
      print("خطأ أثناء التحقق من وجود الحجز: $e");
      return false;
    }
  }
}
