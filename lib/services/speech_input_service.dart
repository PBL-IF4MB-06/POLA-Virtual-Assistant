import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

typedef SpeechResultCallback = void Function(String text, bool isFinal);

class SpeechInputService {
  SpeechInputService() : _speech = SpeechToText();

  final SpeechToText _speech;
  bool _initialized = false;
  bool _sessionActive = false;
  void Function(String status)? _statusHandler;
  void Function(String message)? _errorHandler;

  bool get isAvailable => _speech.isAvailable;
  bool get isListening => _sessionActive || _speech.isListening;
  bool get isInitialized => _initialized;

  Future<void> _releaseSession() async {
    if (!_sessionActive && !_speech.isListening) return;
    try {
      if (_speech.isListening) {
        await _speech.stop();
      }
    } catch (_) {}
    try {
      await _speech.cancel();
    } catch (_) {}
    _sessionActive = false;
    if (kIsWeb) {
      await Future<void>.delayed(const Duration(milliseconds: 150));
    }
  }

  Future<bool> initialize({
    void Function(String message)? onError,
  }) async {
    if (_initialized) return _speech.isAvailable;
    _errorHandler = onError;
    final ok = await _speech.initialize(
      onStatus: (status) => _statusHandler?.call(status),
      onError: (error) => _errorHandler?.call(_friendlyError(error.errorMsg)),
      debugLogging: kDebugMode,
    );
    _initialized = true;
    return ok;
  }

  Future<String?> _resolveLocale(String? preferred) async {
    if (preferred == null || preferred.isEmpty) return null;

    if (kIsWeb) {
      return preferred.replaceAll('_', '-');
    }

    try {
      final locales = await _speech.locales();
      for (final locale in locales) {
        if (locale.localeId == preferred) return locale.localeId;
        if (locale.localeId.replaceAll('_', '-') ==
            preferred.replaceAll('_', '-')) {
          return locale.localeId;
        }
      }
    } catch (_) {}

    return preferred;
  }

  Future<bool> startListening({
    required String? localeId,
    required SpeechResultCallback onResult,
    required void Function(String status) onStatus,
    Duration? pauseFor,
    Duration listenFor = const Duration(seconds: 30),
  }) async {
    if (_sessionActive || _speech.isListening) {
      await _releaseSession();
    }

    _statusHandler = onStatus;
    final effectiveLocale = await _resolveLocale(localeId);

    try {
      await _speech.listen(
        onResult: (SpeechRecognitionResult result) {
          onResult(result.recognizedWords, result.finalResult);
        },
        listenOptions: SpeechListenOptions(
          localeId: effectiveLocale,
          listenFor: listenFor,
          pauseFor: pauseFor,
          listenMode: ListenMode.dictation,
          partialResults: true,
          cancelOnError: false,
          autoPunctuation: true,
        ),
      );
      _sessionActive = true;
      return true;
    } catch (e) {
      await _releaseSession();
      _errorHandler?.call(_friendlyError(e.toString()));
      return false;
    }
  }

  Future<void> stop() => _releaseSession();

  static String _friendlyError(String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains('not-allowed') || lower.contains('permission')) {
      return 'Akses mikrofon ditolak. Izinkan mic di pengaturan browser.';
    }
    if (lower.contains('not supported') || lower.contains('speech_not_supported')) {
      return 'Browser ini tidak mendukung speech recognition. Gunakan Chrome.';
    }
    if (lower.contains('already started')) {
      return 'Mikrofon masih aktif. Tunggu sebentar lalu coba lagi.';
    }
    if (lower.contains('no-speech') || lower.contains('audio-capture')) {
      return 'Suara tidak terdeteksi. Pastikan mic aktif dan coba lagi.';
    }
    return raw;
  }

  static String? localeFromAppLanguage(String appLanguage) {
    switch (appLanguage) {
      case 'Indonesia':
        return 'id_ID';
      case 'English':
        return 'en_US';
      default:
        return null;
    }
  }
}
