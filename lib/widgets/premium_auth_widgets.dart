import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../ui/theme/pola_colors.dart';
import '../ui/theme/pola_tokens.dart';
import 'pola_logo.dart';

/// Logo Google resmi (4 warna).
class GoogleLogo extends StatelessWidget {
  const GoogleLogo({super.key, this.size = 20});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _GoogleLogoPainter()),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    void arc(Color c, double start, double sweep) {
      final p = Paint()
        ..color = c
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.19
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(
        Rect.fromLTWH(w * 0.05, h * 0.05, w * 0.9, h * 0.9),
        start,
        sweep,
        false,
        p,
      );
    }

    arc(const Color(0xFFEA4335), -0.52, 1.05);
    arc(const Color(0xFFFBBC05), 0.53, 0.95);
    arc(const Color(0xFF34A853), 1.48, 1.05);
    arc(const Color(0xFF4285F4), 2.53, 0.95);

    canvas.drawRect(
      Rect.fromLTWH(w * 0.48, h * 0.44, w * 0.52, h * 0.14),
      Paint()..color = const Color(0xFF4285F4),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class PremiumAuthBackground extends StatefulWidget {
  const PremiumAuthBackground({super.key, required this.child});

  final Widget child;

  @override
  State<PremiumAuthBackground> createState() => _PremiumAuthBackgroundState();
}

class _PremiumAuthBackgroundState extends State<PremiumAuthBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _drift;

  @override
  void initState() {
    super.initState();
    _drift = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
  }

  @override
  void dispose() {
    _drift.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      PolaColors.darkBackground,
                      const Color(0xFF172554),
                      const Color(0xFF1E3A5F),
                      PolaColors.darkSurface,
                    ]
                  : [
                      const Color(0xFFEFF6FF),
                      const Color(0xFFF0F9FF),
                      const Color(0xFFF8FAFC),
                      const Color(0xFFDBEAFE),
                    ],
              stops: const [0.0, 0.35, 0.65, 1.0],
            ),
          ),
        ),
        AnimatedBuilder(
          animation: _drift,
          builder: (context, _) {
            final t = _drift.value * 2 * math.pi;
            return Stack(
              children: [
                Positioned(
                  top: -90 + math.sin(t) * 18,
                  right: -70 + math.cos(t) * 14,
                  child: _GlowOrb(
                    size: 240,
                    color: PolaColors.primary.withValues(alpha: isDark ? 0.2 : 0.16),
                    blur: 60,
                  ),
                ),
                Positioned(
                  bottom: 60 + math.cos(t * 0.8) * 20,
                  left: -80 + math.sin(t * 0.7) * 16,
                  child: _GlowOrb(
                    size: 200,
                    color: PolaColors.secondary.withValues(alpha: isDark ? 0.14 : 0.18),
                    blur: 50,
                  ),
                ),
                Positioned(
                  top: MediaQuery.sizeOf(context).height * 0.42,
                  right: 30 + math.sin(t * 1.2) * 10,
                  child: _GlowOrb(
                    size: 90,
                    color: const Color(0xFF818CF8).withValues(alpha: isDark ? 0.1 : 0.12),
                    blur: 36,
                  ),
                ),
              ],
            );
          },
        ),
        widget.child,
      ],
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({
    required this.size,
    required this.color,
    this.blur = 0,
  });

  final double size;
  final Color color;
  final double blur;

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: blur > 0 ? ImageFilter.blur(sigmaX: blur, sigmaY: blur) : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }
}

class PremiumAuthCard extends StatelessWidget {
  const PremiumAuthCard({
    super.key,
    required this.child,
    this.showClose = false,
    this.onClose,
    this.isLoginMode = true,
  });

  final Widget child;
  final bool showClose;
  final VoidCallback? onClose;
  final bool isLoginMode;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            color: cs.surface.withValues(alpha: isDark ? 0.88 : 0.92),
            border: Border.all(
              color: Colors.white.withValues(alpha: isDark ? 0.08 : 0.55),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: PolaColors.primary.withValues(alpha: isDark ? 0.12 : 0.08),
                blurRadius: 40,
                spreadRadius: 2,
                offset: const Offset(0, 16),
              ),
              ...PolaTokens.softShadow(Colors.black),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PremiumAuthHeader(
                showClose: showClose,
                onClose: onClose,
                isLoginMode: isLoginMode,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PremiumAuthHeader extends StatelessWidget {
  const PremiumAuthHeader({
    super.key,
    this.showClose = false,
    this.onClose,
    this.isLoginMode = true,
  });

  final bool showClose;
  final VoidCallback? onClose;
  final bool isLoginMode;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 58),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                PolaColors.primary.withValues(alpha: isDark ? 0.65 : 0.95),
                const Color(0xFF3B82F6).withValues(alpha: isDark ? 0.45 : 0.85),
                PolaColors.secondary.withValues(alpha: isDark ? 0.28 : 0.72),
              ],
            ),
          ),
          child: Column(
            children: [
              Text(
                isLoginMode ? 'Selamat datang kembali' : 'Buat akun POLA',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'POLA Assistant',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.6,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
              ),
              const SizedBox(height: 10),
              Text(
                isLoginMode
                    ? 'Masuk untuk sinkron riwayat chat, bookmark, dan profil.'
                    : 'Daftar sekali — gunakan email kampus atau Google.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                      height: 1.4,
                    ),
              ),
              const SizedBox(height: 16),
              const _FeatureBadges(),
            ],
          ),
        ),
        if (showClose && onClose != null)
          Positioned(
            top: 10,
            right: 10,
            child: IconButton(
              tooltip: 'Tutup',
              onPressed: onClose,
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.22),
              ),
              icon: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
            ),
          ),
        Positioned(
          left: 0,
          right: 0,
          bottom: -40,
          child: Center(
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: PolaColors.primary.withValues(alpha: 0.45),
                    blurRadius: 28,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: cs.surface,
                  border: Border.all(
                    color: PolaColors.primary.withValues(alpha: 0.55),
                    width: 2.5,
                  ),
                ),
                child: const PolaLogo(size: 72),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FeatureBadges extends StatelessWidget {
  const _FeatureBadges();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 6,
      children: const [
        _FeatureBadge(icon: Icons.cloud_done_outlined, label: 'Sinkron cloud'),
        _FeatureBadge(icon: Icons.history_rounded, label: 'Riwayat chat'),
        _FeatureBadge(icon: Icons.verified_user_outlined, label: 'Aman'),
      ],
    );
  }
}

class _FeatureBadge extends StatelessWidget {
  const _FeatureBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.white.withValues(alpha: 0.95)),
          const SizedBox(width: 5),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.95),
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
          ),
        ],
      ),
    );
  }
}

class PremiumModeTabs extends StatelessWidget {
  const PremiumModeTabs({
    super.key,
    required this.isLoginMode,
    required this.onChanged,
  });

  final bool isLoginMode;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      height: 46,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          _TabChip(label: 'Masuk', selected: isLoginMode, onTap: () => onChanged(true)),
          _TabChip(label: 'Daftar', selected: !isLoginMode, onTap: () => onChanged(false)),
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
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          gradient: selected
              ? const LinearGradient(
                  colors: [PolaColors.primary, Color(0xFF3B82F6), PolaColors.secondary],
                )
              : null,
          borderRadius: BorderRadius.circular(12),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: PolaColors.primary.withValues(alpha: 0.38),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: Center(
              child: Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: selected ? Colors.white : cs.onSurfaceVariant,
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PremiumAuthField extends StatelessWidget {
  const PremiumAuthField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.hint,
    this.obscure = false,
    this.keyboardType,
    this.autofillHints,
    this.onToggleObscure,
    this.validator,
    this.onFieldSubmitted,
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
  final ValueChanged<String>? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      autofillHints: autofillHints,
      validator: validator,
      onFieldSubmitted: onFieldSubmitted,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        prefixIcon: Container(
          width: 48,
          alignment: Alignment.center,
          child: Icon(icon, size: 21, color: cs.primary),
        ),
        suffixIcon: onToggleObscure == null
            ? null
            : IconButton(
                tooltip: obscure ? 'Tampilkan' : 'Sembunyikan',
                onPressed: onToggleObscure,
                icon: Icon(
                  obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  size: 20,
                ),
              ),
        filled: true,
        fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.42),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.45)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: PolaColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: cs.error.withValues(alpha: 0.8)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: cs.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}

class PremiumPrimaryButton extends StatelessWidget {
  const PremiumPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.busy = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool busy;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !busy;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: enabled
            ? const LinearGradient(
                colors: [PolaColors.primary, Color(0xFF3B82F6), PolaColors.secondary],
              )
            : null,
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: PolaColors.primary.withValues(alpha: 0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 5),
                ),
              ]
            : null,
      ),
      child: Material(
        color: enabled ? Colors.transparent : Theme.of(context).disabledColor,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: 52,
            child: Center(
              child: busy
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon != null) ...[
                          Icon(icon, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 15.5,
                            letterSpacing: 0.2,
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

class PremiumGoogleButton extends StatelessWidget {
  const PremiumGoogleButton({
    super.key,
    required this.onPressed,
    this.busy = false,
    this.highlight = true,
  });

  final VoidCallback? onPressed;
  final bool busy;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final enabled = onPressed != null && !busy;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: enabled ? onPressed : null,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: isDark ? cs.surfaceContainerHighest.withValues(alpha: 0.6) : Colors.white,
            border: Border.all(
              color: highlight
                  ? cs.outlineVariant.withValues(alpha: 0.7)
                  : cs.outlineVariant.withValues(alpha: 0.45),
              width: highlight ? 1.4 : 1,
            ),
            boxShadow: highlight
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (busy)
                SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: cs.primary,
                  ),
                )
              else ...[
                const GoogleLogo(size: 22),
                const SizedBox(width: 12),
                Text(
                  'Lanjutkan dengan Google',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.1,
                      ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class PremiumAuthDivider extends StatelessWidget {
  const PremiumAuthDivider({super.key, this.label = 'atau masuk dengan email'});

  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(child: Divider(color: cs.outlineVariant.withValues(alpha: 0.55), thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        Expanded(child: Divider(color: cs.outlineVariant.withValues(alpha: 0.55), thickness: 1)),
      ],
    );
  }
}

/// Form login/daftar bersama — dipakai halaman login & dialog sambutan.
class PremiumAuthForm extends StatelessWidget {
  const PremiumAuthForm({
    super.key,
    required this.formKey,
    required this.isLoginMode,
    required this.onModeChanged,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.obscurePassword,
    required this.onToggleObscure,
    required this.submitted,
    required this.busy,
    required this.onSubmit,
    required this.onGoogleSignIn,
    required this.showGoogle,
    this.onForgotPassword,
    this.onGuest,
  });

  final GlobalKey<FormState> formKey;
  final bool isLoginMode;
  final ValueChanged<bool> onModeChanged;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool obscurePassword;
  final VoidCallback onToggleObscure;
  final bool submitted;
  final bool busy;
  final VoidCallback onSubmit;
  final VoidCallback? onGoogleSignIn;
  final bool showGoogle;
  final VoidCallback? onForgotPassword;
  final VoidCallback? onGuest;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Form(
      key: formKey,
      autovalidateMode:
          submitted ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PremiumModeTabs(isLoginMode: isLoginMode, onChanged: onModeChanged),
          const SizedBox(height: 20),
          if (showGoogle) ...[
            PremiumGoogleButton(
              busy: busy,
              highlight: true,
              onPressed: busy ? null : onGoogleSignIn,
            ),
            const SizedBox(height: 20),
            const PremiumAuthDivider(),
            const SizedBox(height: 18),
          ],
          PremiumAuthField(
            controller: emailController,
            label: 'Email',
            hint: 'nama@polibatam.ac.id',
            icon: Icons.alternate_email_rounded,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            validator: (v) {
              final s = (v ?? '').trim();
              if (s.isEmpty) return 'Email wajib diisi.';
              if (!looksLikeEmail(s)) return 'Format email tidak valid.';
              return null;
            },
          ),
          const SizedBox(height: 14),
          PremiumAuthField(
            controller: passwordController,
            label: 'Kata Sandi',
            icon: Icons.lock_outline_rounded,
            obscure: obscurePassword,
            autofillHints: const [AutofillHints.password],
            onToggleObscure: onToggleObscure,
            onFieldSubmitted: (_) => onSubmit(),
            validator: (v) {
              final s = v ?? '';
              if (s.isEmpty) return 'Kata sandi wajib diisi.';
              if (!isLoginMode && s.length < 6) {
                return 'Minimal 6 karakter.';
              }
              return null;
            },
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 14),
              child: PremiumAuthField(
                controller: confirmPasswordController,
                label: 'Konfirmasi Kata Sandi',
                icon: Icons.lock_person_outlined,
                obscure: obscurePassword,
                validator: (v) {
                  final s = v ?? '';
                  if (s.isEmpty) return 'Konfirmasi kata sandi wajib diisi.';
                  if (s != passwordController.text) return 'Konfirmasi tidak cocok.';
                  return null;
                },
              ),
            ),
            crossFadeState:
                isLoginMode ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 260),
            sizeCurve: Curves.easeOutCubic,
          ),
          if (isLoginMode && onForgotPassword != null) ...[
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: busy ? null : onForgotPassword,
                child: Text(
                  'Lupa kata sandi?',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 18),
          PremiumPrimaryButton(
            label: isLoginMode ? 'Masuk ke POLA' : 'Buat Akun Baru',
            icon: isLoginMode ? Icons.login_rounded : Icons.person_add_alt_1_rounded,
            busy: busy,
            onPressed: busy ? null : onSubmit,
          ),
          if (onGuest != null) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: busy ? null : onGuest,
              child: Text(
                'Lanjut sebagai Tamu',
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

bool looksLikeEmail(String s) =>
    RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(s);
