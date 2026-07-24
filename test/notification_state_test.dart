import 'package:flutter_test/flutter_test.dart';
import 'package:pola_app/state/notification_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('markAsRead dan markAsUnread persisten', () async {
    final state = NotificationState();
    await state.load();

    expect(state.isRead('a1'), isFalse);
    expect(state.unreadCount(['a1', 'a2']), 2);

    await state.markAsRead('a1');
    expect(state.isRead('a1'), isTrue);
    expect(state.unreadCount(['a1', 'a2']), 1);

    await state.markAllAsRead(['a1', 'a2']);
    expect(state.unreadCount(['a1', 'a2']), 0);

    await state.markAsUnread('a2');
    expect(state.isRead('a2'), isFalse);
    expect(state.unreadCount(['a1', 'a2']), 1);

    final state2 = NotificationState();
    await state2.load();
    expect(state2.isRead('a1'), isTrue);
    expect(state2.isRead('a2'), isFalse);
  });
}
