import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/google_oauth_config.dart';
import '../services/supabase/supabase_profile_repository.dart';
import '../services/supabase/supabase_service.dart';

class AuthState extends ChangeNotifier {
  static const _kUsers = 'pola_auth_users_v7';
  static const _kActiveEmail = 'pola_auth_active_email_v7';
  static const _kAdmins = 'pola_auth_admins_v1';

  static const oauthGooglePasswordPlaceholder = '__oauth_google__';

  static const List<String> _googleScopes = <String>[
    'email',
    'https://www.googleapis.com/auth/userinfo.profile',
  ];

  static const String demoAdminEmail = 'admin@pola.app';
  static const String demoAdminPassword = 'admin12345';

  bool _isLoggedIn = false;
  String? _displayName;
  String? _email;
  String? _userId;
  final Map<String, String> _users = {};
  final Set<String> _admins = <String>{};
  bool _sessionUsedGoogle = false;
  bool _supabaseIsAdmin = false;
  GoogleSignIn? _googleSignInCache;

  bool get isLoggedIn => _isLoggedIn;
  String get displayName => _displayName ?? 'Guest';
  String get email => _email ?? 'guest@pola.app';
  String? get userId => _userId;
  bool get usesSupabase => SupabaseService.isReady;
  bool get isAdmin => _isLoggedIn &&
      (SupabaseService.isReady ? _supabaseIsAdmin : _admins.contains(email));

  Future<void> load() async {
    if (SupabaseService.isReady) {
      final session = SupabaseService.client.auth.currentSession;
      if (session?.user != null) {
        await _hydrateFromSupabase(session!.user);
      } else {
        _continueAsGuestInternal(persist: false);
      }
      return;
    }

    await _loadLocal();
  }

  Future<void> _loadLocal() async {
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
    _userId = null;
    _supabaseIsAdmin = false;
    notifyListeners();
    if (persist && !SupabaseService.isReady) {
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

  Future<String?> loginWithGoogle() async {
    if (SupabaseService.isReady) {
      return _loginWithGoogleSupabase();
    }
    return _loginWithGoogleLocal();
  }

  Future<String?> _loginWithGoogleSupabase() async {
    try {
      if (kIsWeb) {
        await SupabaseService.client.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: Uri.base.origin,
        );
        return null;
      }

      if (GoogleOauthConfig.webClientId.isEmpty &&
          GoogleOauthConfig.serverClientId.isEmpty) {
        return 'OAuth Google belum dikonfigurasi untuk Supabase.';
      }

      final account = await _googleSignIn().signIn();
      if (account == null) return 'Masuk dengan Google dibatalkan.';

      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null || idToken.isEmpty) {
        return 'Token Google tidak tersedia.';
      }

      await SupabaseService.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: auth.accessToken,
      );

      final user = SupabaseService.client.auth.currentUser;
      if (user == null) return 'Gagal masuk dengan Google via Supabase.';
      await _hydrateFromSupabase(user);
      _sessionUsedGoogle = true;
      return null;
    } catch (e, st) {
      debugPrint('loginWithGoogle Supabase failed: $e\n$st');
      return 'Gagal masuk dengan Google. Pastikan provider Google aktif di Supabase Dashboard.';
    }
  }

  Future<String?> _loginWithGoogleLocal() async {
    if (kIsWeb && GoogleOauthConfig.webClientId.isEmpty) {
      return 'OAuth web belum dikonfigurasi. Jalankan aplikasi dengan '
          '--dart-define=GOOGLE_WEB_CLIENT_ID=... (lihat lib/config/google_oauth_config.dart).';
    }
    try {
      final account = await _googleSignIn().signIn();
      if (account == null) return 'Masuk dengan Google dibatalkan.';

      final email = account.email.trim();
      if (email.isEmpty) return 'Akun Google tidak menyediakan alamat email.';

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
    if (SupabaseService.isReady) {
      try {
        await SupabaseService.client.auth.signOut();
      } catch (e, st) {
        debugPrint('Supabase signOut: $e\n$st');
      }
    }
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

  static String _normalizeEmail(String email) => email.trim().toLowerCase();

  Future<String?> _completeSupabaseSession(AuthResponse res) async {
    final user = res.user ?? SupabaseService.client.auth.currentUser;
    final session = res.session ?? SupabaseService.client.auth.currentSession;
    if (user == null || session == null) {
      return 'Gagal masuk. Session tidak tersedia — coba lagi.';
    }
    await _hydrateFromSupabase(user);
    _sessionUsedGoogle = false;
    return null;
  }

  /// `null` = sukses, selain itu pesan error (Bahasa Indonesia).
  Future<String?> loginWithPassword({
    required String email,
    required String password,
  }) async {
    if (SupabaseService.isReady) {
      final key = _normalizeEmail(email);
      try {
        final res = await SupabaseService.client.auth.signInWithPassword(
          email: key,
          password: password,
        );
        return await _completeSupabaseSession(res);
      } on AuthException catch (e) {
        debugPrint('loginWithPassword AuthException: ${e.message}');
        return _mapSupabaseAuthError(e);
      } catch (e, st) {
        debugPrint('loginWithPassword Supabase: $e\n$st');
        return 'Gagal masuk. Periksa koneksi internet.';
      }
    }

    final key = email.trim();
    final stored = _users[key];
    if (stored == null || stored != password) {
      return 'Email atau kata sandi salah.';
    }
    _sessionUsedGoogle = false;
    _setLoggedInInternal(key, persist: true);
    return null;
  }

  /// `null` = sukses & langsung masuk, selain itu pesan error / instruksi.
  Future<String?> register({
    required String email,
    required String password,
  }) async {
    final key = _normalizeEmail(email);
    if (key.isEmpty || password.isEmpty) {
      return 'Email dan kata sandi wajib diisi.';
    }

    if (SupabaseService.isReady) {
      try {
        final res = await SupabaseService.client.auth.signUp(
          email: key,
          password: password,
        );
        if (res.user == null) {
          return 'Registrasi gagal. Coba lagi.';
        }

        if (res.session != null) {
          return await _completeSupabaseSession(res);
        }

        // Confirm email OFF: signUp kadang tidak mengembalikan session — coba login langsung.
        final loginRes = await SupabaseService.client.auth.signInWithPassword(
          email: key,
          password: password,
        );
        return await _completeSupabaseSession(loginRes);
      } on AuthException catch (e) {
        debugPrint('register AuthException: ${e.message}');
        final mapped = _mapSupabaseAuthError(e);
        if (mapped.toLowerCase().contains('sudah terdaftar')) {
          return '$mapped\n\nGunakan tab Masuk dengan password yang sama.';
        }
        if (mapped.toLowerCase().contains('konfirmasi') ||
            mapped.toLowerCase().contains('confirmed')) {
          return '$mapped\n\n'
              'Atau jalankan SQL di supabase/confirm_user.sql lalu masuk lagi.';
        }
        return mapped;
      } catch (e, st) {
        debugPrint('register Supabase: $e\n$st');
        return 'Registrasi gagal. Periksa koneksi internet.';
      }
    }

    if (_users.containsKey(key)) {
      return 'Email sudah terdaftar.';
    }
    _sessionUsedGoogle = false;
    _users[key] = password;
    _persistUsers();
    _setLoggedInInternal(key, persist: true);
    return null;
  }

  static String _mapSupabaseAuthError(AuthException e) {
    final msg = (e.message).toLowerCase();
    if (msg.contains('confirm') ||
        msg.contains('verified') ||
        msg.contains('not confirmed')) {
      return 'Email belum dikonfirmasi. Buka link di inbox Anda, lalu coba masuk lagi.';
    }
    if (msg.contains('invalid login') ||
        msg.contains('invalid credentials') ||
        msg.contains('wrong password')) {
      return 'Email atau kata sandi salah.';
    }
    if (msg.contains('already registered') || msg.contains('already exists')) {
      return 'Email sudah terdaftar. Silakan masuk.';
    }
    if (msg.contains('password') && msg.contains('least')) {
      return 'Kata sandi terlalu pendek (minimal 6 karakter di Supabase).';
    }
    if (msg.contains('rate') ||
        msg.contains('too many') ||
        msg.contains('exceed') ||
        msg.contains('429')) {
      return 'Terlalu banyak percobaan email dari Supabase. '
          'Tunggu ~1 jam, atau nonaktifkan "Confirm email" di Dashboard Supabase, '
          'lalu konfirmasi akun manual lewat SQL Editor.';
    }
    if (msg.contains('signup') && msg.contains('disabled')) {
      return 'Pendaftaran email dimatikan di Supabase.\n\n'
          'Aktifkan di Dashboard → Authentication → Providers → Email → '
          'Enable Email provider + Enable sign ups.';
    }
    if (msg.contains('signups') && msg.contains('disabled')) {
      return 'Pendaftaran email dimatikan di Supabase.\n\n'
          'Aktifkan di Dashboard → Authentication → Providers → Email → '
          'Enable Email provider + Enable sign ups.';
    }
    return e.message;
  }

  Future<bool> changePassword({
    required String email,
    required String oldPassword,
    required String newPassword,
  }) async {
    final key = email.trim();
    if (key.isEmpty || newPassword.isEmpty) return false;

    if (SupabaseService.isReady) {
      try {
        await SupabaseService.client.auth.updateUser(
          UserAttributes(password: newPassword),
        );
        return true;
      } catch (_) {
        return false;
      }
    }

    final stored = _users[key];
    if (stored == null || stored != oldPassword) return false;
    _users[key] = newPassword;
    _persistUsers();
    return true;
  }

  Future<void> grantAdmin(String email) async {
    final e = email.trim();
    if (e.isEmpty) return;

    if (SupabaseService.isReady) {
      await const SupabaseProfileRepository().grantAdmin(e);
      return;
    }

    _admins.add(e);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kAdmins, _admins.toList()..sort());
  }

  Future<void> revokeAdmin(String email) async {
    final e = email.trim();
    if (e.isEmpty) return;

    if (SupabaseService.isReady) {
      await const SupabaseProfileRepository().revokeAdmin(e);
      return;
    }

    _admins.remove(e);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kAdmins, _admins.toList()..sort());
  }

  Future<void> reloadProfile() async {
    if (!SupabaseService.isReady || !_isLoggedIn) return;
    final user = SupabaseService.client.auth.currentUser;
    if (user == null) return;
    await _hydrateFromSupabase(user);
  }

  Future<void> _hydrateFromSupabase(User user) async {
    _isLoggedIn = true;
    _userId = user.id;
    _email = user.email ?? '';
    final meta = user.userMetadata ?? {};
    _displayName = (meta['full_name'] as String?)?.trim() ??
        (meta['name'] as String?)?.trim() ??
        (_email!.isNotEmpty ? _email!.split('@').first : 'User');

    _supabaseIsAdmin = false;
    try {
      final profile = await const SupabaseProfileRepository().fetchCurrent();
      if (profile != null) {
        if (profile.displayName?.trim().isNotEmpty == true) {
          _displayName = profile.displayName!.trim();
        }
        _supabaseIsAdmin = profile.isAdmin;
      }
    } catch (e, st) {
      debugPrint('fetch profile failed: $e\n$st');
    }

    notifyListeners();
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
