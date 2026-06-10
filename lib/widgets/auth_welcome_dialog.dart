import 'dart:ui';

import 'package:flutter/material.dart';

import '../app/app_state_scope.dart';
import '../state/auth_state.dart';
import '../ui/theme/pola_tokens.dart';
import 'pola_logo.dart';

/// Popup sambutan auth saat app dibuka dan pengguna belum login.
Future<void> showAuthWelcomeDialog(BuildContext context) async {
  final auth = AppStateScope.of(context).auth;
  if (auth.isLoggedIn) return;

  await showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Tutup',
    barrierColor: Colors.black.withValues(alpha: 0.55),
    transitionDuration: const Duration(milliseconds: 320),
    pageBuilder: (dialogContext, _, __) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
          child: AuthWelcomeDialog(onDismiss: () => Navigator.of(dialogContext).pop()),
        ),
      );
    },
    transitionBuilder: (context, anim, _, child) {
      final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.92, end: 1).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class AuthWelcomeDialog extends StatefulWidget {
  const AuthWelcomeDialog({super.key, required this.onDismiss});

  final VoidCallback onDismiss;

  @override
  State<AuthWelcomeDialog> createState() => _AuthWelcomeDialogState();
}

class _AuthWelcomeDialogState extends State<AuthWelcomeDialog> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();

  bool _isLoginMode = true;
  bool _obscure = true;
  bool _submitted = false;
  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  AuthState get _auth => AppStateScope.of(context).auth;

  Future<void> _onSuccess() async {
    await AppStateScope.of(context).chat.loadFromStorage();
    if (!mounted) return;
    widget.onDismiss();
  }

  Future<void> _submit() async {
    setState(() => _submitted = true);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _busy = true);
    try {
      final email = _email.text.trim();
      final pass = _password.text;

      final err = _isLoginMode
          ? await _auth.loginWithPassword(email: email, password: pass)
          : await _auth.register(email: email, password: pass);
      if (!mounted) return;
      if (err != null) {
        _showError(err);
        return;
      }
      await _onSuccess();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _busy = true);
    try {
      final err = await _auth.loginWithGoogle();
      if (!mounted) return;
      if (err == null) {
        await _onSuccess();
      } else {
        _showError(err);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _switchMode(bool login) {
    if (_isLoginMode == login) return;
    setState(() {
      _isLoginMode = login;
      _submitted = false;
      _confirmPassword.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: Material(
        color: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                color: cs.surface.withValues(alpha: isDark ? 0.88 : 0.94),
                border: Border.all(
                  color: cs.outlineVariant.withValues(alpha: 0.35),
                ),
                boxShadow: PolaTokens.softShadow(Colors.black),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _Header(
                    cs: cs,
                    isDark: isDark,
                    onClose: widget.onDismiss,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 44, 22, 22),
                    child: Form(
                      key: _formKey,
                      autovalidateMode: _submitted
                          ? AutovalidateMode.onUserInteraction
                          : AutovalidateMode.disabled,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _ModeTabs(
                            isLoginMode: _isLoginMode,
                            onChanged: _switchMode,
                          ),
                          const SizedBox(height: 18),
                          _AuthField(
                            controller: _email,
                            label: 'Email',
                            hint: 'nama@polibatam.ac.id',
                            icon: Icons.mail_outline_rounded,
                            keyboardType: TextInputType.emailAddress,
                            autofillHints: const [AutofillHints.email],
                            validator: (v) {
                              final s = (v ?? '').trim();
                              if (s.isEmpty) return 'Email wajib diisi.';
                              if (!_looksLikeEmail(s)) {
                                return 'Format email tidak valid.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          _AuthField(
                            controller: _password,
                            label: 'Kata Sandi',
                            icon: Icons.lock_outline_rounded,
                            obscure: _obscure,
                            autofillHints: const [AutofillHints.password],
                            onToggleObscure: () =>
                                setState(() => _obscure = !_obscure),
                            validator: (v) {
                              final s = v ?? '';
                              if (s.isEmpty) return 'Kata sandi wajib diisi.';
                              if (!_isLoginMode && s.length < 8) {
                                return 'Minimal 8 karakter.';
                              }
                              return null;
                            },
                          ),
                          AnimatedCrossFade(
                            firstChild: const SizedBox.shrink(),
                            secondChild: Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: _AuthField(
                                controller: _confirmPassword,
                                label: 'Konfirmasi Kata Sandi',
                                icon: Icons.lock_person_outlined,
                                obscure: _obscure,
                                validator: (v) {
                                  final s = v ?? '';
                                  if (s.isEmpty) {
                                    return 'Konfirmasi kata sandi wajib diisi.';
                                  }
                                  if (s != _password.text) {
                                    return 'Konfirmasi tidak cocok.';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            crossFadeState: _isLoginMode
                                ? CrossFadeState.showFirst
                                : CrossFadeState.showSecond,
                            duration: const Duration(milliseconds: 220),
                            sizeCurve: Curves.easeOutCubic,
                          ),
                          if (_isLoginMode) ...[
                            const SizedBox(height: 4),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 0,
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                onPressed: _busy ? null : () => _forgotPassword(context),
                                child: Text(
                                  'Lupa kata sandi?',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelMedium
                                      ?.copyWith(color: cs.primary),
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: _busy ? null : _submit,
                            style: FilledButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: _busy
                                ? SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: cs.onPrimary,
                                    ),
                                  )
                                : Text(
                                    _isLoginMode ? 'Masuk' : 'Buat Akun',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: cs.outlineVariant.withValues(alpha: 0.6),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  'atau',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(color: cs.onSurfaceVariant),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: cs.outlineVariant.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          OutlinedButton.icon(
                            onPressed: _busy ? null : _signInWithGoogle,
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(46),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              side: BorderSide(
                                color: cs.outlineVariant.withValues(alpha: 0.7),
                              ),
                            ),
                            icon: const _GoogleMark(),
                            label: const Text('Lanjutkan dengan Google'),
                          ),
                          const SizedBox(height: 10),
                          TextButton(
                            onPressed: _busy
                                ? null
                                : () {
                                    _auth.continueAsGuest();
                                    widget.onDismiss();
                                  },
                            child: Text(
                              'Lanjut sebagai Tamu',
                              style: TextStyle(
                                color: cs.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.cs,
    required this.isDark,
    required this.onClose,
  });

  final ColorScheme cs;
  final bool isDark;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(22, 28, 22, 52),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                cs.primary.withValues(alpha: isDark ? 0.35 : 0.55),
                cs.primary.withValues(alpha: isDark ? 0.12 : 0.18),
              ],
            ),
          ),
          child: Column(
            children: [
              Text(
                'Selamat datang',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.75),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'POLA Assistant',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                      color: cs.onSurface,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Asisten virtual Polibatam — simpan riwayat chat & fitur penuh.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.72),
                      height: 1.35,
                    ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 10,
          right: 10,
          child: IconButton(
            tooltip: 'Tutup',
            onPressed: onClose,
            style: IconButton.styleFrom(
              backgroundColor: cs.surface.withValues(alpha: 0.5),
            ),
            icon: Icon(Icons.close_rounded, color: cs.onSurfaceVariant, size: 20),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: -36,
          child: Center(
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: cs.primary.withValues(alpha: 0.35),
                    blurRadius: 24,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: cs.surface,
                  border: Border.all(
                    color: cs.primary.withValues(alpha: 0.45),
                    width: 2,
                  ),
                ),
                child: const PolaLogo(size: 64),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ModeTabs extends StatelessWidget {
  const _ModeTabs({required this.isLoginMode, required this.onChanged});

  final bool isLoginMode;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          _TabChip(
            label: 'Masuk',
            selected: isLoginMode,
            onTap: () => onChanged(true),
          ),
          _TabChip(
            label: 'Daftar',
            selected: !isLoginMode,
            onTap: () => onChanged(false),
          ),
        ],
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({
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
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: selected ? cs.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: cs.primary.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: onTap,
            child: Center(
              child: Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: selected ? cs.onPrimary : cs.onSurfaceVariant,
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthField extends StatelessWidget {
  const _AuthField({
    required this.controller,
    required this.label,
    required this.icon,
    this.hint,
    this.obscure = false,
    this.keyboardType,
    this.autofillHints,
    this.onToggleObscure,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData icon;
  final bool obscure;
  final TextInputType? keyboardType;
  final Iterable<String>? autofillHints;
  final VoidCallback? onToggleObscure;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      autofillHints: autofillHints,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20, color: cs.onSurfaceVariant),
        suffixIcon: onToggleObscure == null
            ? null
            : IconButton(
                tooltip: obscure ? 'Tampilkan' : 'Sembunyikan',
                onPressed: onToggleObscure,
                icon: Icon(
                  obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 20,
                ),
              ),
        filled: true,
        fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.45),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: cs.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: cs.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }
}

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

bool _looksLikeEmail(String s) {
  return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(s);
}

Future<void> _forgotPassword(BuildContext context) async {
  await showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: const Text('Lupa kata sandi'),
      content: const Text(
        'Reset password via email belum tersedia.\n\n'
        'Buat akun baru atau hubungi admin jika perlu bantuan.',
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
