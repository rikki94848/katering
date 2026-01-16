import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const _kToken = 'token';
  static const _kRole = 'role';
  static const _kApproved = 'approved';
  static const _kName = 'name';

  static Future<void> saveSession({required String token, required String role, required bool approved, required String name}) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kToken, token);
    await sp.setString(_kRole, role);
    await sp.setBool(_kApproved, approved);
    await sp.setString(_kName, name);
  }

  static Future<Map<String, dynamic>?> loadSession() async {
    final sp = await SharedPreferences.getInstance();
    final token = sp.getString(_kToken);
    if (token == null) return null;
    return {
      'token': token,
      'role': sp.getString(_kRole) ?? 'client',
      'approved': sp.getBool(_kApproved) ?? false,
      'name': sp.getString(_kName) ?? '',
    };
  }

  static Future<void> clear() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_kToken);
    await sp.remove(_kRole);
    await sp.remove(_kApproved);
    await sp.remove(_kName);
  }
}
