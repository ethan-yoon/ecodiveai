import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static Future<void> saveUserData(String name, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', name);
    await prefs.setString('userEmail', email);
  }

  static Future<void> loadUserData({required Function(String?, String?) onLoaded}) async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('userName');
    final email = prefs.getString('userEmail');
    onLoaded(name, email);
  }

  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userName');
    await prefs.remove('userEmail');
  }
}