import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider with ChangeNotifier {
  String _languageCode = 'vi';
  final String _key = 'language_preference';

  final Map<String, Map<String, String>> _localized = {
    'vi': {
      'shelf': 'Tủ sách',
      'leaderboard': 'BXH',
      'home': 'Trang chủ',
      'discover': 'Khám phá',
      'avatar': 'Avatar (URL)',
      'profile': 'Hồ sơ',
      'settings': 'Cài đặt',
      'dark_mode': 'Chế độ nền tối',
      'language': 'Ngôn ngữ',
      'edit_profile': 'Chỉnh sửa hồ sơ',
      'name': 'Tên',
      'email': 'Email',
      'save': 'Lưu',
      'cancel': 'Hủy',
    },
    'en': {
      'shelf': 'Shelf',
      'leaderboard': 'Leaderboard',
      'home': 'Home',
      'discover': 'Discover',
      'avatar': 'Avatar (URL)',
      'profile': 'Profile',
      'settings': 'Settings',
      'dark_mode': 'Dark Mode',
      'language': 'Language',
      'edit_profile': 'Edit Profile',
      'name': 'Name',
      'email': 'Email',
      'save': 'Save',
      'cancel': 'Cancel',
    },
  };

  LanguageProvider() {
    _load();
  }

  String get languageCode => _languageCode;

  String t(String key) {
    return _localized[_languageCode]?[key] ?? key;
  }

  Future<void> setLanguage(String code) async {
    _languageCode = code;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, code);
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key);
    if (code != null && _localized.containsKey(code)) {
      _languageCode = code;
      notifyListeners();
    }
  }
}
