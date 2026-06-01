// ignore_for_file: deprecated_member_use, avoid_unnecessary_containers

import 'package:gap/gap.dart'; // تحتوي على الـ Gap والـ SliverGap معاً
import 'package:princesses/auth/application/auth_notifier_provider.dart';
import 'package:princesses/home/application/current_user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: Colors.pink.shade50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "الرئيسية",
          style: TextStyle(
            fontFamily: "Amiri",
            color: Colors.pink,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
        data: (user) {
          final bool isAdmin = user?.isAdmin == true;

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 1. قسم الترحيب
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 20.0,
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.person,
                          size: 32,
                          color: Colors.pink.shade700,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "مرحباً بك، ",
                              style: TextStyle(
                                fontFamily: "Amiri",
                                fontSize: 26,
                                color: Colors.pink.shade400,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              user?.name ?? "بالضيف",
                              style: TextStyle(
                                fontFamily: "Amiri",
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.pink.shade400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // المسافة الأولى (بعد الترحيب وقبل الأزرار)
              const SliverGap(30),

              // 2. شبكة الأزرار البيضاء
              // SliverPadding(
              //   padding: const EdgeInsets.symmetric(horizontal: 20.0),
              //   sliver: SliverGrid.count(
              //     crossAxisCount: 2,
              //     mainAxisSpacing: 16,
              //     crossAxisSpacing: 16,
              //     childAspectRatio: 1.1,
              //     children: [
              //       // زر الحجوزات
              //       _buildGridButton(
              //         text: isAdmin ? "عرض الحجوزات" : "حجوزات مدينتي",
              //         icon: Icons.list_alt_rounded,
              //         iconColor: Colors.pink.shade400,
              //         onTap: () => context.go("/reservations"),
              //       ),

              //       // زر إضافة حجز جديد
              //       _buildGridButton(
              //         text: "إضافة حجز",
              //         icon: Icons.add_circle_outline_rounded,
              //         iconColor: Colors.pink.shade400,
              //         onTap: () => context.go("/appointment"),
              //       ),

              //       // أزرار المدير (تظهر إذا كان Admin)
              //       if (isAdmin) ...[
              //         _buildGridButton(
              //           text: "لوحة التحكم",
              //           icon: Icons.admin_panel_settings_rounded,
              //           iconColor: Colors.pink.shade400,
              //           onTap: () => context.go("/admin"),
              //         ),
              //         _buildGridButton(
              //           text: "الماسح والحفلات",
              //           icon: Icons.qr_code_scanner_rounded,
              //           iconColor: Colors.pink.shade400,
              //           onTap: () => context.push("/import-event"),
              //         ),
              //       ],
              //     ],
              //   ),
              // ),
              // 2. شبكة الأزرار البيضاء
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                sliver: SliverGrid.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.1,
                  children: [
                    // زر الحجوزات (يظهر للجميع)
                    _buildGridButton(
                      text: isAdmin ? "عرض الحجوزات" : "حجوزات مدينتي",
                      icon: Icons.list_alt_rounded,
                      iconColor: Colors.pink.shade400,
                      onTap: () => context.go("/reservations"),
                    ),

                    // زر إضافة حجز جديد (يظهر للجميع)
                    _buildGridButton(
                      text: "إضافة حجز",
                      icon: Icons.add_circle_outline_rounded,
                      iconColor: Colors.pink.shade400,
                      onTap: () => context.go("/appointment"),
                    ),

                    // أزرار المدير (تظهر فقط إذا كان isAdmin == true)
                    if (isAdmin) ...[
                      // أ) زر لوحة التحكم الإدارية
                      _buildGridButton(
                        text: "لوحة التحكم",
                        icon: Icons.admin_panel_settings_rounded,
                        iconColor: Colors.pink.shade400,
                        onTap: () => context.go("/admin"),
                      ),

                      // ب) [الزر الجديد] لفتح شاشة قائمة الحفلات والمناسبات وإدارتها
                      _buildGridButton(
                        text: "إدارة الحفلات",
                        icon: Icons.festival_rounded, // أيقونة معبرة للمناسبات
                        iconColor: Colors.pink.shade400,
                        onTap: () => context.push(
                          "/events",
                        ), // المسار الرئيسي لقائمة الحفلات حسب ضبط الـ Router لديكِ
                      ),

                      // ج) زر استيراد المناسبات الفوري (القديم)
                      _buildGridButton(
                        text: "استيراد معازيم",
                        icon: Icons.cloud_upload_rounded,
                        iconColor: Colors.pink.shade400,
                        onTap: () => context.push("/import-event"),
                      ),
                      _buildGridButton(
                        text: "قريبًا ",
                        icon: Icons.soap_rounded,
                        iconColor: Colors.pink.shade400,
                        onTap: () => context.push("/import-event"),
                      ),
                    ],
                  ],
                ),
              ),
              // [تم الإصلاح هنا] المسافة الثانية قبل زر تسجيل الخروج
              const SliverGap(75),

              // 3. زر تسجيل الخروج في الأسفل
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () {
                          ref.read(authNotifierProvider.notifier).logOut();
                          context.go("/");
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.pink.shade200,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.logout_rounded,
                                color: Colors.pink.shade600,
                                size: 22,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "تسجيل الخروج",
                                style: TextStyle(
                                  fontFamily: "Amiri",
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.pink.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 24,
                      ), // مسافة أمان إضافية لأسفل الشاشة
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ودجت المربعات البيضاء الموحدة
  Widget _buildGridButton({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
    required Color iconColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.shade100.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 30, color: iconColor),
                ),
                const SizedBox(height: 12),
                Text(
                  text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: "Amiri",
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.pink.shade900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
