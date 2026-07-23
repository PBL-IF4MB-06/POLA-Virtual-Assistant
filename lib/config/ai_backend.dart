import 'package:flutter/foundation.dart';

import 'env_config.dart';

/// Base URL backend AI yang dipakai app (tanpa UI Settings).
///
/// Prioritas:
/// 1. `--dart-define=POLA_BACKEND_URL=http://...` (saat build release)
/// 2. File `.env` (dibundel ke APK/installer — isi sebelum `flutter build`)
/// 3. Default debug per platform
/// 4. Release desktop: `http://127.0.0.1:8787` (server jalan di PC yang sama)
String aiBackendBaseUrl() {
  const configured = String.fromEnvironment('POLA_BACKEND_URL');
  final fromDefine = configured.trim();
  if (fromDefine.isNotEmpty) return fromDefine;

  final fromEnv = EnvConfig.get('POLA_BACKEND_URL');
  if (fromEnv.isNotEmpty) return fromEnv;

  if (kDebugMode) {
    if (kIsWeb) return 'http://127.0.0.1:8787';
    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
        return 'http://127.0.0.1:8787';
      case TargetPlatform.android:
        return 'http://10.0.2.2:8787';
      case TargetPlatform.iOS:
        return 'http://127.0.0.1:8787';
      default:
        return '';
    }
  }

  // Release web: pakai origin halaman (website + proxy API di server yang sama).
  if (kIsWeb) {
    final origin = Uri.base.origin;
    if (origin.isNotEmpty) return origin;
    return 'http://127.0.0.1:8787';
  }
  switch (defaultTargetPlatform) {
    case TargetPlatform.windows:
    case TargetPlatform.linux:
    case TargetPlatform.macOS:
      return 'http://127.0.0.1:8787';
    default:
      return '';
  }
}

