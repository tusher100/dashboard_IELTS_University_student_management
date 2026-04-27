import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Provider for SharedPreferences instance (overridden in main.dart)
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

final authProvider = NotifierProvider<AuthNotifier, bool>(() {
  return AuthNotifier();
});

class AuthNotifier extends Notifier<bool> {
  static const String _authKey = 'is_admin_logged_in';
  static const String adminEmail = 'admin@ieltsuniversity.com';
  static const String adminPassword = 'adminpassword123';

  @override
  bool build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getBool(_authKey) ?? false;
  }

  bool login(String email, String password) {
    if (email == adminEmail && password == adminPassword) {
      ref.read(sharedPreferencesProvider).setBool(_authKey, true);
      state = true;
      return true;
    }
    return false;
  }

  void logout() {
    ref.read(sharedPreferencesProvider).setBool(_authKey, false);
    state = false;
  }
}
