import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookmarkedAnswer {
  const BookmarkedAnswer({
    required this.messageId,
    required this.conversationTitle,
    required this.text,
    required this.savedAt,
  });

  final String messageId;
  final String conversationTitle;
  final String text;
  final DateTime savedAt;

  Map<String, Object?> toJson() => {
        'messageId': messageId,
        'conversationTitle': conversationTitle,
        'text': text,
        'savedAt': savedAt.toIso8601String(),
      };

  factory BookmarkedAnswer.fromJson(Map<String, Object?> json) {
    return BookmarkedAnswer(
      messageId: json['messageId'] as String? ?? '',
      conversationTitle: json['conversationTitle'] as String? ?? '',
      text: json['text'] as String? ?? '',
      savedAt: DateTime.tryParse(json['savedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

class BookmarkState extends ChangeNotifier {
  static const _kBookmarks = 'pola_bookmarks_v8';

  final List<BookmarkedAnswer> _items = [];

  List<BookmarkedAnswer> get items => List.unmodifiable(_items);

  bool isBookmarked(String messageId) =>
      _items.any((b) => b.messageId == messageId);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kBookmarks);
    _items.clear();
    if (raw != null) {
      try {
        final list = jsonDecode(raw) as List<dynamic>;
        for (final e in list) {
          if (e is Map<String, Object?>) {
            _items.add(BookmarkedAnswer.fromJson(e));
          }
        }
      } catch (_) {}
    }
    notifyListeners();
  }

  Future<void> toggle({
    required String messageId,
    required String conversationTitle,
    required String text,
  }) async {
    final idx = _items.indexWhere((b) => b.messageId == messageId);
    if (idx >= 0) {
      _items.removeAt(idx);
    } else {
      _items.insert(
        0,
        BookmarkedAnswer(
          messageId: messageId,
          conversationTitle: conversationTitle,
          text: text,
          savedAt: DateTime.now(),
        ),
      );
    }
    notifyListeners();
    await _persist();
  }

  Future<void> remove(String messageId) async {
    _items.removeWhere((b) => b.messageId == messageId);
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kBookmarks,
      jsonEncode(_items.map((b) => b.toJson()).toList()),
    );
  }
}
