// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class AttendeeListScreen extends StatelessWidget {
  final String eventId;

  const AttendeeListScreen({super.key, required this.eventId});

  // 🖨️ دالة لتوليد ملف الـ PDF وطباعة البطاقات بشكل شبكي قابل للقص
  Future<void> _printAttendanceCards(
    List<QueryDocumentSnapshot> attendees,
  ) async {
    final pdf = pw.Document();

    // تحميل الخطوط لضمان دعم اللغة العربية والتشكيل داخل الـ PDF
    final arabicFont = await PdfGoogleFonts.amiriRegular();
    final arabicBoldFont = await PdfGoogleFonts.amiriBold();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl, // دعم الكتابة من اليمين لليسار
        margin: const pw.EdgeInsets.all(15),
        build: (context) {
          return [
            pw.GridView(
              crossAxisCount:
                  2, // كرتين بجانب بعض في السطر لتسهيل القص وتوفير الورق
              childAspectRatio: 1.3, // أبعاد مناسبة لشكل بطاقات الدعوة
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: attendees.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                String qrData = data['code'] ?? doc.id;

                return pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.pink200, width: 1.5),
                    borderRadius: pw.BorderRadius.circular(12),
                    color: PdfColors.white,
                  ),
                  padding: const pw.EdgeInsets.all(12),
                  child: pw.Row(
                    children: [
                      // الجهة اليمنى: تفاصيل كرت المعزم
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(
                              "بطاقة دعوة حضور",
                              style: pw.TextStyle(
                                font: arabicBoldFont,
                                fontSize: 14,
                                color: PdfColors.pink700,
                              ),
                            ),
                            pw.SizedBox(height: 5),
                            pw.Text(
                              "الاسم: ${data['name'] ?? 'بدون اسم'}",
                              style: pw.TextStyle(
                                font: arabicBoldFont,
                                fontSize: 12,
                                color: PdfColors.black,
                              ),
                              maxLines: 1,
                            ),
                            pw.Text(
                              "الهاتف: ${data['phone'] ?? 'لا يوجد'}",
                              style: pw.TextStyle(
                                font: arabicFont,
                                fontSize: 10,
                                color: PdfColors.grey700,
                              ),
                            ),
                            pw.Spacer(),
                            pw.Container(
                              padding: const pw.EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: pw.BoxDecoration(
                                color: data['isPresent'] == true
                                    ? PdfColors.green100
                                    : PdfColors.red100,
                                borderRadius: pw.BorderRadius.circular(4),
                              ),
                              child: pw.Text(
                                data['isPresent'] == true
                                    ? "حالة الحضور: تم الدخول"
                                    : "حالة الحضور: غائب",
                                style: pw.TextStyle(
                                  font: arabicFont,
                                  fontSize: 9,
                                  color: data['isPresent'] == true
                                      ? PdfColors.green800
                                      : PdfColors.red800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      pw.SizedBox(width: 8),
                      // الجهة اليسرى: توليد الـ QR Code داخل البطاقة المطبوعة ليتم مسحه عند الباب
                      pw.Container(
                        width: 75,
                        height: 75,
                        alignment: pw.Alignment.center,
                        child: pw.BarcodeWidget(
                          barcode: pw.Barcode.qrCode(),
                          data: qrData,
                          width: 75,
                          height: 75,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ];
        },
      ),
    );

    // عرض نافذة المعاينة والطباعة
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'بطاقات_دعوة_$eventId.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('guests')
          .where('eventId', isEqualTo: eventId)
          .snapshots(),
      builder: (context, snapshot) {
        // تجهيز قائمة المعازيم لإرسالها للزر في الـ AppBar عند اكتمال البيانات
        final List<QueryDocumentSnapshot> attendees = snapshot.hasData
            ? snapshot.data!.docs
            : [];

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              "جدول معازيم الحفلة",
              style: TextStyle(color: Colors.white, fontFamily: 'Amiri'),
            ),
            centerTitle: true,
            backgroundColor: const Color.fromARGB(255, 204, 69, 145),
            actions: [
              // 🖨️ زر الطباعة مدمج في الـ AppBar
              if (snapshot.hasData && attendees.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.print, color: Colors.white),
                  tooltip: 'طباعة البطاقات الورقية',
                  onPressed: () => _printAttendanceCards(attendees),
                ),
              const SizedBox(width: 8),
            ],
          ),
          body: () {
            if (snapshot.hasError) {
              return Center(
                child: Text("حدث خطأ أثناء تحميل البيانات: ${snapshot.error}"),
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (attendees.isEmpty) {
              return const Center(
                child: Text(
                  "لا يوجد معازيم مضافين لهذه الحفلة بعد!",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }

            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(
                      const Color.fromARGB(255, 204, 69, 145).withOpacity(0.1),
                    ),
                    dataRowMinHeight: 70,
                    dataRowMaxHeight: 80,
                    columns: const [
                      DataColumn(
                        label: Text(
                          'الاسم',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'رقم الهاتف',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'رمز الـ QR',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'حالة الحضور',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                    rows: attendees.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      String attendeeId = doc.id;
                      String qrData = data['code'] ?? attendeeId;

                      return DataRow(
                        cells: [
                          DataCell(Text(data['name'] ?? 'بدون اسم')),
                          DataCell(Text(data['phone'] ?? 'لا يوجد')),
                          DataCell(
                            IconButton(
                              icon: const Icon(
                                Icons.qr_code_2,
                                color: Color.fromARGB(255, 204, 69, 145),
                                size: 30,
                              ),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text("كود الحضور: ${data['name']}"),
                                    content: SizedBox(
                                      width: 200,
                                      height: 200,
                                      child: Center(
                                        child: QrImageView(
                                          data: qrData,
                                          version: QrVersions.auto,
                                          size: 200.0,
                                        ),
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text("إغلاق"),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          DataCell(
                            Icon(
                              data['isPresent'] == true
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              color: data['isPresent'] == true
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            );
          }(),
        );
      },
    );
  }
}
