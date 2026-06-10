import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'supabase/supabase_kb_repository.dart';
import 'supabase/supabase_service.dart';

const _uuid = Uuid();

class AdminKbStore {
  const AdminKbStore();

  static const String key = 'pola_admin_kb_entries_v1';

  bool get _useSupabase => SupabaseService.isReady;

  /// Baca FAQ dari cloud (tanpa login) untuk PolaBot.
  bool get _readFromSupabase => SupabaseService.isReady;

  Future<List<AdminKbEntry>> load() async {
    if (_readFromSupabase) {
      try {
        return await const SupabaseKbRepository().loadEntries();
      } catch (e, st) {
        debugPrint('AdminKbStore Supabase load gagal, fallback lokal: $e\n$st');
      }
    }

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(key) ?? const <String>[];
    final out = <AdminKbEntry>[];
    for (final s in raw) {
      try {
        final j = jsonDecode(s) as Map<String, dynamic>;
        final e = AdminKbEntry.fromJson(j);
        if (e.id.isNotEmpty &&
            e.question.trim().isNotEmpty &&
            e.answer.trim().isNotEmpty) {
          out.add(e);
        }
      } catch (_) {}
    }
    return out;
  }

  Future<void> save(List<AdminKbEntry> entries) async {
    if (_useSupabase && SupabaseService.client.auth.currentUser != null) {
      try {
        await const SupabaseKbRepository().saveEntries(entries);
        return;
      } catch (e, st) {
        debugPrint('AdminKbStore Supabase save gagal, fallback lokal: $e\n$st');
      }
    }

    final prefs = await SharedPreferences.getInstance();
    final raw = entries.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(key, raw);
  }

  static String newId() {
    if (SupabaseService.isReady) return _uuid.v4();
    return DateTime.now().microsecondsSinceEpoch.toString();
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
