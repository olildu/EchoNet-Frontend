import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String keyToken = "access_token";
  static const String keyUserId = "user_id";
  static const String keyRole = "user_role";
  static const String keyFullName = "full_name"; // NEW

  // Save session data after successful login or registration
  Future<void> saveSession(String token, String userId, String role, String fullName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyToken, token);
    await prefs.setString(keyUserId, userId);
    await prefs.setString(keyRole, role);
    await prefs.setString(keyFullName, fullName); // NEW
  }

  Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyRole);
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyUserId);
  }

  // NEW: Retrieve Name
  Future<String?> getFullName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyFullName);
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
