import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Keeps the signed-in employee's name on the device until they sign out.
class SessionStore extends ChangeNotifier {
  SessionStore._(this._prefs) : _employeeName = _prefs.getString(_key);

  static const _key = 'employee_name';

  final SharedPreferences _prefs;
  String? _employeeName;

  static Future<SessionStore> load() async =>
      SessionStore._(await SharedPreferences.getInstance());

  String? get employeeName => _employeeName;

  Future<void> signIn(String name) async {
    final trimmed = name.trim().replaceAll(RegExp(r'\s+'), ' ');
    await _prefs.setString(_key, trimmed);
    _employeeName = trimmed;
    notifyListeners();
  }

  Future<void> signOut() async {
    await _prefs.remove(_key);
    _employeeName = null;
    notifyListeners();
  }
}
