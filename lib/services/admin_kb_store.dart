import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AdminKbStore {
  const AdminKbStore();

  // Keep compatible with existing AdminPage storage.
  static const String key = 'pola_admin_kb_entries_v1';

  Future<List<AdminKbEntry>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(key) ?? const <String>[];
    final out = <AdminKbEntry>[];
    for (final s in raw) {
      try {
        final j = jsonDecode(s) as Map<String, dynamic>;
        final e = AdminKbEntry.fromJson(j);
        if (e.id.isNotEmpty && e.question.trim().isNotEmpty && e.answer.trim().isNotEmpty) {
          out.add(e);
        }
      } catch (_) {}
    }
    return out;
  }

  Future<void> save(List<AdminKbEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = entries.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(key, raw);
  }
}

class AdminKbEntry {
  const AdminKbEntry({
    required this.id,
    required this.question,
    required this.answer,
  });

  final String id;
  final String question;
  final String answer;

  Map<String, Object?> toJson() => {
        'id': id,
        'q': question,
        'a': answer,
      };

  factory AdminKbEntry.fromJson(Map<String, dynamic> json) {
    return AdminKbEntry(
      id: (json['id'] as String?) ?? '',
      question: (json['q'] as String?) ?? '',
      answer: (json['a'] as String?) ?? '',
    );
  }
}

