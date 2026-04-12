import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthState extends ChangeNotifier {
  static const _kUsers = 'pola_auth_users_v7'; // email|password
  static const _kActiveEmail = 'pola_auth_active_email_v7';
  static const _kAdmins = 'pola_auth_admins_v1'; // list of admin emails

  // Demo-only bootstrap admin (local auth).
  static const String demoAdminEmail = 'admin@pola.app';
  static const String demoAdminPassword = 'admin12345';

  bool _isLoggedIn = false;
  String? _displayName;
  String? _email;
  final Map<String, String> _users = {};
  final Set<String> _admins = <String>{};

  bool get isLoggedIn => _isLoggedIn;
  String get displayName => _displayName ?? 'Guest';
  String get email => _email ?? 'guest@pola.app';
  bool get isAdmin => _isLoggedIn && _admins.contains(email);

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

    _admins
      ..clear()
      ..addAll(prefs.getStringList(_kAdmins) ?? const <String>[]);

    // Ensure there is at least one admin account available for demo.
    // Always enforce demo admin password so login can't get "stuck" on old data.
    _users[demoAdminEmail] = demoAdminPassword;
    await prefs.setStringList(
      _kUsers,
      _users.entries.map((e) => '${e.key}|${e.value}').toList(),
    );
    if (!_admins.contains(demoAdminEmail)) {
      _admins.add(demoAdminEmail);
      await prefs.setStringList(_kAdmins, _admins.toList()..sort());
    }

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

  bool changePassword({
    required String email,
    required String oldPassword,
    required String newPassword,
  }) {
    final key = email.trim();
    if (key.isEmpty) return false;
    final stored = _users[key];
    if (stored == null || stored != oldPassword) return false;
    if (newPassword.isEmpty) return false;
    _users[key] = newPassword;
    _persistUsers();
    return true;
  }

  Future<void> grantAdmin(String email) async {
    final e = email.trim();
    if (e.isEmpty) return;
    _admins.add(e);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kAdmins, _admins.toList()..sort());
  }

  Future<void> revokeAdmin(String email) async {
    final e = email.trim();
    if (e.isEmpty) return;
    _admins.remove(e);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kAdmins, _admins.toList()..sort());
  }

  void _setLoggedIn(String email) {
    _setLoggedInInternal(email, persist: true);
  }

  void _setLoggedInInternal(String email, {required bool persist}) {
    if (email.isEmpty) return;
    _isLoggedIn = true;
    _email = email;
    _displayName = email.split('@').first;
    // First-time bootstrap: jika belum ada admin sama sekali, jadikan akun pertama admin.
    if (_admins.isEmpty) {
      _admins.add(email);
      SharedPreferences.getInstance()
          .then((p) => p.setStringList(_kAdmins, _admins.toList()..sort()));
    }
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
