import 'package:supabase_flutter/supabase_flutter.dart';

import '../admin_kb_store.dart';
import 'supabase_service.dart';

class SupabaseKbRepository {
  const SupabaseKbRepository();

  SupabaseClient get _db => SupabaseService.client;

  Future<List<AdminKbEntry>> loadEntries() async {
    final rows = await _db
        .from('kb_entries')
        .select()
        .eq('is_published', true)
        .order('updated_at', ascending: false);

    return rows
        .map(
          (r) => AdminKbEntry(
            id: r['id'] as String,
            question: r['question'] as String? ?? '',
            answer: r['answer'] as String? ?? '',
          ),
        )
        .where((e) => e.question.trim().isNotEmpty && e.answer.trim().isNotEmpty)
        .toList();
  }

  Future<void> saveEntries(List<AdminKbEntry> entries) async {
    final existingRows = await _db.from('kb_entries').select('id');
    final existingIds = existingRows.map((r) => r['id'] as String).toSet();
    final incomingIds = entries.map((e) => e.id).toSet();

    for (final oldId in existingIds.difference(incomingIds)) {
      await _db.from('kb_entries').delete().eq('id', oldId);
    }

    final uid = _db.auth.currentUser?.id;
    for (final e in entries) {
      final payload = {
        'question': e.question.trim(),
        'answer': e.answer.trim(),
        'is_published': true,
        if (uid != null) 'created_by': uid,
      };

      if (existingIds.contains(e.id)) {
        await _db.from('kb_entries').update(payload).eq('id', e.id);
      } else {
        await _db.from('kb_entries').insert({
          'id': e.id,
          ...payload,
        });
      }
    }
  }
}
