import 'package:princesses/auth/domain/app_user.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/firestore_app_user_repository.dart';

part 'app_user_service.g.dart';

@riverpod
AppUserService appUserService(Ref ref) => AppUserService(
  firestoreAppUserRepository: ref.read(firestoreAppUserRepositoryProvider),
);

class AppUserService {
  final FirestoreAppUserRepository firestoreAppUserRepository;
  AppUserService({required this.firestoreAppUserRepository});

  Future<AppUser> createAccount(AppUser user) {
    return firestoreAppUserRepository.createUser(appUser: user);
  }

  Future<AppUser?> getAccountByEmail(String email) {
    return firestoreAppUserRepository.getUserByEmail(email: email);
  }

  Future<void> updateUser({required FormGroup form}) async {
    BotToast.showLoading();
    var id = form.control("id").value;
    var userName = form.control("userName").value;
    var birthDate = form.control("date").value;
    var oldUser = await firestoreAppUserRepository.readUser(id: id); // Data
    if (oldUser == null) {
      BotToast.closeAllLoading();
      BotToast.showText(text: "عذراً,يوجد خطأ ما!!");
    } else {
      oldUser = oldUser.copyWith(name: userName, birthDate: birthDate);
      await firestoreAppUserRepository.updateUser(appUser: oldUser); // Data
      BotToast.closeAllLoading();
      BotToast.showText(text: "تم التحديث بنجاح");
    }
  }

  Future<void> saveUserFcmToken(String userId) {
    return firestoreAppUserRepository.saveUserFcmToken(userId);
  }
}
