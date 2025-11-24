import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider with ChangeNotifier {
  String _languageCode = 'vi';
  final String _key = 'language_preference';

  final Map<String, Map<String, String>> _localized = {
    'vi': {
      // Navigation
      'shelf': 'Tủ sách',
      'leaderboard': 'BXH',
      'home': 'Trang chủ',
      'discover': 'Khám phá',
      'profile': 'Hồ sơ',

      // Home
      'featured_books': 'Truyện Hot Tuần',
      'new_releases': 'Truyện mới',
      'recommended_for_you': 'Dựa trên sở thích của bạn',
      'popular_authors': 'Tác giả được tìm đọc nhiều nhất',
      'no_books_found': 'Không tìm thấy truyện nào',
      'book_rolete': 'Đọc một truyện ngẫu nhiên',


      // Profile props
      'avatar': 'Ảnh hồ sơ (URL)',
      'settings': 'Cài đặt',
      'dark_mode': 'Chế độ nền tối',
      'language': 'Ngôn ngữ',
      'edit_profile': 'Chỉnh sửa hồ sơ',
      'name': 'Tên',
      'save': 'Lưu',
      'cancel': 'Hủy',
      'logout': 'Đăng xuất',
      'logout_toast': 'Hẹn gặp lại !',
    },
    'en': {
      // Navigation
      'shelf': 'Shelf',
      'leaderboard': 'Leaderboard',
      'home': 'Home',
      'discover': 'Discover',
      'profile': 'Profile',

      // Profile props
      'avatar': 'Avatar (URL)',
      'settings': 'Settings',
      'dark_mode': 'Dark Mode',
      'language': 'Language',
      'edit_profile': 'Edit Profile',
      'name': 'Name',
      'save': 'Save',
      'cancel': 'Cancel',
      'logout': 'Log out',
      'logout_toast': 'See you later !',
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
