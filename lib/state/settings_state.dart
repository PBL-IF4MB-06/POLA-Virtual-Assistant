import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState extends ChangeNotifier {
  static const _kProfileName = 'pola_profile_name_v1';
  static const _kUsername = 'pola_profile_username_v1';
  static const _kAvatarBase64 = 'pola_profile_avatar_b64_v1';
  static const _kAppLanguage = 'pola_app_language_v1';
  static const _kPrimaryLanguage = 'pola_primary_language_v1';
  static const _kAccentIndex = 'pola_accent_index_v1';
  static const _kHaptic = 'pola_haptic_feedback_v1';
  static const _kSpell = 'pola_spell_correction_v1';
  static const _kVoice = 'pola_voice_v1';
  static const _kSplitMode = 'pola_split_mode_v1';
  static const _kBackgroundConvo = 'pola_background_conversation_v1';
  static const _kAutoFinish = 'pola_auto_finish_v1';
  static const _kTrendingSearch = 'pola_trending_search_v1';
  static const _kFollowUp = 'pola_follow_up_suggestions_v1';

  String _profileName = '';
  String _username = '';
  String _avatarBase64 = '';
  String _appLanguage = 'Indonesia';
  String _primaryLanguage = 'Otomatis';
  int _accentIndex = 0;

  bool _hapticFeedback = true;
  bool _spellCorrection = true;
  String _voice = 'Arbor';
  bool _splitMode = false;
  bool _backgroundConversation = false;

  bool _autoFinish = true;
  bool _trendingSearch = true;
  bool _followUpSuggestions = true;

  String get profileName => _profileName;
  String get username => _username;
  String get avatarBase64 => _avatarBase64;
  String get appLanguage => _appLanguage;
  String get primaryLanguage => _primaryLanguage;
  int get accentIndex => _accentIndex;

  bool get hapticFeedback => _hapticFeedback;
  bool get spellCorrection => _spellCorrection;
  String get voice => _voice;
  bool get splitMode => _splitMode;
  bool get backgroundConversation => _backgroundConversation;

  bool get autoFinish => _autoFinish;
  bool get trendingSearch => _trendingSearch;
  bool get followUpSuggestions => _followUpSuggestions;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _profileName = prefs.getString(_kProfileName) ?? '';
    _username = prefs.getString(_kUsername) ?? '';
    _avatarBase64 = prefs.getString(_kAvatarBase64) ?? '';
    _appLanguage = prefs.getString(_kAppLanguage) ?? 'Indonesia';
    _primaryLanguage = prefs.getString(_kPrimaryLanguage) ?? 'Otomatis';
    _accentIndex = prefs.getInt(_kAccentIndex) ?? 0;

    _hapticFeedback = prefs.getBool(_kHaptic) ?? true;
    _spellCorrection = prefs.getBool(_kSpell) ?? true;
    _voice = prefs.getString(_kVoice) ?? 'Arbor';
    _splitMode = prefs.getBool(_kSplitMode) ?? false;
    _backgroundConversation = prefs.getBool(_kBackgroundConvo) ?? false;

    _autoFinish = prefs.getBool(_kAutoFinish) ?? true;
    _trendingSearch = prefs.getBool(_kTrendingSearch) ?? true;
    _followUpSuggestions = prefs.getBool(_kFollowUp) ?? true;
    notifyListeners();
  }

  Future<void> setProfile({String? name, String? username}) async {
    final prefs = await SharedPreferences.getInstance();
    var changed = false;

    if (name != null && name.trim() != _profileName) {
      _profileName = name.trim();
      await prefs.setString(_kProfileName, _profileName);
      changed = true;
    }
    if (username != null && username.trim() != _username) {
      _username = username.trim();
      await prefs.setString(_kUsername, _username);
      changed = true;
    }

    if (changed) notifyListeners();
  }

  Future<void> setAvatarBase64(String base64) async {
    if (base64 == _avatarBase64) return;
    _avatarBase64 = base64;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kAvatarBase64, base64);
  }

  Future<void> setAppLanguage(String value) async {
    if (value == _appLanguage) return;
    _appLanguage = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kAppLanguage, value);
  }

  Future<void> setPrimaryLanguage(String value) async {
    if (value == _primaryLanguage) return;
    _primaryLanguage = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPrimaryLanguage, value);
  }

  Future<void> setAccentIndex(int index) async {
    if (index == _accentIndex) return;
    _accentIndex = index;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kAccentIndex, index);
  }

  Future<void> setHapticFeedback(bool value) async {
    if (value == _hapticFeedback) return;
    _hapticFeedback = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kHaptic, value);
  }

  Future<void> setSpellCorrection(bool value) async {
    if (value == _spellCorrection) return;
    _spellCorrection = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kSpell, value);
  }

  Future<void> setVoice(String value) async {
    if (value == _voice) return;
    _voice = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kVoice, value);
  }

  Future<void> setSplitMode(bool value) async {
    if (value == _splitMode) return;
    _splitMode = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kSplitMode, value);
  }

  Future<void> setBackgroundConversation(bool value) async {
    if (value == _backgroundConversation) return;
    _backgroundConversation = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kBackgroundConvo, value);
  }

  Future<void> setAutoFinish(bool value) async {
    if (value == _autoFinish) return;
    _autoFinish = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kAutoFinish, value);
  }

  Future<void> setTrendingSearch(bool value) async {
    if (value == _trendingSearch) return;
    _trendingSearch = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kTrendingSearch, value);
  }

  Future<void> setFollowUpSuggestions(bool value) async {
    if (value == _followUpSuggestions) return;
    _followUpSuggestions = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kFollowUp, value);
  }
}

