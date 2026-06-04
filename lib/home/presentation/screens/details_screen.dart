// ignore_for_file: unnecessary_underscores, deprecated_member_use, depend_on_referenced_packages

import 'package:princesses/home/application/appointment_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:princesses/home/domain/appointment_model.dart';
import 'package:princesses/home/presentation/screens/edit_screen.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart'; // استيراد الباكج لاستخراج الرقم النظيف

class DetailsAppScreen extends ConsumerWidget {
  final String appId;

  const DetailsAppScreen({super.key, required this.appId});

  // دالة مساعدة لتنظيف وعرض رقم الهاتف بشكل مقروء
  String _formatPhoneNumber(String rawPhone) {
    if (rawPhone.isEmpty) return "لا يوجد";
    try {
      // محاولة قراءة وتحليل النص ككائن هاتف
      final parsed = PhoneNumber.parse(rawPhone);
      return parsed
          .international; // يعيد الرقم بالصيغة الدولية المنسقة تلقائياً
    } catch (_) {
      // إذا كان النص مخزناً مسبقاً بشكل معقد أو يحتوي على نصوص الباكج القديمة
      if (rawPhone.contains("nsn:")) {
        final regExp = RegExp(r'nsn:\s*(\d+)');
        final match = regExp.firstMatch(rawPhone);
        if (match != null && match.group(1) != null) {
          return "+963 ${match.group(1)}"; // استخراج الرقم الصافي في حال علق النص القديم بقاعدة البيانات
        }
      }
      return rawPhone; // كخيار احتياطي إذا كان الرقم عادي
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reservationsAsync = ref.watch(reservationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "تفاصيل الحجز",
          style: TextStyle(fontFamily: "Amiri", fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          reservationsAsync.when(
            data: (apps) {
              final hasApp = apps.any((element) => element.id == appId);
              if (!hasApp) return const SizedBox.shrink();

              return IconButton(
                icon: const Icon(Icons.edit, color: Colors.pinkAccent),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditAppScreen(appId: appId),
                    ),
                  );
                },
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: reservationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text("حدث خطأ: $error")),
        data: (apps) {
          final appointment = apps.firstWhere(
            (element) => element.id == appId,
            orElse: () => AppointmentModel(
              id: '',
              name: 'غير معروف',
              place: '',
              mediator: '',
              city: '',
              notes: '',
              phone: '',
              date: DateTime.now(),
              number: '',
              email: '',
              paid: "0",
              rest: "0",
              transportFees: 0,
            ),
          );

          if (appointment.id.isEmpty) {
            return const Center(child: Text("الحجز غير موجود أو تم حذفه"));
          }

          final formattedDate = DateFormat(
            'yyyy-MM-dd',
          ).format(appointment.date);
          final formattedTime = DateFormat('hh:mm a').format(appointment.date);

          // حساب السعر الإجمالي (المدفوع + المتبقي) بشكل ديناميكي
          // 1. تحويل القيم المادية الأساسية بأمان (سواء كانت نص أو رقم)
          final double paidAmount =
              double.tryParse(appointment.paid.toString()) ?? 0.0;
          final double restAmount =
              double.tryParse(appointment.rest.toString()) ?? 0.0;
          final double transport =
              double.tryParse(appointment.transportFees.toString()) ?? 0.0;

          // 2. جلب أسعار الأركان ديناميكياً وتحويلها بأمان لتفادي مشكلة الصفر (0.0) إذا كانت مخزنة كنص
          final double memoriesPrice =
              double.tryParse(appointment.memoriesCornerPrice.toString()) ??
              0.0;
          final double safesPrice =
              double.tryParse(appointment.safesCornerPrice.toString()) ?? 0.0;
          final double coversPrice =
              double.tryParse(appointment.coversServicePrice.toString()) ?? 0.0;

          // 3. حساب السعر الإجمالي الكلي المحدث والشامل لكل شيء
          final double totalOriginalPrice =
              paidAmount +
              restAmount +
              transport +
              memoriesPrice +
              safesPrice +
              coversPrice;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow(
                          Icons.person,
                          "الاسم:",
                          appointment.name,
                        ),
                        _buildDetailRow(
                          Icons.phone,
                          "الهاتف:",
                          _formatPhoneNumber(appointment.phone),
                        ),
                        _buildDetailRow(
                          Icons.location_city,
                          "المدينة:",
                          appointment.city,
                        ),
                        _buildDetailRow(
                          Icons.store,
                          "الصالة / المكان:",
                          appointment.place,
                        ),
                        _buildDetailRow(
                          Icons.calendar_month,
                          "التاريخ:",
                          formattedDate,
                        ),
                        _buildDetailRow(
                          Icons.access_time,
                          "الوقت:",
                          formattedTime,
                        ),

                        // const Divider(height: 30, thickness: 1),

                        // 🌟 عرض السعر الإجمالي للحجز
                        _buildDetailRow(
                          Icons.monetization_on,
                          "السعر الإجمالي:",
                          "$totalOriginalPrice \$",
                          isBold: true,
                        ),
                        _buildDetailRow(
                          Icons.money,
                          "المبلغ المدفوع:",
                          "${appointment.paid} \$",
                        ),
                        _buildDetailRow(
                          Icons.money_off,
                          "المبلغ المتبقي:",
                          "${appointment.rest} \$",
                        ),
                        _buildDetailRow(
                          Icons.local_shipping,
                          "أجور النقل:",
                          "${appointment.transportFees} \$",
                        ),

                        // const Divider(height: 30, thickness: 1),
                        _buildDetailRow(
                          Icons.star,
                          "ركن الذكريات:",
                          appointment.hasMemoriesCorner
                              ? "نعم (+ ${appointment.memoriesCornerPrice} \$)"
                              : "لا",
                        ),
                        _buildDetailRow(
                          Icons.lock,
                          "ركن الأمانات:",
                          appointment.hasSafesCorner
                              ? "نعم (+ ${appointment.safesCornerPrice} \$)"
                              : "لا",
                        ),
                        _buildDetailRow(
                          Icons.cameraswitch_outlined,
                          "ركن الكفرات:",
                          appointment.hasCoversService
                              ? "نعم (+ ${appointment.coversServicePrice} \$)"
                              : "لا",
                        ),
                        _buildDetailRow(
                          Icons.notes,
                          "ملاحظات:",
                          appointment.notes.isEmpty
                              ? "لا يوجد"
                              : appointment.notes,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditAppScreen(appId: appId),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit_note, color: Colors.white),
                    label: const Text(
                      "تعديل بيانات الحجز",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value, {
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: isBold ? Colors.green : Colors.pinkAccent.withOpacity(0.8),
            size: 24,
          ),
          const SizedBox(width: 15),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                color: isBold ? Colors.green : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
