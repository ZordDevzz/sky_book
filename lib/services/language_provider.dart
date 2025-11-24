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

      // Auth
      'title_login': 'Đăng nhập',
      'title_register': 'Tạo tài khoản',
      'username': 'Tên đăng nhập',
      'passw': 'Mật khẩu',
      'repeat_passw': 'Nhập lại mật khẩu',
      'login_btn': 'Đăng nhập',
      'register_btn': 'Đăng ký',
      'username_validator': 'Vui lòng nhập tên đăng nhập',
      'passw_validator': 'Mật khẩu tối thiểu 6 ký tự',
      'repeat_passw_validator': 'Mật khẩu không khớp',
      'no_account': 'Chưa có tài khoản? Đăng ký ngay',
      'has_account': 'Đã có tài khoản? Đăng nhập ngay',

      // Home
      'featured_books': 'Truyện Hot Tuần',
      'featured_muted': 'Top trending trong tuần',
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
      'save': 'Lưu',
      'cancel': 'Hủy',
      'logout': 'Đăng xuất',
      'logout_toast': 'Hẹn gặp lại !',
      'guest': 'Khách',
      'guest_mode':
          'Bạn đang ở chế độ khách. Hãy đăng nhập để lưu truyện và xem BXH.',
      'login_or_register': 'Đăng nhập / Đăng ký',
      'login_required': 'Vui lòng đăng nhập để sử dụng tính năng này',
    },
    'en': {
      // Navigation
      'shelf': 'Shelf',
      'leaderboard': 'Leaderboard',
      'home': 'Home',
      'discover': 'Discover',
      'profile': 'Profile',

      // Auth
      'title_login': 'Login to Sky Book',
      'title_register': 'Create a new account',
      'username': 'Username',
      'passw': 'Password',
      'repeat_passw': 'Repeat password',
      'login_btn': 'Login',
      'register_btn': 'Register',
      'username_validator': 'Please input username',
      'passw_validator': 'Password must be at least 6 characters long',
      'repeat_passw_validator': 'Passwords do not match',
      'no_account': 'Don\'t have an account? Register now',
      'has_account': 'Has an account already? Login now',

      // Home
      'featured_books': 'Featured Novels',
      'featured_muted': 'Top trending this week',
      'new_releases': 'New releases',
      'recommended_for_you': 'Recommended',
      'popular_authors': 'Popular authors',
      'no_books_found': 'Couldn\'t find novels',

      // Profile props
      'avatar': 'Avatar (URL)',
      'settings': 'Settings',
      'dark_mode': 'Dark Mode',
      'language': 'Language',
      'edit_profile': 'Edit Profile',
      'save': 'Save',
      'cancel': 'Cancel',
      'logout': 'Log out',
      'logout_toast': 'See you later !',
      'guest': 'Guest',
      'guest_mode':
          'You are in guest mode. Sign in to save your novels and view leaderboard.',
      'login_or_register': 'Sign in / Register',
      'login_required': 'Please sign in to use this feature',
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
