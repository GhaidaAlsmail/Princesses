import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart'; // استبدال file_picker بـ image_picker
import 'package:flutter/foundation.dart';

class ExcelService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  /// دالة لاختيار ملف الإكسل باستخدام الـ Picker المتوافق تلقائياً مع أندرويد
  Future<void> importExcelAndUpload({required String eventId}) async {
    try {
      // 1. استخدام متصفح الوسائط الافتراضي للأندرويد لاختيار الملف بأمان
      final XFile? pickedFile = await _picker.pickMedia();

      if (pickedFile == null) {
        debugPrint("لم يتم اختيار أي ملف");
        return;
      }

      // التحقق من أن الملف المختار هو ملف إكسل فعلاً
      // التحقق الصارم: نقبل فقط .xlsx لأن المكتبة لا تدعم الصيغ القديمة
      if (!pickedFile.name.toLowerCase().endsWith('.xlsx')) {
        throw Exception(
          "الرجاء اختيار ملف بصيغة Excel حديثة تنتهي بـ (.xlsx) فقط. الصيغ القديمة .xls غير مدعومة.",
        );
      }

      // 2. قراءة الملف من المسار وتحويله إلى بايتات
      var bytes = await pickedFile.readAsBytes();
      var excel = Excel.decodeBytes(bytes);

      // 3. قراءة أول ورقة عمل (Sheet) في ملف الإكسل
      String firstSheet = excel.tables.keys.first;
      var table = excel.tables[firstSheet];

      if (table == null || table.maxRows <= 1) {
        throw Exception("ملف الإكسل فارغ أو غير صالح");
      }

      WriteBatch batch = _firestore.batch();
      int count = 0;

      // 4. المرور على الأسطر (بدءاً من السطر الثاني لتخطي العناوين)
      for (int i = 1; i < table.maxRows; i++) {
        var row = table.rows[i];

        if (row[0]?.value == null) continue;

        String guestName = row[0]!.value.toString().trim();
        String category = row[1]?.value?.toString().trim() ?? "عادي";
        String seatNumber = row[2]?.value?.toString().trim() ?? "غير محدد";

        DocumentReference guestRef = _firestore.collection('guests').doc();

        Map<String, dynamic> guestData = {
          'guestId': guestRef.id,
          'eventId': eventId,
          'name': guestName,
          'category': category, // VIP - وسط - عادي
          'seatNumber': seatNumber,
          'status': 'لم يحضر',
          'createdAt': FieldValue.serverTimestamp(),
        };

        batch.set(guestRef, guestData);
        count++;

        if (count == 499) {
          await batch.commit();
          batch = _firestore.batch();
          count = 0;
        }
      }

      if (count > 0) {
        await batch.commit();
      }

      debugPrint("تم رفع كافة الأسماء بنجاح التام عبر نظام الـ Picker الآمن!");
    } catch (e) {
      debugPrint("خطأ أثناء معالجة الملف: $e");
      rethrow;
    }
  }

  Future<List<Map<String, String>>> readExcelFile() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );

      if (result == null || result.files.single.path == null) {
        return [];
      }

      Uint8List bytes;
      if (kIsWeb) {
        bytes = result.files.single.bytes!;
      } else {
        bytes = await File(result.files.single.path!).readAsBytes();
      }

      var excel = Excel.decodeBytes(bytes);
      String firstSheet = excel.tables.keys.first;
      var table = excel.tables[firstSheet];

      if (table == null || table.maxRows <= 1) {
        throw Exception("ملف الإكسل فارغ أو غير صالح");
      }

      List<Map<String, String>> extractedGuests = [];

      // قراءة الأسطر (بدءاً من السطر الثاني i = 1)
      for (int i = 1; i < table.maxRows; i++) {
        var row = table.rows[i];
        if (row[0]?.value == null) continue;

        extractedGuests.add({
          'name': row[0]!.value.toString().trim(),
          'category': row[1]?.value?.toString().trim() ?? "عادي",
          'seatNumber': row[2]?.value?.toString().trim() ?? "غير محدد",
        });
      }

      return extractedGuests;
    } catch (e) {
      debugPrint("خطأ أثناء قراءة ملف الإكسل: $e");
      rethrow;
    }
  }
}
// import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:excel/excel.dart';
// import 'package:file_picker/file_picker.dart'; // العودة للمكتبة المخصصة بعد حل مشكلة الشبكة
// import 'package:flutter/foundation.dart';

// class ExcelService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   Future<void> importExcelAndUpload({required String eventId}) async {
//     try {
//       // 1. اختيار ملف إكسل حقيقي مع قفل الفلتر على صيغ الإكسل فقط
//       // 1. اختيار ملف إكسل حقيقي باستخدام الاستدعاء الحديث .instance
//       FilePickerResult? result = await FilePicker.pickFiles(
//         type: FileType.custom,
//         allowedExtensions: [
//           'xlsx',
//         ], // حصر الاختيار في .xlsx فقط لمنع خطأ الصيغة
//       );

//       if (result == null || result.files.single.path == null) {
//         debugPrint("لم يتم اختيار أي ملف");
//         return;
//       }

//       // 2. قراءة الملف كـ Bytes مباشرة لضمان عدم تغير الصيغة
//       Uint8List bytes;
//       if (kIsWeb) {
//         bytes = result.files.single.bytes!;
//       } else {
//         File file = File(result.files.single.path!);
//         bytes = await file.readAsBytes();
//       }

//       // 3. فك تشفير ملف الإكسل
//       var excel = Excel.decodeBytes(bytes);

//       // 4. قراءة أول ورقة عمل (Sheet)
//       String firstSheet = excel.tables.keys.first;
//       var table = excel.tables[firstSheet];

//       if (table == null || table.maxRows <= 1) {
//         throw Exception("ملف الإكسل فارغ أو غير صالح");
//       }

//       WriteBatch batch = _firestore.batch();
//       int count = 0;

//       // 5. المرور على الأسطر ورفعها للفايربيز
//       for (int i = 1; i < table.maxRows; i++) {
//         var row = table.rows[i];

//         if (row[0]?.value == null) continue;

//         String guestName = row[0]!.value.toString().trim();
//         String category = row[1]?.value?.toString().trim() ?? "عادي";
//         String seatNumber = row[2]?.value?.toString().trim() ?? "غير محدد";

//         DocumentReference guestRef = _firestore.collection('guests').doc();

//         Map<String, dynamic> guestData = {
//           'guestId': guestRef.id,
//           'eventId': eventId,
//           'name': guestName,
//           'category': category,
//           'seatNumber': seatNumber,
//           'status': 'لم يحضر',
//           'createdAt': FieldValue.serverTimestamp(),
//         };

//         batch.set(guestRef, guestData);
//         count++;

//         if (count == 499) {
//           await batch.commit();
//           batch = _firestore.batch();
//           count = 0;
//         }
//       }

//       if (count > 0) {
//         await batch.commit();
//       }

//       debugPrint("تم الرفع بنجاح تام وبصيغة مدعومة!");
//     } catch (e) {
//       debugPrint("خطأ أثناء معالجة الملف: $e");
//       rethrow;
//     }
//   }
// }
