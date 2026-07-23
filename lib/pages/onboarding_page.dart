import 'package:flutter/material.dart';

import '../app/app_state_scope.dart';
import '../ui/theme/pola_colors.dart';
import '../widgets/auth_welcome_dialog.dart';
import '../widgets/modern_gradient_background.dart';
import '../widgets/pola_logo.dart';
import 'app_shell_v8.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _page = PageController();
  int _index = 0;

  static const _slides = <({String emoji, String title, String body})>[
    (
      emoji: '🤖',
      title: 'Chatbot AI pada Aplikasi POLA',
      body:
          'Implementasi chatbot AI berbasis mobile untuk civitas Politeknik Negeri Batam',
    ),
    (
      emoji: '📚',
      title: 'Informasi Kampus Terpadu',
      body: 'Modul akademik, beasiswa, magang, dan layanan Polibatam dalam satu aplikasi',
    ),
    (
      emoji: '⚡',
      title: 'Respons Cepat & Akurat',
      body: 'Chatbot AI menjawab pertanyaan kampus kapan saja, langsung dari ponsel Anda',
    ),
  ];

  Future<void> _finish() async {
    await AppStateScope.of(context).settings.setOnboardingCompleted(true);
    if (!mounted) return;
    // Tampilkan sebelum pindah halaman (setelah pushReplacement context ini dispose).
    await showAuthWelcomeDialog(context);
    if (!mounted) return;
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const AppShellV8()),
    );
  }

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _index == _slides.length - 1;

    return Scaffold(
      body: ModernGradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(onPressed: _finish, child: const Text('Lewati')),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _page,
                  itemCount: _slides.length,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (context, i) {
                    final s = _slides[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: PolaColors.primary.withValues(alpha: 0.15),
                                  blurRadius: 24,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: i == 0
                                ? const PolaLogo(size: 72)
                                : Text(s.emoji, style: const TextStyle(fontSize: 52)),
                          ),
                          const SizedBox(height: 36),
                          Text(
                            s.title,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            s.body,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  height: 1.55,
                                ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_slides.length, (i) {
                  final active = i == _index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: active ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(99),
                      color: active ? PolaColors.primary : const Color(0xFFCBD5E1),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: isLast
                        ? _finish
                        : () => _page.nextPage(
                              duration: const Duration(milliseconds: 320),
                              curve: Curves.easeOutCubic,
                            ),
                    child: Text(isLast ? 'Mulai Sekarang' : 'Lanjut'),
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
