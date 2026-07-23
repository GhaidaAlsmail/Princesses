import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:princesses/excel_file/services/excel_service.dart';
import 'package:qr_flutter/qr_flutter.dart'; // 1. استيراد مكتبة الـ QR

class EventImportScreen extends StatefulWidget {
  final String? eventId; // استقبال الـ ID الجديد هنا

  const EventImportScreen({super.key, this.eventId});
  @override
  State<EventImportScreen> createState() => _EventImportScreenState();
}

class _EventImportScreenState extends State<EventImportScreen> {
  final TextEditingController _eventNameController = TextEditingController();
  final ExcelService _excelService = ExcelService();

  List<Map<String, String>> _previewGuests =
      []; // قائمة حفظ المعازيم للمعاينة في الجدول
  bool _isLoading = false;

  /// دالة اختيار الملف ومعاينته في الجدول
  Future<void> _pickAndPreviewExcel() async {
    setState(() => _isLoading = true);
    try {
      final guests = await _excelService.readExcelFile();
      setState(() {
        _previewGuests = guests;
      });
      if (guests.isEmpty) {
        _showSnackBar("لم يتم استخراج أي أسماء من الملف.");
      } else {
        _showSnackBar("تم تحميل ${_previewGuests.length} ضيف للمعاينة بنجاح!");
      }
    } catch (e) {
      _showSnackBar(
        "خطأ في قراءة الملف: ${e.toString().replaceAll("Exception:", "")}",
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// دالة التأكيد والرفع السحابي مع توليد بيانات الباركود/QR
  Future<void> _confirmAndUpload() async {
    if (_eventNameController.text.trim().isEmpty) {
      _showSnackBar("الرجاء إدخال اسم الحفلة أولاً");
      return;
    }

    if (_previewGuests.isEmpty) {
      _showSnackBar("الرجاء اختيار ملف إكسل يحتوي على معازيم أولاً");
      return;
    }

    setState(() => _isLoading = true);
    debugPrint("🚀 بدأت عملية الرفع السحابي الذكية مع توليد الـ QR...");

    try {
      // 1. إنشاء مستند الحفلة الرئيسي
      DocumentReference eventRef = await FirebaseFirestore.instance
          .collection('events')
          .add({
            'eventName': _eventNameController.text.trim(),
            'createdAt': FieldValue.serverTimestamp(),
          })
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception(
                "فشل الاتصال بالسيرفر. تأكدي من جودة الإنترنت والـ VPN لديكِ.",
              );
            },
          );

      debugPrint("✅ تم إنشاء الحفلة بنجاح بـ ID: ${eventRef.id}");

      // 2. تجهيز الـ Batch للرفع
      WriteBatch batch = FirebaseFirestore.instance.batch();
      int count = 0;

      for (var guest in _previewGuests) {
        DocumentReference guestRef = FirebaseFirestore.instance
            .collection('guests')
            .doc();

        // توليد نص الباركود الفريد بناءً على الـ ID الخاص بالضيف لضمان عدم التكرار
        String uniqueBarcodeData = guestRef.id;

        batch.set(guestRef, {
          'guestId': guestRef.id,
          'eventId': eventRef.id,
          'name': guest['name'],
          'category': guest['category'],
          'seatNumber': guest['seatNumber'],
          'status': 'لم يحضر',
          'qrData': uniqueBarcodeData, // الحقل الجديد المخصص للباركود أو الـ QR
          'createdAt': FieldValue.serverTimestamp(),
        });

        count++;
        if (count == 499) {
          await batch.commit();
          batch = FirebaseFirestore.instance.batch();
          count = 0;
        }
      }

      if (count > 0) {
        await batch.commit().timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw Exception(
              "استغرق رفع الأسماء وقتاً طويلاً. تحقق من الاتصال.",
            );
          },
        );
      }
      debugPrint("📊 تم رفع جميع المعازيم بنجاح مع أكواد الباركود الخاصة بهم!");

      // 3. الانتقال الآمن لشاشة الماسح الذكي
      if (mounted) {
        _showSnackBar("🎉 تم إنشاء المناسبة وتوليد باركود لكل ضيف بنجاح!");

        setState(() => _isLoading = false);
        _eventNameController.clear();

        debugPrint("🔄 جاري الانتقال إلى المسار: /scanner/${eventRef.id}");

        try {
          context.push('/scanner/${eventRef.id}');
          setState(() => _previewGuests = []);
        } catch (routerError) {
          debugPrint("❌ خطأ في مسار الراوتر (Router Path Error): $routerError");
          _showSnackBar(
            "تم الرفع، لكن فشل الانتقال التلقائي. تأكد من إعدادات الـ Router.",
          );
        }
      }
    } catch (e) {
      debugPrint("❌ خطأ قاتل أثناء الرفع: $e");
      if (mounted) {
        _showSnackBar("حدث خطأ أثناء الرفع السحابي: $e");
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// 2. دالة إظهار بطاقة الـ QR للمعاينة الفردية لكل ضيف قبل الرفع
  void _openQrPreviewDialog(Map<String, String> guest) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        content: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome, color: Colors.pink.shade400, size: 30),
                const SizedBox(height: 10),
                Text(
                  guest['name'] ?? 'بدون اسم',
                  style: const TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.pink,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Chip(
                      label: Text("الفئة: ${guest['category'] ?? ''}"),
                      backgroundColor: Colors.pink.shade50,
                      labelStyle: TextStyle(color: Colors.pink.shade700),
                    ),
                    const SizedBox(width: 10),
                    Chip(
                      label: Text("مقعد: ${guest['seatNumber'] ?? ''}"),
                      backgroundColor: Colors.blue.shade50,
                      labelStyle: TextStyle(color: Colors.blue.shade700),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // توليد الـ QR للمعاينة (هنا نستخدم الاسم أو نص افتراضي مؤقت للمعاينة فقط)
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.pink.shade100, width: 2),
                  ),
                  child: QrImageView(
                    data: guest['name'] ?? 'preview_data',
                    version: QrVersions.auto,
                    size: 180.0,
                    gapless: false,
                    errorStateBuilder: (cxt, err) {
                      return const Center(child: Text("فشل توليد الرمز"));
                    },
                  ),
                ),
                const SizedBox(height: 15),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "إغلاق المعاينة",
                    style: TextStyle(color: Colors.pink),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "معاينة واستيراد المناسبات",
          style: TextStyle(color: Colors.white, fontFamily: 'Amiri'),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 204, 69, 145),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _eventNameController,
              decoration: const InputDecoration(
                labelText: "اسم الحفلة أو المناسبة",
                border: OutlineInputBorder(),
                prefixIcon: Icon(
                  Icons.celebration,
                  color: Color.fromARGB(255, 204, 69, 145),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _pickAndPreviewExcel,
                    icon: const Icon(Icons.file_open),
                    label: const Text("1. اختيار الملف"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 204, 69, 145),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading || _previewGuests.isEmpty
                        ? null
                        : _confirmAndUpload,
                    icon: const Icon(Icons.cloud_upload),
                    label: const Text("2. تأكيد ورفع"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 204, 69, 145),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _previewGuests.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.table_rows,
                            size: 60,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "لا توجد بيانات مستوردة حالياً.\nقم باختيار ملف إكسل للمعاينة.",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    )
                  : Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              headingRowColor: WidgetStateProperty.all(
                                Colors.pink.shade50,
                              ),
                              // 3. إضافة عمود رابع في العناوين للزر
                              columns: const [
                                DataColumn(
                                  label: Text(
                                    'الاسم',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'الفئة',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'المقعد',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'الباركود',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                              rows: _previewGuests.map((guest) {
                                return DataRow(
                                  cells: [
                                    DataCell(Text(guest['name'] ?? '')),
                                    DataCell(Text(guest['category'] ?? '')),
                                    DataCell(Text(guest['seatNumber'] ?? '')),
                                    // 4. خلية الزر التفاعلي لكل ضيف لإظهار الـ QR الخاص به
                                    DataCell(
                                      IconButton(
                                        icon: const Icon(
                                          Icons.qr_code_2,
                                          color: Color.fromARGB(
                                            255,
                                            204,
                                            69,
                                            145,
                                          ),
                                        ),
                                        onPressed: () =>
                                            _openQrPreviewDialog(guest),
                                        tooltip: "معاينة كود الضيف",
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
