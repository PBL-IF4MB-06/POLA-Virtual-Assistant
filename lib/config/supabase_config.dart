import 'env_config.dart';

/// Supabase: isi di `.env` (disarankan) atau `--dart-define`.
///
/// ```bash
/// cp .env.example .env   # lalu edit nilainya
/// flutter run
/// ```
class SupabaseConfig {
  const SupabaseConfig._();

  static String get url => EnvConfig.get(
        'SUPABASE_URL',
        compileTimeDefault: const String.fromEnvironment(
          'SUPABASE_URL',
          defaultValue: '',
        ),
      );

  static String get anonKey => EnvConfig.get(
        'SUPABASE_ANON_KEY',
        compileTimeDefault: const String.fromEnvironment(
          'SUPABASE_ANON_KEY',
          defaultValue: '',
        ),
      );

  static bool get isConfigured =>
      url.trim().isNotEmpty && anonKey.trim().isNotEmpty;
}
