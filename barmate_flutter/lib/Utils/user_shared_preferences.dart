import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static SharedPreferences? _preferences;

  static const String _loginKey = 'login';
  static const String _userId = 'user_id';

  static Future init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  static Future setUserName(String userName) async {
    await _preferences?.setString(_loginKey, userName);
  }

  static Future setId(String id) async {
    await _preferences?.setString(_userId, id);
  }

  String getUserName() => _preferences?.getString(_loginKey) ?? '';
  

  String getUserId() => _preferences?.getString(_userId) ?? '';

   static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
  
}