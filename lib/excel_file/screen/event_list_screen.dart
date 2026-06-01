import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart'; // لتنسيق تاريخ إنشاء الحفلة إذا رغبتِ

class EventListScreen extends StatelessWidget {
  const EventListScreen({super.key});

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
        actions: [
          // زر سريع لإضافة حفلة جديدة بالانتقال لشاشة الاستيراد السابقة
          IconButton(
            icon: const Icon(Icons.add_box, color: Colors.white, size: 28),
            onPressed: () => context.push('/import'),
          ),
        ],
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
                // margin: const EdgeInsets.bottom edgedInsets.only(bottom: 16),
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
                        decoration: BoxDecoration(
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

                      // الزر الذكي لفتح الماسح الخاص بهذه الحفلة بالتحديد
                      ElevatedButton.icon(
                        onPressed: () {
                          debugPrint(
                            "🔄 الانتقال لماسح الحفلة: $eventName بـ ID: $eventId",
                          );
                          // الانتقال للراوتر وتمرير الـ ID الديناميكي
                          context.push('/scanner/$eventId');
                        },
                        icon: const Icon(Icons.qr_code_scanner, size: 20),
                        label: const Text("فتح الماسح"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            204,
                            69,
                            145,
                          ),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
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
