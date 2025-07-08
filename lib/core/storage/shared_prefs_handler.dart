import 'package:shared_preferences/shared_preferences.dart';

/// Singleton class for handling shared preferences (token management)
class SharedPrefsHandler {
  static final SharedPrefsHandler _instance = SharedPrefsHandler._internal();
  factory SharedPrefsHandler() => _instance;
  SharedPrefsHandler._internal();

  static const String _tokenKey = 'user_token';

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}
