import 'env_config.dart';

/// OAuth 2.0 client IDs dari [Google Cloud Console](https://console.cloud.google.com/apis/credentials).
///
/// Isi di `.env` (disarankan) atau `--dart-define`:
/// ```
/// GOOGLE_WEB_CLIENT_ID=xxx.apps.googleusercontent.com
/// GOOGLE_SERVER_CLIENT_ID=xxx.apps.googleusercontent.com
/// ```
abstract final class GoogleOauthConfig {
  static String get webClientId => EnvConfig.get(
        'GOOGLE_WEB_CLIENT_ID',
        compileTimeDefault: const String.fromEnvironment(
          'GOOGLE_WEB_CLIENT_ID',
          defaultValue: '',
        ),
      );

  static String get serverClientId => EnvConfig.get(
        'GOOGLE_SERVER_CLIENT_ID',
        compileTimeDefault: const String.fromEnvironment(
          'GOOGLE_SERVER_CLIENT_ID',
          defaultValue: '',
        ),
      );

  static bool get isConfigured =>
      webClientId.trim().isNotEmpty || serverClientId.trim().isNotEmpty;
}
