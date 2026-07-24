import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pola_app/pages/app_shell_v8.dart';
import 'package:pola_app/pages/login_page.dart';
import 'package:pola_app/pages/onboarding_page.dart';
import 'package:pola_app/pages/splash_page.dart';
import 'package:pola_app/pages/campus/campus_hub_page.dart';
import 'package:pola_app/pages/campus/campus_search_page.dart';
import 'package:pola_app/pages/announcements/notification_center_page.dart';
import 'package:pola_app/pages/profile/profile_hub_page.dart';
import 'package:pola_app/pages/chat/chat_tab_page.dart';
import 'package:pola_app/pages/info/info_detail_page.dart';
import 'package:pola_app/data/campus_catalog.dart';

import 'screenshot_harness.dart';

/// Generate screenshot PNG ke folder `screenshots/`:
/// flutter test test/generate_screenshots_test.dart --update-goldens
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Screenshot BAB IV', () {
    testWidgets('SS-01 splash', (tester) async {
      final h = await ScreenshotHarness.create(
        prefs: {'pola_onboarding_done_v8': true},
      );
      h.configureView(tester);
      await tester.pumpWidget(h.wrap(const SplashPage()));
      await tester.pump(const Duration(milliseconds: 900));
      await h.saveGolden(tester, 'SS-01_splash.png');
      // Selesaikan timer navigasi splash agar test tidak gagal.
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('SS-02 onboarding', (tester) async {
      final h = await ScreenshotHarness.create();
      await h.pumpScreenshot(tester, const OnboardingPage());
      await h.saveGolden(tester, 'SS-02_onboarding.png');
    });

    testWidgets('SS-03 beranda', (tester) async {
      final h = await ScreenshotHarness.create(
        prefs: {'pola_onboarding_done_v8': true},
      );
      await h.pumpScreenshot(tester, const AppShellV8());
      await h.saveGolden(tester, 'SS-03_beranda.png');
    });

    testWidgets('SS-06 quick prompts', (tester) async {
      final h = await ScreenshotHarness.create(
        prefs: {'pola_onboarding_done_v8': true},
      );
      await h.pumpScreenshot(
        tester,
        const Scaffold(body: ChatTabPage()),
        withShell: true,
      );
      await h.saveGolden(tester, 'SS-06_quick_prompts.png');
    });

    testWidgets('SS-08 campus hub', (tester) async {
      final h = await ScreenshotHarness.create(
        prefs: {'pola_onboarding_done_v8': true},
      );
      await h.pumpScreenshot(tester, const CampusHubPage(), withShell: true);
      await h.saveGolden(tester, 'SS-08_campus_hub.png');
    });

    testWidgets('SS-09 detail beasiswa', (tester) async {
      final h = await ScreenshotHarness.create();
      final module = CampusCatalog.all.firstWhere((m) => m.id == 'beasiswa');
      await h.pumpScreenshot(
        tester,
        InfoDetailPage(module: module),
        withShell: true,
      );
      await h.saveGolden(tester, 'SS-09_detail_beasiswa.png');
    });

    testWidgets('SS-10 pencarian kampus', (tester) async {
      final h = await ScreenshotHarness.create();
      await h.pumpScreenshot(tester, const CampusSearchPage(), withShell: true);
      await h.saveGolden(tester, 'SS-10_pencarian_kampus.png');
    });

    testWidgets('SS-11 notifikasi', (tester) async {
      final h = await ScreenshotHarness.create(
        prefs: {'pola_onboarding_done_v8': true},
      );
      await h.pumpScreenshot(
        tester,
        const NotificationCenterPage(),
        withShell: true,
      );
      await h.saveGolden(tester, 'SS-11_notifikasi.png');
    });

    testWidgets('SS-13 profil', (tester) async {
      final h = await ScreenshotHarness.create(
        prefs: {'pola_onboarding_done_v8': true},
      );
      await h.settings.setProfile(name: 'Mahasiswa POLA');
      await h.pumpScreenshot(tester, const ProfileHubPage(), withShell: true);
      await h.saveGolden(tester, 'SS-13_profil.png');
    });

    testWidgets('SS-16 tema gelap', (tester) async {
      final h = await ScreenshotHarness.create(
        prefs: {'pola_onboarding_done_v8': true},
      );
      await h.theme.setMode(ThemeMode.dark);
      await h.pumpScreenshot(tester, const AppShellV8());
      await h.saveGolden(tester, 'SS-16_tema_gelap.png');
    });

    testWidgets('SS-17 login', (tester) async {
      final h = await ScreenshotHarness.create();
      await h.pumpScreenshot(tester, const LoginPage());
      await h.saveGolden(tester, 'SS-17_login.png');
    });

    testWidgets('SS-19 notifikasi dimatikan', (tester) async {
      final h = await ScreenshotHarness.create(
        prefs: {'pola_onboarding_done_v8': true},
      );
      await h.settings.setNotificationsEnabled(false);
      await h.pumpScreenshot(
        tester,
        const NotificationCenterPage(),
        withShell: true,
      );
      await h.saveGolden(tester, 'SS-19_notifikasi_off.png');
    });
  });
}
