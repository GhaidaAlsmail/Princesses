import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class GuestQrCard extends StatelessWidget {
  final String guestName;
  final String category;
  final String seatNumber;
  final String
  qrData; // الـ ID الفريد المستورد من الفايربيز الذي قمنا بتوليده سابقاً

  const GuestQrCard({
    super.key,
    required this.guestName,
    required this.category,
    required this.seatNumber,
    required this.qrData,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // شعار أو أيقونة تجميلية أعلى الكرت
            Icon(Icons.auto_awesome, color: Colors.pink.shade400, size: 30),
            const SizedBox(height: 10),

            // اسم الضيف
            Text(
              guestName,
              style: const TextStyle(
                fontFamily: 'Amiri',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.pink,
              ),
            ),
            const SizedBox(height: 5),

            // تفاصيل الفئة والمقعد
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Chip(
                  label: Text("الفئة: $category"),
                  backgroundColor: Colors.pink.shade50,
                  labelStyle: TextStyle(color: Colors.pink.shade700),
                ),
                const SizedBox(width: 10),
                Chip(
                  label: Text("مقعد: $seatNumber"),
                  backgroundColor: Colors.blue.shade50,
                  labelStyle: TextStyle(
                    color: const Color.fromARGB(255, 223, 167, 190),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 👑 الـ QR Code الذكي والمربع
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.pink.shade100, width: 2),
              ),
              child: QrImageView(
                data: qrData, // النص المشفر داخل المربع (الـ guestId)
                version: QrVersions.auto,
                size: 200.0, // حجم المربع في الشاشة
                gapless: false,
                embeddedImage: const AssetImage(
                  'assets/images/logo.png',
                ), // اختياري: لو أردتِ وضع لوجو صغير في منتصف الـ QR
                embeddedImageStyle: const QrEmbeddedImageStyle(
                  size: Size(40, 40),
                ),
                errorStateBuilder: (cxt, err) {
                  return const Center(child: Text("فشل توليد الرمز المربع"));
                },
              ),
            ),
            const SizedBox(height: 15),

            Text(
              "يرجى إبراز هذا الرمز عند بوابة الدخول",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
