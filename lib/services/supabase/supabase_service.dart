import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/supabase_config.dart';

class SupabaseService {
  const SupabaseService._();

  static bool _initialized = false;

  static bool get isConfigured => SupabaseConfig.isConfigured;
  static bool get isReady => _initialized && isConfigured;

  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    if (!isConfigured) return;
    if (_initialized) return;

    await Supabase.initialize(
      url: SupabaseConfig.url.trim(),
      anonKey: SupabaseConfig.anonKey.trim(),
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
    _initialized = true;
  }
}
