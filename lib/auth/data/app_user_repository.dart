import 'package:princesses/auth/domain/app_user.dart';

abstract class AppUserRepository {
  Future<void> createUser({required AppUser appUser});
  Future<AppUser?> readUser({required String id});
  Future<void> updateUser({required AppUser appUser});
  Future<void> deleteUser({required String id});
  Future<AppUser?> getUserByEmail({required String email});
  Stream<AppUser?> streamUserById({required String id});
  Future<List<AppUser>> getAllUsers();
}
