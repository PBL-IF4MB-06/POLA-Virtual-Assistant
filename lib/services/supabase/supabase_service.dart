import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/supabase_config.dart';

class SupabaseService {
  const SupabaseService._();

  static bool _initialized = false;
  static bool _initFailed = false;

  static bool get isConfigured => SupabaseConfig.isConfigured;
  static bool get isReady => _initialized && isConfigured && !_initFailed;
  static bool get initFailed => _initFailed;

  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    if (!isConfigured) return;
    if (_initialized) return;

    try {
      await Supabase.initialize(
        url: SupabaseConfig.url.trim(),
        publishableKey: SupabaseConfig.publishableKey.trim(),
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce,
          detectSessionInUri: true,
        ),
      );
      final reachable = await _verifyReachable();
      if (!reachable) {
        _initFailed = true;
        _initialized = false;
        debugPrint(
          'Supabase tidak terjangkau (${SupabaseConfig.url}) — mode lokal aktif.',
        );
        return;
      }
      _initialized = true;
      _initFailed = false;
      await _recoverOAuthSessionFromUrl();
    } catch (e, st) {
      _initFailed = true;
      _initialized = false;
      debugPrint('Supabase initialize failed — mode lokal aktif: $e\n$st');
    }
  }

  static void markAuthUnreachable() {
    if (!_initialized) return;
    _initFailed = true;
    _initialized = false;
    debugPrint('Supabase auth gagal — beralih ke mode lokal.');
  }

  static Future<bool> _verifyReachable() async {
    try {
      final base = SupabaseConfig.url.trim().replaceAll(RegExp(r'/+$'), '');
      final uri = Uri.parse('$base/auth/v1/health');
      final res = await http.get(uri).timeout(const Duration(seconds: 6));
      return res.statusCode >= 200 && res.statusCode < 500;
    } catch (e, st) {
      debugPrint('Supabase reachability check failed: $e\n$st');
      return false;
    }
  }

  static Future<void> _recoverOAuthSessionFromUrl() async {
    if (!kIsWeb) return;
    try {
      final uri = Uri.base;
      if (!uri.hasQuery) return;
      final hasAuthParams = uri.queryParameters.containsKey('code') ||
          uri.fragment.contains('access_token') ||
          uri.queryParameters.containsKey('access_token');
      if (!hasAuthParams) return;
      await Supabase.instance.client.auth.getSessionFromUrl(uri);
    } catch (e, st) {
      debugPrint('OAuth session recovery skipped: $e\n$st');
    }
  }
}