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

  String _formatPhoneNumber(String rawPhone) {
    if (rawPhone.isEmpty) return "لا يوجد";

    // 1. تنظيف النص من الفراغات أو الرموز الزائدة
    String cleanPhone = rawPhone.replaceAll(RegExp(r'[\s\-\+\(\)]'), '');

    // 2. معالجة حالات نصوص الباكج القديمة المخزنة مثل (nsn: 963...) قبل أي شيء
    if (cleanPhone.contains("nsn:")) {
      final regExp = RegExp(r'nsn:\s*(\d+)');
      final match = regExp.firstMatch(
        rawPhone,
      ); // نستخدم الأصل للبحث عن النص بدقة
      if (match != null && match.group(1) != null) {
        cleanPhone = match.group(1)!;
      }
    }

    // 3. حل مشكلة تكرار النداء الدولي الصريح بأي صيغة (00963963 أو 963963)
    if (cleanPhone.startsWith('00963963')) {
      cleanPhone = cleanPhone.substring(5); // ترك 963 واحدة مع الرقم
    } else if (cleanPhone.startsWith('963963')) {
      cleanPhone = cleanPhone.substring(3); // ترك 963 واحدة مع الرقم
    }

    // تأمين إضافة زائد واحدة في البداية للباكج إذا كان يبدأ بـ 963 ليتم التعرف عليه دولياً
    if (cleanPhone.startsWith('963')) {
      cleanPhone = '+$cleanPhone';
    } else if (cleanPhone.startsWith('09')) {
      // إذا كان رقم محلي سوري يبدأ بـ 09، نحوله لصيغة دولية صحيحة لتجنب المشاكل
      cleanPhone = '+963${cleanPhone.substring(1)}';
    } else if (cleanPhone.startsWith('9') && cleanPhone.length == 9) {
      // إذا كان رقم محلي بدون صفر (9xx xxx xxx)
      cleanPhone = '+963$cleanPhone';
    }

    try {
      // محاولة قراءة وتحليل النص ككائن هاتف مع تحديد الدولة لضمان عدم التكرار
      final parsed = PhoneNumber.parse(cleanPhone, callerCountry: IsoCode.SY);
      return parsed
          .international; // يعيد الرقم بالصيغة الدولية المنسقة تلقائياً
    } catch (_) {
      // كخيار احتياطي أخير إذا فشل التحليل، نعيد بناء الرقم بشكل يدوي نظيف
      String fallback = cleanPhone.replaceAll('+', '');
      if (fallback.startsWith('963')) {
        return "+963 ${fallback.substring(3)}";
      }
      return rawPhone;
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

          // تحويل القيم الرقمية بأمان من قاعدة البيانات
          final double paidAmount =
              double.tryParse(appointment.paid.toString()) ?? 0.0;
          final double restAmount =
              double.tryParse(appointment.rest.toString()) ?? 0.0;

          // 🌟 الإصلاح الجوهري للحساب: السعر الإجمالي الكلي الفعلي يساوي المدفوع + المتبقي
          final double totalOriginalPrice = paidAmount + restAmount;

          String locationToDisplay = appointment.city;
          if (appointment.isRural) {
            if (appointment.ruralLocation.trim().isNotEmpty) {
              locationToDisplay = "ريف - ${appointment.ruralLocation}";
            } else {
              locationToDisplay = "ريف - غير محدد";
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(10.0),
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
                          "\u200E${_formatPhoneNumber(appointment.phone)}",
                        ),
                        _buildDetailRow(
                          Icons.location_city,
                          appointment.isRural ? "المنطقة (ريف):" : "المدينة:",
                          locationToDisplay,
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
                        _buildDetailRow(
                          Icons.people,
                          "عدد الضيوف:",
                          "${appointment.number} ضيف", // يجلب عدد الضيوف المخزن في الموديل
                        ),
                        _buildDetailRow(
                          Icons.monetization_on,
                          "السعر الإجمالي:",
                          "\u200E${totalOriginalPrice.toStringAsFixed(1)} \$",
                          isBold: true,
                        ),
                        _buildDetailRow(
                          Icons.money,
                          "المبلغ المدفوع:",
                          "\u200E${paidAmount.toStringAsFixed(0)} \$",
                        ),
                        _buildDetailRow(
                          Icons.money_off,
                          "المبلغ المتبقي:",
                          "\u200E${restAmount.toStringAsFixed(0)} \$",
                        ),
                        _buildDetailRow(
                          Icons.local_shipping,
                          "أجور النقل:",
                          "\u200E${appointment.transportFees} \$",
                        ),
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
                const SizedBox(height: 15),
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
      padding: const EdgeInsets.symmetric(vertical: 8.0),
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
