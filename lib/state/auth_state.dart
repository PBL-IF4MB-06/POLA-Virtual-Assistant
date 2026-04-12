import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/google_oauth_config.dart';

class AuthState extends ChangeNotifier {
  static const _kUsers = 'pola_auth_users_v7'; // email|password
  static const _kActiveEmail = 'pola_auth_active_email_v7';
  static const _kAdmins = 'pola_auth_admins_v1'; // list of admin emails

  /// Sentinel password for accounts created only via Google Sign-In (OAuth 2.0).
  static const oauthGooglePasswordPlaceholder = '__oauth_google__';

  static const List<String> _googleScopes = <String>[
    'email',
    'https://www.googleapis.com/auth/userinfo.profile',
  ];

  // Demo-only bootstrap admin (local auth).
  static const String demoAdminEmail = 'admin@pola.app';
  static const String demoAdminPassword = 'admin12345';

  bool _isLoggedIn = false;
  String? _displayName;
  String? _email;
  final Map<String, String> _users = {};
  final Set<String> _admins = <String>{};
  bool _sessionUsedGoogle = false;
  GoogleSignIn? _googleSignInCache;

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
      final storedPass = _users[active];
      _sessionUsedGoogle = storedPass == oauthGooglePasswordPlaceholder;
      _setLoggedInInternal(active, persist: false);
    } else {
      _continueAsGuestInternal(persist: false);
    }
  }

  void continueAsGuest() {
    _sessionUsedGoogle = false;
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
    _sessionUsedGoogle = false;
    _setLoggedIn(email.trim());
  }

  GoogleSignIn _googleSignIn() {
    return _googleSignInCache ??= GoogleSignIn(
      scopes: _googleScopes,
      clientId: _googleOAuthClientId(),
      serverClientId: GoogleOauthConfig.serverClientId.isNotEmpty
          ? GoogleOauthConfig.serverClientId
          : null,
    );
  }

  /// Web / desktop: OAuth **Web client** ID. Android / iOS: prefer [GoogleOauthConfig.serverClientId].
  static String? _googleOAuthClientId() {
    final id = GoogleOauthConfig.webClientId;
    if (id.isEmpty) return null;
    if (kIsWeb) return id;
    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
        return id;
      default:
        return null;
    }
  }

  /// Returns `null` on success, or a short Indonesian error message.
  Future<String?> loginWithGoogle() async {
    if (kIsWeb && GoogleOauthConfig.webClientId.isEmpty) {
      return 'OAuth web belum dikonfigurasi. Jalankan aplikasi dengan '
          '--dart-define=GOOGLE_WEB_CLIENT_ID=... (lihat lib/config/google_oauth_config.dart).';
    }
    try {
      final account = await _googleSignIn().signIn();
      if (account == null) {
        return 'Masuk dengan Google dibatalkan.';
      }
      final email = account.email.trim();
      if (email.isEmpty) {
        return 'Akun Google tidak menyediakan alamat email.';
      }
      if (!_users.containsKey(email)) {
        _users[email] = oauthGooglePasswordPlaceholder;
        await _persistUsersAsync();
      }
      final dn = account.displayName?.trim();
      _setLoggedInInternal(
        email,
        persist: true,
        displayName: (dn != null && dn.isNotEmpty) ? dn : null,
      );
      _sessionUsedGoogle = true;
      return null;
    } catch (e, st) {
      debugPrint('loginWithGoogle failed: $e\n$st');
      return 'Gagal masuk dengan Google. Pastikan OAuth client ID sudah benar '
          'dan SHA-1 / bundle ID sudah didaftarkan di Google Cloud Console.';
    }
  }

  Future<void> logout() async {
    if (_sessionUsedGoogle) {
      try {
        await _googleSignIn().signOut();
      } catch (e, st) {
        debugPrint('Google signOut: $e\n$st');
      }
      _sessionUsedGoogle = false;
    }
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
    _sessionUsedGoogle = false;
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
    _sessionUsedGoogle = false;
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

  void _setLoggedInInternal(
    String email, {
    required bool persist,
    String? displayName,
  }) {
    if (email.isEmpty) return;
    _isLoggedIn = true;
    _email = email;
    final dn = displayName?.trim();
    _displayName =
        (dn != null && dn.isNotEmpty) ? dn : email.split('@').first;
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

  Future<void> _persistUsersAsync() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _users.entries.map((e) => '${e.key}|${e.value}').toList();
    await prefs.setStringList(_kUsers, list);
  }
}
