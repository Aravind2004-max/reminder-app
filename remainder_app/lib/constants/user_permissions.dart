import 'package:shared_preferences/shared_preferences.dart';

class OEMPermissionCheck {
  static final String _isInstalled = "isInstalled";

  static Future<bool> installationCheck() async {
    final localStorage = await SharedPreferences.getInstance();
    return localStorage.getBool(_isInstalled) ?? true;
  }

  static Future<void> markAsInstalled() async {
    final localStorage = await SharedPreferences.getInstance();
    localStorage.setBool('isInstalled', false);
  }
}
