import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  // Singleton instance
  static UserPreferences? _instance;
  SharedPreferences? _preferences;

  // Klucze preferencji
  static const String _loginKey = 'login';
  static const String _userId = 'user_id';
  static const String _userTitleKey = 'user_title';

  // Prywatny konstruktor dla wzorca Singleton
  UserPreferences._();

  // Fabryka dla tworzenia/zwracania instancji
  static Future<UserPreferences> getInstance() async {
    if (_instance == null) {
      _instance = UserPreferences._();
      await _instance!.init();
    } else if (_instance!._preferences == null) {
      await _instance!.init();
    }
    return _instance!;
  }

  // Metoda do zastąpienia instancji w testach
  static set instance(UserPreferences mockInstance) {
    _instance = mockInstance;
  }

  // Inicjalizacja preferencji
  Future<void> init() async {
    _preferences ??= await SharedPreferences.getInstance();
  }

  // Metody zapisujące dane
  Future<void> setUserName(String userName) async {
    await _preferences?.setString(_loginKey, userName);
  }

  Future<void> setUserId(String id) async {
    await _preferences?.setString(_userId, id);
  }

  Future<void> setUserTitle(String title) async {
    await _preferences?.setString(_userTitleKey, title);
  }

  // Metody odczytujące dane
  String getUserName() => _preferences?.getString(_loginKey) ?? '';
  String getUserId() => _preferences?.getString(_userId) ?? '';
  String? getUserTitle() => _preferences?.getString(_userTitleKey);

  // Czyszczenie preferencji
  Future<void> clear() async {
    await _preferences?.clear();
  }

  // Statyczna metoda do czyszczenia (kompatybilność wsteczna)
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
