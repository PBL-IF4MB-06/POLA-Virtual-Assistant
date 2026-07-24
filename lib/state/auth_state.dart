import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../config/google_oauth_config.dart';
import '../services/supabase/supabase_profile_repository.dart';
import '../services/supabase/supabase_service.dart';

class AuthState extends ChangeNotifier {
  static const _kUsers = 'pola_auth_users_v7';
  static const _kActiveEmail = 'pola_auth_active_email_v7';
  static const _kAdmins = 'pola_auth_admins_v1';

  static const oauthGooglePasswordPlaceholder = '__oauth_google__';

  /// Deep link OAuth callback untuk Android/iOS (daftarkan di Supabase Dashboard).
  static const mobileOAuthRedirect = 'ac.id.polibatam.pola://login-callback/';

  static const List<String> _googleScopes = <String>[
    'email',
    'https://www.googleapis.com/auth/userinfo.profile',
  ];

  static const String demoAdminEmail = 'admin@pola.app';
  static const String demoAdminPassword = 'admin12345';
  static const String supabaseAdminEmail = 'admin@polibatam.ac.id';
  static const String supabaseAdminPassword = 'AdminPola2026!';

  bool _isLoggedIn = false;
  String? _displayName;
  String? _email;
  String? _userId;
  final Map<String, String> _users = {};
  final Set<String> _admins = <String>{};
  bool _sessionUsedGoogle = false;
  bool _supabaseIsAdmin = false;
  GoogleSignIn? _googleSignInCache;
  StreamSubscription<sb.AuthState>? _authSub;

  bool get isLoggedIn => _isLoggedIn;
  String get displayName => _displayName ?? 'Guest';
  String get email => _email ?? 'guest@pola.app';
  String? get userId => _userId;
  bool get usesSupabase => SupabaseService.isReady;
  bool get isAdmin {
    if (!_isLoggedIn) return false;
    if (_supabaseIsAdmin) return true;
    return _admins.contains(_normalizeEmail(email));
  }

  String get authBackendLabel => SupabaseService.isReady
      ? 'Supabase Cloud'
      : SupabaseService.isConfigured
          ? 'Lokal (Supabase gagal init)'
          : 'Lokal';

  /// Google sign-in hanya jika OAuth client ID sudah dikonfigurasi.
  bool get isGoogleSignInAvailable => GoogleOauthConfig.isConfigured;

  Future<void> load() async {
    await _loadLocalUsers();

    if (SupabaseService.isReady) {
      await _authSub?.cancel();
      _authSub = SupabaseService.client.auth.onAuthStateChange.listen((data) {
        final user = data.session?.user;
        if (data.event == sb.AuthChangeEvent.signedIn && user != null) {
          unawaited(_hydrateFromSupabase(user));
          final provider = user.appMetadata['provider']?.toString() ?? '';
          _sessionUsedGoogle = provider.contains('google');
        } else if (data.event == sb.AuthChangeEvent.signedOut) {
          // Jangan hapus sesi lokal saat Supabase tidak punya session cloud.
          if (_userId != null) {
            _continueAsGuestInternal(persist: false);
          }
        }
      });

      final session = SupabaseService.client.auth.currentSession;
      if (session?.user != null) {
        await _hydrateFromSupabase(session!.user);
      } else {
        await _restoreLocalSession();
      }
      return;
    }

    await _restoreLocalSession();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  static String oauthRedirectUrl() {
    if (kIsWeb) {
      final base = Uri.base;
      var path = base.path.isEmpty ? '/' : base.path;
      if (!path.endsWith('/')) path = '$path/';
      return '${base.origin}$path';
    }
    return mobileOAuthRedirect;
  }

  static String _oauthRedirectUrl() => oauthRedirectUrl();

  Future<void> _loadLocalUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final rawUsers = prefs.getStringList(_kUsers) ?? const <String>[];
    _users
      ..clear()
      ..addEntries(
        rawUsers
            .map((e) => e.split('|'))
            .where((p) => p.length == 2)
            .map((p) => MapEntry(_normalizeEmail(p[0]), p[1])),
      );

    _admins
      ..clear()
      ..addAll(
        (prefs.getStringList(_kAdmins) ?? const <String>[])
            .map(_normalizeEmail),
      );

    _users[demoAdminEmail] = demoAdminPassword;
    await prefs.setStringList(
      _kUsers,
      _users.entries.map((e) => '${e.key}|${e.value}').toList(),
    );
    if (!_admins.contains(demoAdminEmail)) {
      _admins.add(demoAdminEmail);
      await prefs.setStringList(_kAdmins, _admins.toList()..sort());
    }
  }

  Future<void> _restoreLocalSession() async {
    final prefs = await SharedPreferences.getInstance();
    final active = prefs.getString(_kActiveEmail);
    final activeKey = active == null ? null : _normalizeEmail(active);
    if (activeKey != null &&
        activeKey.isNotEmpty &&
        _users.containsKey(activeKey)) {
      final storedPass = _users[activeKey];
      _sessionUsedGoogle = storedPass == oauthGooglePasswordPlaceholder;
      _setLoggedInInternal(activeKey, persist: false);
    } else {
      _continueAsGuestInternal(persist: false);
    }
  }

  bool _tryLocalLogin(String email, String password) {
    final key = _normalizeEmail(email);
    final stored = _users[key];
    if (stored == null || stored != password) return false;
    _sessionUsedGoogle = stored == oauthGooglePasswordPlaceholder;
    unawaited(_setLoggedInInternal(key, persist: true));
    return true;
  }

  Future<bool> _tryLocalLoginAsync(String email, String password) async {
    final key = _normalizeEmail(email);
    final stored = _users[key];
    if (stored == null || stored != password) return false;
    _sessionUsedGoogle = stored == oauthGooglePasswordPlaceholder;
    await _setLoggedInInternal(key, persist: true);
    return true;
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

  static bool get _isMobileNative =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  Future<String?> _loginWithGoogleSupabase() async {
    try {
      // Android/iOS + serverClientId: native Google Sign-In (lebih stabil).
      final canUseNative = _isMobileNative &&
          GoogleOauthConfig.serverClientId.trim().isNotEmpty;

      if (canUseNative) {
        return _loginWithGoogleNativeSupabase();
      }

      // Web atau mobile tanpa native config: OAuth redirect via Supabase.
      await SupabaseService.client.auth.signInWithOAuth(
        sb.OAuthProvider.google,
        redirectTo: _oauthRedirectUrl(),
        queryParams: const {'prompt': 'select_account'},
        authScreenLaunchMode: kIsWeb
            ? LaunchMode.platformDefault
            : LaunchMode.externalApplication,
      );
      return null;
    } on sb.AuthException catch (e) {
      debugPrint('loginWithGoogle AuthException: ${e.message}');
      return 'Gagal masuk Google: ${e.message}';
    } catch (e, st) {
      debugPrint('loginWithGoogle Supabase failed: $e\n$st');
      final msg = e.toString();
      if (msg.contains('ApiException: 10') || msg.contains('sign_in_failed')) {
        return 'Google Sign-In gagal (konfigurasi).\n\n'
            'Pastikan:\n'
            '1. Provider Google aktif di Supabase Dashboard\n'
            '2. GOOGLE_SERVER_CLIENT_ID di .env\n'
            '3. SHA-1 debug/release terdaftar di Google Cloud Console';
      }
      return 'Gagal masuk dengan Google. Periksa koneksi internet dan konfigurasi OAuth.';
    }
  }

  Future<String?> _loginWithGoogleNativeSupabase() async {
    if (!GoogleOauthConfig.isConfigured) {
      return 'Google Sign-In belum dikonfigurasi.\n\n'
          'Isi GOOGLE_SERVER_CLIENT_ID di .env (Web Client ID dari Google Cloud), '
          'dan aktifkan provider Google di Supabase Dashboard.';
    }

    final account = await _googleSignIn().signIn();
    if (account == null) return 'Masuk dengan Google dibatalkan.';

    final auth = await account.authentication;
    final idToken = auth.idToken;
    if (idToken == null || idToken.isEmpty) {
      return 'Token Google tidak tersedia.\n\n'
          'Pastikan SHA-1 APK terdaftar di Google Cloud Console '
          'dan GOOGLE_SERVER_CLIENT_ID sudah benar.';
    }

    await SupabaseService.client.auth.signInWithIdToken(
      provider: sb.OAuthProvider.google,
      idToken: idToken,
      accessToken: auth.accessToken,
    );

    final user = SupabaseService.client.auth.currentUser;
    if (user == null) return 'Gagal masuk dengan Google via Supabase.';
    await _hydrateFromSupabase(user);
    _sessionUsedGoogle = true;
    return null;
  }

  Future<String?> _loginWithGoogleLocal() async {
    if (!GoogleOauthConfig.isConfigured) {
      if (kIsWeb) {
        return 'OAuth Google belum dikonfigurasi. Isi GOOGLE_WEB_CLIENT_ID di .env '
            '(lihat lib/config/google_oauth_config.dart).';
      }
      if (_isMobileNative) {
        return 'Google Sign-In belum dikonfigurasi.\n\n'
            'Isi GOOGLE_SERVER_CLIENT_ID di .env (Web Client ID dari Google Cloud) '
            'dan daftarkan SHA-1 APK di Google Cloud Console.';
      }
      return 'OAuth Google belum dikonfigurasi. Isi GOOGLE_WEB_CLIENT_ID di .env.';
    }
    try {
      final account = await _googleSignIn().signIn();
      if (account == null) return 'Masuk dengan Google dibatalkan.';

      final email = _normalizeEmail(account.email);
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

  Future<String?> _completeSupabaseSession(sb.AuthResponse res) async {
    final user = res.user ?? SupabaseService.client.auth.currentUser;
    final session = res.session ?? SupabaseService.client.auth.currentSession;
    if (user == null || session == null) {
      return 'Gagal masuk. Session tidak tersedia — coba lagi.';
    }
    try {
      await const SupabaseProfileRepository().ensureCurrentProfile();
    } catch (e, st) {
      debugPrint('ensureCurrentProfile after auth: $e\n$st');
    }
    await _hydrateFromSupabase(user);
    _sessionUsedGoogle = false;
    if (!_isLoggedIn) {
      return 'Gagal memuat profil pengguna. Coba masuk lagi.';
    }
    return null;
  }

  /// `null` = sukses, selain itu pesan error (Bahasa Indonesia).
  Future<String?> loginWithPassword({
    required String email,
    required String password,
  }) async {
    final key = _normalizeEmail(email);

    // Prioritas akun lokal (demo admin / register offline).
    if (await _tryLocalLoginAsync(key, password)) {
      return null;
    }

    if (SupabaseService.isReady) {
      try {
        final res = await SupabaseService.client.auth.signInWithPassword(
          email: key,
          password: password,
        );
        return await _completeSupabaseSession(res);
      } on sb.AuthException catch (e) {
        debugPrint('loginWithPassword AuthException: ${e.message}');
        SupabaseService.markAuthUnreachable();
        if (_isNetworkAuthError(e)) {
          return _networkAuthMessage();
        }
        return _mapSupabaseAuthError(e);
      } catch (e, st) {
        debugPrint('loginWithPassword Supabase: $e\n$st');
        SupabaseService.markAuthUnreachable();
        if (_isNetworkAuthError(e)) {
          return _networkAuthMessage();
        }
        return 'Gagal masuk. Periksa koneksi internet.';
      }
    }

    return 'Email atau kata sandi salah.';
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
      } on sb.AuthException catch (e) {
        debugPrint('register AuthException: ${e.message}');
        SupabaseService.markAuthUnreachable();
        if (_isNetworkAuthError(e) || _shouldFallbackRegisterToLocal(e)) {
          return _registerLocal(key, password);
        }
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
        SupabaseService.markAuthUnreachable();
        return _registerLocal(key, password);
      }
    }

    return _registerLocal(key, password);
  }

  Future<String?> _registerLocal(String key, String password) async {
    if (_users.containsKey(key)) {
      return 'Email sudah terdaftar. Gunakan tab Masuk.';
    }
    _sessionUsedGoogle = false;
    _users[key] = password;
    await _persistUsersAsync();
    await _setLoggedInInternal(key, persist: true);
    return null;
  }

  static bool _shouldTryLocalFallback(sb.AuthException e) {
    final msg = e.message.toLowerCase();
    return msg.contains('invalid login') ||
        msg.contains('invalid credentials') ||
        msg.contains('wrong password') ||
        msg.contains('user not found');
  }

  static bool _isNetworkAuthError(Object e) {
    final msg = '${e is sb.AuthException ? e.message : e}'.toLowerCase();
    return msg.contains('failed to fetch') ||
        msg.contains('clientexception') ||
        msg.contains('socketexception') ||
        msg.contains('network') ||
        msg.contains('connection refused') ||
        msg.contains('connection error') ||
        msg.contains('host lookup') ||
        msg.contains('name could not be resolved') ||
        msg.contains('handshake') ||
        msg.contains('timed out');
  }

  static String _networkAuthMessage() =>
      'Tidak dapat terhubung ke Supabase.\n\n'
      'Periksa koneksi internet atau URL project di file .env. '
      'Untuk demo offline, gunakan akun lokal: admin@pola.app / admin12345';

  static bool _shouldFallbackRegisterToLocal(sb.AuthException e) {
    final msg = e.message.toLowerCase();
    return (msg.contains('signup') && msg.contains('disabled')) ||
        (msg.contains('signups') && msg.contains('disabled')) ||
        msg.contains('rate') ||
        msg.contains('too many') ||
        msg.contains('429');
  }

  static String _mapSupabaseAuthError(sb.AuthException e) {
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

  Future<String?> requestPasswordReset(String email) async {
    final key = email.trim();
    if (key.isEmpty || !_looksLikeEmail(key)) {
      return 'Masukkan alamat email yang valid.';
    }

    if (SupabaseService.isReady) {
      try {
        await SupabaseService.client.auth.resetPasswordForEmail(key);
        return null;
      } on sb.AuthException catch (e) {
        return e.message;
      } catch (_) {
        return 'Gagal mengirim email reset. Coba lagi.';
      }
    }

    return 'Reset password via email membutuhkan konfigurasi Supabase.\n'
        'Untuk akun demo lokal, hubungi admin atau buat akun baru.';
  }

  static bool _looksLikeEmail(String s) =>
      RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(s);

  Future<bool> changePassword({
    required String email,
    required String oldPassword,
    required String newPassword,
  }) async {
    final key = _normalizeEmail(email);
    if (key.isEmpty || newPassword.isEmpty) return false;

    if (SupabaseService.isReady) {
      try {
        await SupabaseService.client.auth.updateUser(
          sb.UserAttributes(password: newPassword),
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
    final e = _normalizeEmail(email);
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
    final e = _normalizeEmail(email);
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

  Future<void> _hydrateFromSupabase(sb.User user) async {
    _isLoggedIn = true;
    _userId = user.id;
    _email = _normalizeEmail(user.email ?? '');
    final meta = user.userMetadata ?? {};
    _displayName = (meta['full_name'] as String?)?.trim() ??
        (meta['name'] as String?)?.trim() ??
        (_email!.isNotEmpty ? _email!.split('@').first : 'User');

    _supabaseIsAdmin = false;
    try {
      var profile = await const SupabaseProfileRepository().fetchCurrent();
      if (profile == null) {
        await const SupabaseProfileRepository().ensureCurrentProfile();
        profile = await const SupabaseProfileRepository().fetchCurrent();
      }
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
    unawaited(_setLoggedInInternal(email, persist: true));
  }

  Future<void> _setLoggedInInternal(
    String email, {
    required bool persist,
    String? displayName,
  }) async {
    final key = _normalizeEmail(email);
    if (key.isEmpty) return;
    _isLoggedIn = true;
    _email = key;
    _userId = null;
    _supabaseIsAdmin = false;
    final dn = displayName?.trim();
    _displayName =
        (dn != null && dn.isNotEmpty) ? dn : key.split('@').first;
    notifyListeners();
    if (persist) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kActiveEmail, key);
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
