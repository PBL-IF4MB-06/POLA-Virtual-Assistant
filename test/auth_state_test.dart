import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pola_app/state/auth_state.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('register logs in and persists session', () async {
    final auth = AuthState();
    await auth.load();

    final ok = auth.register(email: 'user@polibatam.ac.id', password: 'pass123');
    expect(ok, true);
    expect(auth.isLoggedIn, true);
    expect(auth.email, 'user@polibatam.ac.id');

    final auth2 = AuthState();
    await auth2.load();
    expect(auth2.isLoggedIn, true);
    expect(auth2.email, 'user@polibatam.ac.id');
  });

  test('login with wrong password fails', () async {
    final auth = AuthState();
    await auth.load();
    auth.register(email: 'a@b.com', password: 'x');

    final ok = auth.loginWithPassword(email: 'a@b.com', password: 'wrong');
    expect(ok, false);
  });
}

