import 'package:flutter/foundation.dart';

/// Jika [configured] kosong dan app dijalankan dalam **debug**, pakai server lokal
/// (`cd server && npm start`, port 8787) supaya AI jalan tanpa isi manual dulu.
String aiBackendUrlOrDevDefault(String configured) {
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
