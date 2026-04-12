import 'package:flutter_test/flutter_test.dart';
import 'package:pola_app/main.dart';

void main() {
  testWidgets('Menampilkan halaman POLA dan input chat', (tester) async {
    await tester.pumpWidget(const POLAApp());
    await tester.pumpAndSettle();

    // Masuk ke tab Chat (v7)
    await tester.tap(find.text('Chat'));
    await tester.pumpAndSettle();

    // Pastikan hint input tampil
    expect(find.text('Tulis pesan...'), findsOneWidget);
  });
}

