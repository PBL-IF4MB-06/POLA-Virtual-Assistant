import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pola_app/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'pola_onboarding_done_v8': true,
    });
  });

  testWidgets('Menampilkan splash POLA Chatbot', (tester) async {
    await tester.pumpWidget(const POLAApp());

    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (find.text('POLA Chatbot').evaluate().isNotEmpty) break;
    }

    expect(find.text('POLA Chatbot'), findsOneWidget);
    expect(find.text('Politeknik Negeri Batam'), findsOneWidget);
    expect(find.text('Chatbot AI Berbasis Mobile'), findsOneWidget);

    // Selesaikan timer navigasi splash agar tidak ada pending timer.
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });
}
