import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';

class QrScannerScreen extends StatefulWidget {
  final String eventId;

  const QrScannerScreen({super.key, required this.eventId});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  bool _isProcessing = false;
  String _resultMessage = "وجه الكاميرا نحو رمز الـ QR الخاص بالبطاقة";
  Color _cardColor = Colors.white;

  /// الدالة الذكية للتحقق من بيانات الضيف داخل الفايربيز
  Future<void> _verifyGuest(String guestId) async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
      _resultMessage = "جاري التحقق من قاعدة البيانات سحابياً...";
    });

    try {
      DocumentSnapshot guestDoc = await FirebaseFirestore.instance
          .collection('guests')
          .doc(guestId.trim())
          .get();

      if (!guestDoc.exists) {
        setState(() {
          _cardColor = Colors.red.shade100;
          _resultMessage =
              "❌ عذراً! الباركود المقروء ($guestId) غير مسجل في النظام.";
        });
        return;
      }

      Map<String, dynamic> guestData = guestDoc.data() as Map<String, dynamic>;

      if (guestData['eventId'] != widget.eventId) {
        setState(() {
          _cardColor = Colors.orange.shade100;
          _resultMessage =
              "⚠️ تنبيه: هذا الضيف تابع لحفلة أخرى وليس لهذه الحفلة الحالية!";
        });
        return;
      }

      String name = guestData['name'] ?? "بدون اسم";
      String category = guestData['category'] ?? "عادي";
      String seat = guestData['seatNumber'] ?? "غير محدد";
      String status = guestData['status'] ?? "لم يحضر";

      setState(() {
        if (category.toUpperCase() == 'VIP') {
          _cardColor = Colors.amber.shade100;
        } else if (category == 'وسط') {
          _cardColor = Colors.blue.shade100;
        } else {
          _cardColor = Colors.green.shade100;
        }

        _resultMessage =
            "🎉 أهلاً وسهلاً بك: $name\n"
            "👑 الفئة: $category\n"
            "🪑 مكان الجلوس: $seat\n"
            "📌 الحالة السابقة: $status";
      });

      // تحديث الحالة إلى "تم الحضور" لمنع الدخول المتكرر بنفس التذكرة
      await FirebaseFirestore.instance
          .collection('guests')
          .doc(guestId.trim())
          .update({
            'status': 'تم الحضور',
            'arrivalTime': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      setState(() {
        _cardColor = Colors.red.shade50;
        _resultMessage = "خطأ أثناء التحقق: ${e.toString()}";
      });
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          "شاشة الفحص والمسح الحي",
          style: TextStyle(
            fontFamily: 'Amiri',
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 233, 169, 200),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. لوحة عرض نتائج الفحص وتوجيه المنظم والمقاعد
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: _cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color.fromARGB(255, 219, 157, 192),
                  width: 2,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromARGB(31, 237, 170, 209),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Text(
                _resultMessage,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 30),

            // 2. زر فتح كاميرا البث الحي (مثل الماسح الحقيقي)
            ElevatedButton.icon(
              icon: const Icon(Icons.videocam, size: 28),
              label: const Text(
                "افتح الماسح",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Color.fromARGB(255, 233, 169, 200),

                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: () async {
                // فتح شاشة كاميرا المسح الحي المتوافقة تماماً مع إصدار 7.1.0
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AiBarcodeScanner(
                      // في هذا الإصدار يتم استخدام onDispose لمعالجة الكود بعد انتهاء لقطة الشاشة
                      onDispose: () {
                        debugPrint("تم إغلاق شاشة المسح الحي");
                      },
                      // هذا هو البارامتر الصحيح لالتقاط النص المقروء في الإصدارات القديمة
                      onDetect: (BarcodeCapture capture) {
                        // استخراج النص من أول باركود ممسوح في البث
                        final String? code = capture.barcodes.first.rawValue;

                        if (code != null && code.isNotEmpty) {
                          debugPrint("تم مسح كود بنجاح: $code");
                          Navigator.of(
                            context,
                          ).pop(); // إغلاق الكاميرا تلقائياً فور اللقطة
                          _verifyGuest(code); // بدء التحقق الفوري في الفايربيز
                        }
                      },
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 40),
            const Divider(
              thickness: 1.5,
              color: Color.fromARGB(255, 233, 169, 200),
            ),
            const SizedBox(height: 10),

            // 3. قسم التجريب للمحاكي (Emulator Testing Dashboard)
            const Text(
              " أدوات تجريب المحاكي (بدون كاميرا):",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
              textAlign: TextAlign.start,
            ),
            const SizedBox(height: 15),

            // حقل إدخال يدوي لكتابة أي ID ضيف ومحاكاة عملية المسح بنجاح ورؤية النتيجة
            TextField(
              decoration: InputDecoration(
                labelText: "أدخل ID ضيف يدوياً للتجريب ومحاكاة الباركود",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(
                  Icons.hot_tub_rounded,
                  color: Color.fromARGB(255, 238, 170, 202),
                ),
                suffixIcon: const Icon(
                  Icons.arrow_forward,
                  color: Color.fromARGB(255, 233, 169, 200),
                ),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  _verifyGuest(value); // محاكاة عملية القراءة الحية للـ QR
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
