// ignore_for_file: use_build_context_synchronously

import 'package:bot_toast/bot_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:princesses/auth/application/auth_notifier_provider.dart';
import 'package:princesses/home/application/current_user_provider.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;

  String? _selectedCity;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final List<Map<String, String>> _cities = const [
    {'value': 'idleb', 'label': 'إدلب'},
    {'value': 'aleppo', 'label': 'حلب'},
    {'value': 'homs', 'label': 'حمص'},
    {'value': 'Damascus', 'label': 'دمشق'},
  ];

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();

    final userState = ref.read(currentUserProvider).value;
    if (userState != null) {
      _nameController.text = userState.name ?? '';

      final userCity = userState.city;
      if (userCity != null && userCity.isNotEmpty) {
        final matchingCity = _cities.firstWhere(
          (element) =>
              element['value']!.toLowerCase() == userCity.toLowerCase(),
          orElse: () => {},
        );
        _selectedCity = matchingCity['value'];
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    BotToast.showLoading();

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      final currentUserData = ref.read(currentUserProvider).value;

      if (currentUser != null && currentUserData != null) {
        final oldCity = currentUserData.city;
        final newCity = _selectedCity;
        final newName = _nameController.text.trim();
        final newPassword = _passwordController.text.trim();

        debugPrint("--- [تعديل البروفايل] البيانات الجديدة ---");
        debugPrint("الاسم الجديد: $newName");
        debugPrint("المدينة الجديدة: $newCity");
        debugPrint("هل تم إدخال كلمة مرور جديدة؟: ${newPassword.isNotEmpty}");

        await FirebaseFirestore.instance
            .collection('appUsers')
            .doc(currentUser.uid)
            .update({'name': newName, 'city': newCity});

        debugPrint("--- تم التحديث في Firestore بنجاح! ---");

        if (oldCity != null && oldCity.isNotEmpty && oldCity != newCity) {
          await FirebaseMessaging.instance.unsubscribeFromTopic(
            'city_$oldCity',
          );
        }
        if (newCity != null && newCity.isNotEmpty) {
          await FirebaseMessaging.instance.subscribeToTopic('city_$newCity');
        }

        if (newPassword.isNotEmpty) {
          await currentUser.updatePassword(newPassword);
        }

        BotToast.closeAllLoading();
        BotToast.showText(text: "تم تحديث البيانات بنجاح");

        if (mounted) context.pop();

        // تأجيل إبطال الـ Provider لمنع خطأ Riverpod أثناء التنقل بين الشاشات
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.invalidate(currentUserProvider);
          ref.read(authNotifierProvider.notifier).refreshUser();
        });
      }
    } on FirebaseAuthException catch (e) {
      BotToast.closeAllLoading();
      if (e.code == 'requires-recent-login') {
        BotToast.showText(
          text: "لأسباب أمنية، يرجى إعادة تسجيل الدخول لتغيير كلمة المرور",
        );
      } else {
        BotToast.showText(text: "خطأ في تعديل كلمة المرور: ${e.message}");
      }
    } catch (e) {
      BotToast.closeAllLoading();
      BotToast.showText(text: "حدث خطأ غير متوقع: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final isPasswordUser =
        FirebaseAuth.instance.currentUser?.providerData.any(
          (p) => p.providerId == 'password',
        ) ??
        false;

    return Scaffold(
      backgroundColor: Colors.pink.shade50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "تعديل الملف الشخصي",
          style: TextStyle(
            fontFamily: "Amiri",
            color: primaryColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: primaryColor),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 42,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 55, color: primaryColor),
                ),
              ),
              const Gap(25),

              _buildSectionTitle("الاسم"),
              const Gap(5),
              TextFormField(
                controller: _nameController,
                decoration: _buildInputDecoration(
                  hintText: "الاسم الكامل",
                  icon: Icons.person_outline,
                ),
                validator: (val) =>
                    (val == null || val.isEmpty) ? 'الرجاء إدخال الاسم' : null,
              ),
              const Gap(20),

              _buildSectionTitle("المدينة"),
              const Gap(5),
              DropdownButtonFormField<String>(
                value: _selectedCity,
                decoration: _buildInputDecoration(
                  hintText: "اختر المدينة",
                  icon: Icons.location_city_outlined,
                ),
                items: _cities.map((city) {
                  return DropdownMenuItem<String>(
                    value: city['value'],
                    child: Text(
                      city['label']!,
                      style: const TextStyle(fontFamily: "Amiri", fontSize: 16),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() => _selectedCity = val);
                },
                validator: (val) => (val == null || val.isEmpty)
                    ? 'الرجاء اختيار المدينة'
                    : null,
              ),
              const Gap(20),

              if (isPasswordUser) ...[
                const Divider(height: 30, thickness: 1),
                _buildSectionTitle("كلمة المرور الجديدة (اختياري)"),
                const Gap(5),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: _buildInputDecoration(
                    hintText: "******",
                    icon: Icons.lock_outline,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: primaryColor,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                  ),
                  validator: (val) {
                    if (val != null && val.isNotEmpty && val.length < 6) {
                      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                    }
                    return null;
                  },
                ),
                const Gap(15),

                _buildSectionTitle("تأكيد كلمة المرور الجديدة"),
                const Gap(5),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: _buildInputDecoration(
                    hintText: "******",
                    icon: Icons.lock_clock_outlined,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: primaryColor,
                      ),
                      onPressed: () {
                        setState(
                          () => _obscureConfirmPassword =
                              !_obscureConfirmPassword,
                        );
                      },
                    ),
                  ),
                  validator: (val) {
                    if (_passwordController.text.isNotEmpty &&
                        val != _passwordController.text) {
                      return 'كلمتا المرور غير متطابقتين';
                    }
                    return null;
                  },
                ),
              ],
              const Gap(35),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "حفظ التغييرات",
                    style: TextStyle(
                      fontFamily: "Amiri",
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const Gap(20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontFamily: "Amiri",
        color: Theme.of(context).colorScheme.primary,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: Theme.of(context).colorScheme.onPrimary.withAlpha(100),
      ),
      prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.primary),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.onPrimary.withAlpha(40),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
      ),
    );
  }
}
