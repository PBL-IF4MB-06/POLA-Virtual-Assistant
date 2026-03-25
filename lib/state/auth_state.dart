import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthState extends ChangeNotifier {
  static const _kUsers = 'pola_auth_users_v1'; // email|password
  static const _kActiveEmail = 'pola_auth_active_email_v1';

  bool _isLoggedIn = false;
  String? _displayName;
  String? _email;
  final Map<String, String> _users = {};

  bool get isLoggedIn => _isLoggedIn;
  String get displayName => _displayName ?? 'Guest';
  String get email => _email ?? 'guest@pola.app';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final rawUsers = prefs.getStringList(_kUsers) ?? const <String>[];
    _users
      ..clear()
      ..addEntries(
        rawUsers
            .map((e) => e.split('|'))
            .where((p) => p.length == 2)
            .map((p) => MapEntry(p[0], p[1])),
      );

    final active = prefs.getString(_kActiveEmail);
    if (active != null && active.isNotEmpty && _users.containsKey(active)) {
      _setLoggedInInternal(active, persist: false);
    } else {
      _continueAsGuestInternal(persist: false);
    }
  }

  void continueAsGuest() {
    _continueAsGuestInternal(persist: true);
  }

  void _continueAsGuestInternal({required bool persist}) {
    _isLoggedIn = false;
    _displayName = null;
    _email = null;
    notifyListeners();
    if (persist) {
      SharedPreferences.getInstance().then((p) => p.remove(_kActiveEmail));
    }
  }

  void login({required String email}) {
    _setLoggedIn(email.trim());
  }

  void logout() {
    continueAsGuest();
  }

  bool loginWithPassword({
    required String email,
    required String password,
  }) {
    final key = email.trim();
    final stored = _users[key];
    if (stored == null || stored != password) {
      return false;
    }
    _setLoggedInInternal(key, persist: true);
    return true;
  }

  bool register({
    required String email,
    required String password,
  }) {
    final key = email.trim();
    if (key.isEmpty || password.isEmpty) return false;
    if (_users.containsKey(key)) return false;
    _users[key] = password;
    _persistUsers();
    _setLoggedInInternal(key, persist: true);
    return true;
  }

  void _setLoggedIn(String email) {
    _setLoggedInInternal(email, persist: true);
  }

  void _setLoggedInInternal(String email, {required bool persist}) {
    if (email.isEmpty) return;
    _isLoggedIn = true;
    _email = email;
    _displayName = email.split('@').first;
    notifyListeners();
    if (persist) {
      SharedPreferences.getInstance()
          .then((p) => p.setString(_kActiveEmail, email));
    }
  }

  void _persistUsers() {
    SharedPreferences.getInstance().then((prefs) {
      final list = _users.entries.map((e) => '${e.key}|${e.value}').toList();
      prefs.setStringList(_kUsers, list);
    });
  }
}
