import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _screenshotFontFamily = 'POLA Screenshot';

/// Konfigurasi global test: font asli (bukan kotak Ahem) + mock plugin.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();

  const speechChannel = MethodChannel('plugin.csdcorp.com/speech_to_text');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(speechChannel, (MethodCall call) async {
    switch (call.method) {
      case 'initialize':
        return true;
      case 'has_permission':
        return true;
      case 'locales':
        return <Map<String, String>>[];
      default:
        return null;
    }
  });

  await _loadScreenshotFont();
  await testMain();
}

Future<void> _loadScreenshotFont() async {
  final textCandidates = <String>[
    r'C:\Windows\Fonts\segoeui.ttf',
    r'C:\Windows\Fonts\arial.ttf',
    r'C:\Windows\Fonts\calibri.ttf',
  ];

  for (final path in textCandidates) {
    final file = File(path);
    if (!await file.exists()) continue;

    final loader = FontLoader(_screenshotFontFamily)
      ..addFont(file.readAsBytes().then((bytes) => bytes.buffer.asByteData()));
    await loader.load();
    break;
  }

  final iconCandidates = <String>[
    r'C:\src\flutter\bin\cache\artifacts\material_fonts\materialicons-regular.otf',
    if (Platform.environment['FLUTTER_ROOT'] != null)
      '${Platform.environment['FLUTTER_ROOT']}/bin/cache/artifacts/material_fonts/materialicons-regular.otf',
  ];

  for (final path in iconCandidates) {
    final file = File(path);
    if (!await file.exists()) continue;

    final loader = FontLoader('MaterialIcons')
      ..addFont(file.readAsBytes().then((bytes) => bytes.buffer.asByteData()));
    await loader.load();
    break;
  }
}

/// Terapkan font asli agar teks tidak jadi kotak/blur di golden screenshot.
ThemeData screenshotTheme(ThemeData base) {
  final textTheme = base.textTheme.apply(fontFamily: _screenshotFontFamily);
  return base.copyWith(
    textTheme: textTheme,
    primaryTextTheme: textTheme,
    appBarTheme: base.appBarTheme.copyWith(
      titleTextStyle: base.appBarTheme.titleTextStyle?.copyWith(
        fontFamily: _screenshotFontFamily,
      ),
    ),
    navigationBarTheme: base.navigationBarTheme.copyWith(
      labelTextStyle: WidgetStatePropertyAll(
        TextStyle(fontFamily: _screenshotFontFamily, fontSize: 12),
      ),
    ),
  );
}
