// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class EventListScreen extends StatelessWidget {
  const EventListScreen({super.key});

  //  دالة مسؤولة عن إظهار نافذة التأكيد وحذف الحفلة من الفايربيس
  void _deleteEvent(BuildContext context, String eventId, String eventName) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Color.fromARGB(255, 204, 69, 145),
              ),
              SizedBox(width: 8),
              Text(
                "تأكيد الحذف",
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            "هل أنتِ متأكدة من حذف حفلة \"$eventName\" نهائياً؟\nلا يمكن التراجع عن هذا الإجراء.",
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext), // إغلاق النافذة وإلغاء الحذف
              child: const Text("إلغاء", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext); // إغلاق النافذة أولاً

                try {
                  // حذف الحفلة من الفايربيس
                  await FirebaseFirestore.instance
                      .collection('events')
                      .doc(eventId)
                      .delete();

                  // إشعار نجاح للمستخدم
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("تم حذف حفلة $eventName بنجاح")),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("حدث خطأ أثناء الحذف: $e"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 204, 69, 145),
                foregroundColor: Colors.white,
              ),
              child: const Text("حذف نهائي"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "إدارة الحفلات والمناسبات",
          style: TextStyle(color: Colors.white, fontFamily: 'Amiri'),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 204, 69, 145),
        // actions: [
        //   // زر سريع لإضافة حفلة جديدة بالانتقال لشاشة الاستيراد السابقة
        //   IconButton(
        //     icon: const Icon(Icons.add_box, color: Colors.white, size: 28),
        //     onPressed: () => context.push('/import'),
        //   ),
        // ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        // جلب الحفلات مرتبة من الأحدث إلى الأقدم
        stream: FirebaseFirestore.instance
            .collection('events')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text("حدث خطأ أثناء تحميل الحفلات: ${snapshot.error}"),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.auto_awesome,
                    size: 70,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "لا توجد حفلات مسجلة حالياً!\nاضغطي على الزر العلوي لإضافة أول حفلة.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          final events = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: events.length,
            itemBuilder: (context, index) {
              var eventData = events[index].data() as Map<String, dynamic>;
              String eventId = events[index].id;
              String eventName = eventData['eventName'] ?? "حفلة بدون اسم";

              // تنسيق الوقت بشكل بسيط
              String formattedDate = "";
              if (eventData['createdAt'] != null) {
                DateTime dateTime = (eventData['createdAt'] as Timestamp)
                    .toDate();
                formattedDate = DateFormat(
                  'yyyy-MM-dd – hh:mm a',
                ).format(dateTime);
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      // أيقونة الحفلة التجميلية
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 204, 69, 145),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.celebration,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),

                      // تفاصيل اسم الحفلة وتاريخها
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              eventName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (formattedDate.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                formattedDate,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      // 🛠️ الأزرار بجانب بعضها في سطر واحد (Row)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 1. زر الانتقال لجدول المعازيم الخاص بهذه الحفلة
                          IconButton(
                            onPressed: () {
                              debugPrint(
                                "🔄 الانتقال إلى جدول معازيم الحفلة: $eventName بـ ID: $eventId",
                              );
                              context.push('/attendees/$eventId');
                            },
                            icon: const Icon(
                              Icons.people_outline_rounded,
                            ), // أيقونة ناعمة ومناسبة للمظهر الجديد
                            color: const Color.fromARGB(
                              255,
                              204,
                              69,
                              145,
                            ), // نفس اللون الزهري للحفلة
                            tooltip: 'جدول المعازيم',
                            style: IconButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(
                                    255,
                                    204,
                                    69,
                                    145,
                                  ).withOpacity(
                                    0.1,
                                  ), // خلفية زهرية خفيفة جداً (10%)
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  10,
                                ), // حواف دائرية متناسقة
                              ),
                              padding: const EdgeInsets.all(10),
                            ),
                          ),

                          const SizedBox(width: 8), // مسافة صغيرة بين الزرين
                          // 2. زر حذف الحفلة كأيقونة زهرية بعد زر عرض الجدول
                          IconButton(
                            onPressed: () =>
                                _deleteEvent(context, eventId, eventName),
                            icon: const Icon(Icons.delete_outline_rounded),
                            color: const Color.fromARGB(
                              255,
                              204,
                              69,
                              145,
                            ), // نفس اللون الزهري للحفلة
                            tooltip: 'حذف الحفلة',
                            style: IconButton.styleFrom(
                              backgroundColor: const Color.fromARGB(
                                255,
                                204,
                                69,
                                145,
                              ).withOpacity(0.1), // خلفية زهرية خفيفة جداً
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.all(10),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
