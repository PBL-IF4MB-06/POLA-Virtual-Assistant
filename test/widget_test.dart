import 'package:flutter_test/flutter_test.dart';
import 'package:pola_app/main.dart';

void main() {
  testWidgets('Menampilkan halaman POLA dan input chat', (tester) async {
    await tester.pumpWidget(const POLAApp());
    await tester.pumpAndSettle();

    // Buka chat via bubble popup
    await tester.tap(find.byTooltip('Buka chat POLA'));
    await tester.pumpAndSettle();

    // Pastikan hint input tampil di popup chat
    expect(find.text('Tanyakan informasi kampus...'), findsOneWidget);
  });
}

