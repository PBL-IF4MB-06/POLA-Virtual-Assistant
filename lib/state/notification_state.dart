import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Status baca pengumuman kampus (persisten).
class NotificationState extends ChangeNotifier {
  static const _kReadIds = 'pola_notification_read_v8';

  final Set<String> _readIds = {};

  bool isRead(String id) => _readIds.contains(id);

  int unreadCount(Iterable<String> allIds) =>
      allIds.where((id) => !_readIds.contains(id)).length;

  bool hasUnread(Iterable<String> allIds) => unreadCount(allIds) > 0;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _readIds
      ..clear()
      ..addAll(prefs.getStringList(_kReadIds) ?? const []);
    notifyListeners();
  }

  Future<void> markAsRead(String id) async {
    if (id.isEmpty || _readIds.contains(id)) return;
    _readIds.add(id);
    notifyListeners();
    await _persist();
  }

  Future<void> markAllAsRead(Iterable<String> ids) async {
    var changed = false;
    for (final id in ids) {
      if (id.isEmpty || _readIds.contains(id)) continue;
      _readIds.add(id);
      changed = true;
    }
    if (!changed) return;
    notifyListeners();
    await _persist();
  }

  Future<void> markAsUnread(String id) async {
    if (id.isEmpty || !_readIds.contains(id)) return;
    _readIds.remove(id);
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kReadIds, _readIds.toList()..sort());
  }
}
