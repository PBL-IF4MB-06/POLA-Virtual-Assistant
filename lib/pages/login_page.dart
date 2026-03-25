import 'package:flutter/material.dart';

import '../app/app_state_scope.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();
  bool _isLoginMode = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = AppStateScope.of(context).auth;

    return Scaffold(
      appBar: AppBar(
        title: const Text('POLA Login (Opsional)'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight - 32),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary.withOpacity(0.9),
                            Theme.of(context).colorScheme.secondary.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircleAvatar(
                            radius: 26,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.school, size: 30),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'POLA - Polibatam Assistant',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Login untuk sinkron riwayat chat.\nBisa lanjut sebagai tamu juga.',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: Colors.white70),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ChoiceChip(
                                  label: const Text('Login'),
                                  selected: _isLoginMode,
                                  onSelected: (v) =>
                                      setState(() => _isLoginMode = true),
                                ),
                                const SizedBox(width: 8),
                                ChoiceChip(
                                  label: const Text('Register'),
                                  selected: !_isLoginMode,
                                  onSelected: (v) =>
                                      setState(() => _isLoginMode = false),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _email,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                hintText: 'nama@polibatam.ac.id',
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _password,
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: 'Password',
                              ),
                            ),
                            if (!_isLoginMode) ...[
                              const SizedBox(height: 12),
                              TextField(
                                controller: _confirmPassword,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  labelText: 'Konfirmasi Password',
                                ),
                              ),
                            ],
                            const SizedBox(height: 16),
                            FilledButton(
                              onPressed: () {
                                final email = _email.text.trim();
                                final pass = _password.text;
                                if (email.isEmpty || pass.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Email dan password tidak boleh kosong.',
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                if (_isLoginMode) {
                                  final ok = auth.loginWithPassword(
                                    email: email,
                                    password: pass,
                                  );
                                  if (!ok) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Email atau password salah.',
                                        ),
                                      ),
                                    );
                                    return;
                                  }
                                } else {
                                  if (_confirmPassword.text != pass) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Konfirmasi password tidak cocok.',
                                        ),
                                      ),
                                    );
                                    return;
                                  }
                                  final ok = auth.register(
                                    email: email,
                                    password: pass,
                                  );
                                  if (!ok) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Registrasi gagal. Email mungkin sudah terdaftar.',
                                        ),
                                      ),
                                    );
                                    return;
                                  }
                                }

                                Navigator.of(context).pop();
                              },
                              child: Text(_isLoginMode ? 'Login' : 'Register'),
                            ),
                            const SizedBox(height: 8),
                            OutlinedButton(
                              onPressed: () {
                                auth.continueAsGuest();
                                Navigator.of(context).pop();
                              },
                              child: const Text('Lanjut sebagai Tamu'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

