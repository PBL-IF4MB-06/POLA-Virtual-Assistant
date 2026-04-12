import 'package:flutter/material.dart';

import '../app/app_state_scope.dart';
import '../state/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();
  bool _isLoginMode = true; // true = Masuk, false = Daftar
  bool _obscure = true;
  bool _submitted = false;
  bool _googleBusy = false;

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
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text(''),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(46),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: _ModeTabs(
              isLoginMode: _isLoginMode,
              onChanged: (v) => setState(() => _isLoginMode = v),
            ),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        autovalidateMode:
            _submitted ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'nama@polibatam.ac.id',
              ),
              validator: (v) {
                final s = (v ?? '').trim();
                if (s.isEmpty) return 'Email wajib diisi.';
                if (!_looksLikeEmail(s)) return 'Format email tidak valid.';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _password,
              obscureText: _obscure,
              autofillHints: const [AutofillHints.password],
              decoration: InputDecoration(
                labelText: 'Kata Sandi',
                helperText: _isLoginMode ? null : 'Minimal 8 karakter.',
                suffixIcon: IconButton(
                  tooltip: _obscure ? 'Show' : 'Hide',
                  onPressed: () => setState(() => _obscure = !_obscure),
                  icon: Icon(
                    _obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
              validator: (v) {
                final s = (v ?? '');
                if (s.isEmpty) return 'Kata sandi wajib diisi.';
                if (!_isLoginMode && s.length < 8) return 'Minimal 8 karakter.';
                return null;
              },
              onFieldSubmitted: (_) => _submit(auth),
            ),
            if (_isLoginMode) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => _forgotPassword(context),
                  child: const Text('Lupa kata sandi?'),
                ),
              ),
            ],
            if (!_isLoginMode) ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _confirmPassword,
                obscureText: _obscure,
                decoration: const InputDecoration(
                  labelText: 'Konfirmasi Kata Sandi',
                ),
                validator: (v) {
                  final s = (v ?? '');
                  if (s.isEmpty) return 'Konfirmasi kata sandi wajib diisi.';
                  if (s != _password.text) return 'Konfirmasi tidak cocok.';
                  return null;
                },
              ),
            ],
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _googleBusy ? null : () => _submit(auth),
                child: Text(_isLoginMode ? 'Masuk' : 'Daftar'),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(child: Divider(color: Theme.of(context).colorScheme.outlineVariant)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'atau',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ),
                Expanded(child: Divider(color: Theme.of(context).colorScheme.outlineVariant)),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _googleBusy ? null : () => _signInWithGoogle(auth),
                icon: _googleBusy
                    ? SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      )
                    : const _GoogleMark(),
                label: Text(_googleBusy ? 'Menghubungkan…' : 'Lanjutkan dengan Google'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _googleBusy
                        ? null
                        : () {
                            auth.continueAsGuest();
                            Navigator.of(context).pop();
                          },
                    child: const Text('Lanjut sebagai Tamu'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.center,
              child: TextButton(
                onPressed: () => setState(() => _isLoginMode = !_isLoginMode),
                child: Text(
                  _isLoginMode ? 'Belum punya akun? Daftar' : 'Sudah punya akun? Masuk',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _signInWithGoogle(AuthState auth) async {
    setState(() => _googleBusy = true);
    try {
      final err = await auth.loginWithGoogle();
      if (!mounted) return;
      if (err == null) {
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      }
    } finally {
      if (mounted) setState(() => _googleBusy = false);
    }
  }

  void _submit(AuthState auth) {
    setState(() => _submitted = true);
    final okForm = _formKey.currentState?.validate() ?? false;
    if (!okForm) return;

    final email = _email.text.trim();
    final pass = _password.text;

    if (_isLoginMode) {
      final ok = auth.loginWithPassword(email: email, password: pass);
      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email atau password salah.')),
        );
        return;
      }
    } else {
      final ok = auth.register(email: email, password: pass);
      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registrasi gagal. Email mungkin sudah terdaftar.')),
        );
        return;
      }
    }

    Navigator.of(context).pop();
  }
}

bool _looksLikeEmail(String s) {
  return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(s);
}

Future<void> _forgotPassword(BuildContext context) async {
  await showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Lupa kata sandi'),
      content: const Text(
        'Untuk versi demo ini, reset password belum terhubung ke email.\n\n'
        'Kalau kamu lupa, kamu bisa buat akun baru atau minta admin reset secara manual.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Tutup'),
        ),
      ],
    ),
  );
}

class _ModeTabs extends StatelessWidget {
  const _ModeTabs({required this.isLoginMode, required this.onChanged});

  final bool isLoginMode;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      height: 42,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: cs.surface.withValues(alpha: 0.82),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.45)),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: _TabButton(
              label: 'Masuk',
              selected: isLoginMode,
              onTap: () => onChanged(true),
            ),
          ),
          Expanded(
            child: _TabButton(
              label: 'Daftar',
              selected: !isLoginMode,
              onTap: () => onChanged(false),
            ),
          ),
        ],
      ),
    );
  }
}

/// Minimal “G” mark (OAuth / Google Sign-In). Replace with an official asset if needed.
class _GoogleMark extends StatelessWidget {
  const _GoogleMark();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'G',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: Color(0xFF4285F4),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: selected ? cs.primary : Colors.transparent,
        ),
        child: Center(
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: selected ? cs.onPrimary : cs.onSurfaceVariant,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ),
      ),
    );
  }
}

