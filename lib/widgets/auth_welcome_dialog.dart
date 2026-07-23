import 'package:flutter/material.dart';

import '../app/app_state_scope.dart';
import '../state/auth_state.dart';
import '../widgets/password_reset_dialog.dart';
import '../widgets/premium_auth_widgets.dart';

/// Popup sambutan auth saat app dibuka dan pengguna belum login.
Future<void> showAuthWelcomeDialog(BuildContext context) async {
  final auth = AppStateScope.of(context).auth;
  if (auth.isLoggedIn) return;

  await showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Tutup',
    barrierColor: Colors.black.withValues(alpha: 0.58),
    transitionDuration: const Duration(milliseconds: 360),
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
          scale: Tween<double>(begin: 0.9, end: 1).animate(curved),
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selamat datang, ${_auth.displayName}!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
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
      if (err != null) {
        _showError(err);
        return;
      }
      if (_auth.isLoggedIn) {
        await _onSuccess();
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.errorContainer,
      ),
    );
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
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: Material(
        color: Colors.transparent,
        child: PremiumAuthCard(
          showClose: true,
          onClose: widget.onDismiss,
          isLoginMode: _isLoginMode,
          child: PremiumAuthForm(
            formKey: _formKey,
            isLoginMode: _isLoginMode,
            onModeChanged: _switchMode,
            emailController: _email,
            passwordController: _password,
            confirmPasswordController: _confirmPassword,
            obscurePassword: _obscure,
            onToggleObscure: () => setState(() => _obscure = !_obscure),
            submitted: _submitted,
            busy: _busy,
            onSubmit: _submit,
            onGoogleSignIn: _signInWithGoogle,
            showGoogle: true,
            onForgotPassword: () => showPasswordResetDialog(context),
            onGuest: () {
              _auth.continueAsGuest();
              widget.onDismiss();
            },
          ),
        ),
      ),
    );
  }
}
