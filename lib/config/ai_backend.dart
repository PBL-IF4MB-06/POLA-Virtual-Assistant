import 'package:flutter/foundation.dart';

/// Base URL backend AI yang dipakai app (tanpa UI Settings).
///
/// - Bisa dioverride lewat `--dart-define=POLA_BACKEND_URL=http://...`
/// - Saat debug, default otomatis:
///   - Web/Windows/macOS/Linux/iOS: `http://127.0.0.1:8787`
///   - Android emulator: `http://10.0.2.2:8787`
String aiBackendBaseUrl() {
  const configured = String.fromEnvironment('POLA_BACKEND_URL');
  final c = configured.trim();
  if (c.isNotEmpty) return c;
  if (!kDebugMode) return '';
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

