import 'package:flutter_riverpod/flutter_riverpod.dart';

final authProvider = NotifierProvider<AuthNotifier, bool>(() {
  return AuthNotifier();
});

class AuthNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  static const String adminEmail = 'admin@ieltsuniversity.com';
  static const String adminPassword = 'adminpassword123';

  bool login(String email, String password) {
    if (email == adminEmail && password == adminPassword) {
      state = true;
      return true;
    }
    return false;
  }

  void logout() {
    state = false;
  }
}
