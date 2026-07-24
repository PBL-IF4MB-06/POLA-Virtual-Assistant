import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_service.dart';

class SupabaseProfile {
  const SupabaseProfile({
    required this.id,
    required this.email,
    this.displayName,
    this.username,
    this.avatarUrl,
    required this.role,
  });

  final String id;
  final String email;
  final String? displayName;
  final String? username;
  final String? avatarUrl;
  final String role;

  bool get isAdmin => role == 'admin';

  factory SupabaseProfile.fromRow(Map<String, dynamic> row) {
    return SupabaseProfile(
      id: row['id'] as String,
      email: row['email'] as String? ?? '',
      displayName: row['display_name'] as String?,
      username: row['username'] as String?,
      avatarUrl: row['avatar_url'] as String?,
      role: row['role'] as String? ?? 'user',
    );
  }
}

class SupabaseProfileRepository {
  const SupabaseProfileRepository();

  SupabaseClient get _db => SupabaseService.client;

  Future<SupabaseProfile?> fetchCurrent() async {
    final uid = _db.auth.currentUser?.id;
    if (uid == null) return null;

    final row = await _db
        .from('profiles')
        .select()
        .eq('id', uid)
        .maybeSingle();
    if (row == null) return null;
    return SupabaseProfile.fromRow(row);
  }

  /// Membuat profil + pengaturan default jika trigger DB belum jalan.
  Future<void> ensureCurrentProfile() async {
    final user = _db.auth.currentUser;
    if (user == null) return;

    final meta = user.userMetadata ?? {};
    final email = user.email ?? '';
    final displayName = (meta['full_name'] as String?)?.trim() ??
        (meta['name'] as String?)?.trim() ??
        (email.isNotEmpty ? email.split('@').first : 'User');

    final existing = await _db
        .from('profiles')
        .select('id')
        .eq('id', user.id)
        .maybeSingle();

    if (existing == null) {
      await _db.from('profiles').insert({
        'id': user.id,
        'email': email,
        'display_name': displayName,
        'role': 'user',
      });
    }

    final settings = await _db
        .from('user_settings')
        .select('user_id')
        .eq('user_id', user.id)
        .maybeSingle();

    if (settings == null) {
      await _db.from('user_settings').insert({'user_id': user.id});
    }
  }

  Future<void> updateProfile({
    String? displayName,
    String? username,
    String? avatarUrl,
  }) async {
    final uid = _db.auth.currentUser?.id;
    if (uid == null) return;

    final patch = <String, dynamic>{};
    if (displayName != null) patch['display_name'] = displayName.trim();
    if (username != null) patch['username'] = username.trim();
    if (avatarUrl != null) patch['avatar_url'] = avatarUrl.trim();
    if (patch.isEmpty) return;

    await _db.from('profiles').update(patch).eq('id', uid);
  }

  Future<void> grantAdmin(String email) async {
    await _db.rpc('grant_admin_by_email', params: {'target_email': email.trim()});
  }

  Future<void> revokeAdmin(String email) async {
    await _db.rpc('revoke_admin_by_email', params: {'target_email': email.trim()});
  }

  Future<Map<String, dynamic>> loadSettings() async {
    final uid = _db.auth.currentUser?.id;
    if (uid == null) return {};

    final row = await _db
        .from('user_settings')
        .select('settings')
        .eq('user_id', uid)
        .maybeSingle();
    final raw = row?['settings'];
    if (raw is Map<String, dynamic>) return raw;
    return {};
  }

  Future<void> saveSettings(Map<String, dynamic> settings) async {
    final uid = _db.auth.currentUser?.id;
    if (uid == null) return;

    await _db.from('user_settings').upsert({
      'user_id': uid,
      'settings': settings,
    });
  }
}
