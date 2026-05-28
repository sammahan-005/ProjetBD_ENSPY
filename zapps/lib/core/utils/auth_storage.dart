import 'package:shared_preferences/shared_preferences.dart';
import 'package:zapps/core/api/api_constants.dart';

/// Stockage des credentials (shared_preferences).
/// Note: pour une production mobile avec données sensibles,
/// envisager flutter_secure_storage une fois le conflit GLib résolu.
class AuthStorage {
  static Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  static Future<void> saveToken(String token) async {
    final prefs = await _prefs;
    await prefs.setString(kTokenKey, token);
  }

  static Future<void> saveUserId(int userId) async {
    final prefs = await _prefs;
    await prefs.setInt(kUserIdKey, userId);
  }

  static Future<String?> getToken() async {
    final prefs = await _prefs;
    return prefs.getString(kTokenKey);
  }

  static Future<int?> getUserId() async {
    final prefs = await _prefs;
    return prefs.getInt(kUserIdKey);
  }

  static Future<bool> hasToken() async {
    final prefs = await _prefs;
    final token = prefs.getString(kTokenKey);
    return token != null && token.isNotEmpty;
  }

  static Future<void> clear() async {
    final prefs = await _prefs;
    await prefs.remove(kTokenKey);
    await prefs.remove(kUserIdKey);
  }
}
