import 'package:flutter/material.dart';

import '../app/app_state_scope.dart';
import '../state/auth_state.dart';
import '../widgets/password_reset_dialog.dart';
import '../widgets/premium_auth_widgets.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    this.initialLoginMode = true,
  });

  final bool initialLoginMode;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();
  late bool _isLoginMode;
  late final AnimationController _entrance;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  bool _obscure = true;
  bool _submitted = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _isLoginMode = widget.initialLoginMode;
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    _fade = CurvedAnimation(parent: _entrance, curve: Curves.easeOutCubic);
    _slide = Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero).animate(
      CurvedAnimation(parent: _entrance, curve: Curves.easeOutCubic),
    );
    _entrance.forward();
  }

  @override
  void dispose() {
    _entrance.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  AuthState get _auth => AppStateScope.of(context).auth;

  Future<void> _onSuccess() async {
    await AppStateScope.of(context).chat.loadFromStorage();
    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selamat datang, ${_auth.displayName}!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
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
      if (!_auth.isLoggedIn) {
        _showError('Gagal masuk. Periksa email/kata sandi atau konfirmasi email Anda.');
        return;
      }
      await _onSuccess();
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
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: PremiumAuthBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 16, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      style: IconButton.styleFrom(
                        backgroundColor: cs.surface.withValues(alpha: 0.65),
                      ),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                    ),
                    const Spacer(),
                    Text(
                      _isLoginMode ? 'Masuk' : 'Daftar',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                  child: Center(
                    child: FadeTransition(
                      opacity: _fade,
                      child: SlideTransition(
                        position: _slide,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 440),
                          child: PremiumAuthCard(
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
                              showGoogle: _auth.isGoogleSignInAvailable,
                              onForgotPassword: () => showPasswordResetDialog(context),
                              onGuest: () {
                                _auth.continueAsGuest();
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
