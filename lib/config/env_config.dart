import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Memuat `.env` di root proyek (opsional).
/// Nilai di `.env` menang atas `--dart-define` jika keduanya diisi.
abstract final class EnvConfig {
  static bool _loaded = false;

  static Future<void> load() async {
    if (_loaded) return;
    try {
      await dotenv.load(fileName: '.env');
    } catch (_) {
      // .env tidak wajib — app tetap jalan mode lokal.
    }
    _loaded = true;
  }

  static String get(String key, {String compileTimeDefault = ''}) {
    final fromFile = dotenv.maybeGet(key)?.trim();
    if (fromFile != null && fromFile.isNotEmpty) return fromFile;
    return compileTimeDefault.trim();
  }
}
