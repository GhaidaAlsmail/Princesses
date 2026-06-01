import 'package:princesses/auth/application/auth_service.dart';
import 'package:princesses/auth/application/app_user_service.dart';
import 'package:princesses/auth/domain/app_user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final currentUserProvider = FutureProvider<AppUser?>((ref) async {
  final auth = ref.watch(authServiceProvider);
  final user = auth.currenUser;

  if (user == null) return null;

  final appUserService = ref.watch(appUserServiceProvider);
  final appUser = await appUserService.getAccountByEmail(user.email!);

  return appUser;
});
