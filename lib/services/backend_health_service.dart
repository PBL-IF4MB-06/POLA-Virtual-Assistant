import 'package:http/http.dart' as http;

import '../config/ai_backend.dart';

/// Cek ketersediaan backend AI POLA (`GET /health`).
class BackendHealthService {
  static Future<bool> isOnline() async {
    final base = aiBackendBaseUrl().trim();
    if (base.isEmpty) return false;
    try {
      final uri = Uri.parse(base.endsWith('/') ? '${base}health' : '$base/health');
      final res = await http.get(uri).timeout(const Duration(seconds: 4));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
