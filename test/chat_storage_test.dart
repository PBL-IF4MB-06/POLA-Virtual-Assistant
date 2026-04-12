import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pola_app/models/chat_message.dart';
import 'package:pola_app/models/conversation.dart';
import 'package:pola_app/services/chat_storage.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('save/load conversations preserves messages', () async {
    final storage = ChatStorage();
    final convo = Conversation(id: '1', title: 'New chat', messages: [
      ChatMessage(
        id: 'm1',
        sender: Sender.user,
        text: 'hello',
        createdAt: DateTime.parse('2026-01-01T00:00:00Z'),
      ),
      ChatMessage(
        id: 'm2',
        sender: Sender.bot,
        text: 'hi',
        sources: const [ChatSource(title: 'Src', excerpt: 'Ex', url: 'https://x')],
        createdAt: DateTime.parse('2026-01-01T00:00:01Z'),
      ),
    ]);

    await storage.save([convo], '1');
    final (loaded, activeId) = await storage.load();
    expect(activeId, '1');
    expect(loaded, isNotEmpty);
    expect(loaded.first.messages.length, 2);
    expect(loaded.first.messages.last.sources.first.url, 'https://x');
  });
}

