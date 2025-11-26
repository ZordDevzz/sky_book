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
      'recently_posted': 'Bổ sung gần đây',

      // Book details
      'details': 'Thông tin truyện',
      'add_to_shelf': 'Thêm vào tủ sách',
      'read_from_first': 'Đọc từ đầu',
      'description': 'Mô tả',
      'chapters': 'Tất cả chương',
      'chapter': 'Chương',
      'no_description_available': 'Không có mô tả',
      'select_chapter': 'Chọn chương',

      // Discover
      'discover_subtitle': 'Tìm kiếm, lọc và khám phá truyện mới',
      'search_hint': 'Tìm kiếm theo tên hoặc tác giả...',
      'filter_tags': 'Thể loại',
      'sort_by': 'Sắp xếp',
      'sort_trending': 'Xu hướng',
      'sort_newest': 'Mới nhất',
      'sort_rating': 'Đánh giá cao',
      'no_results': 'Không tìm thấy truyện phù hợp',

      // Leaderboard
      'leaderboard_subtitle': 'Top truyện được đọc nhiều',
      'range_week': 'Tuần',
      'range_month': 'Tháng',
      'range_all': 'Tất cả',
      'views_week': 'lượt/tuần',
      'views_month': 'lượt/tháng',
      'views_total': 'lượt tổng',

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
      'change_password': 'Đổi mật khẩu',
      'current_password': 'Mật khẩu hiện tại',
      'new_password': 'Mật khẩu mới',
      'confirm_password': 'Nhập lại mật khẩu mới',
      'password_changed': 'Đã đổi mật khẩu thành công',
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
      'recently_posted': 'Recently posted',

      // Book details
      'details': 'Novel details',
      'add_to_shelf': 'Add to shelf',
      'read_from_first': 'Start reading',
      'description': 'Description',
      'chapters': 'Chapters',
      'chapter': 'Chapter',
      'no_description_available': 'No description available',
      'select_chapter': 'Select chapters',

      // Discover
      'discover_subtitle': 'Search, filter and explore new novels',
      'search_hint': 'Search by title or author...',
      'filter_tags': 'Tags',
      'sort_by': 'Sort by',
      'sort_trending': 'Trending',
      'sort_newest': 'Newest',
      'sort_rating': 'Top rated',
      'no_results': 'No matching novels found',

      // Leaderboard
      'leaderboard_subtitle': 'Most read novels',
      'range_week': 'Weekly',
      'range_month': 'Monthly',
      'range_all': 'All time',
      'views_week': 'views/week',
      'views_month': 'views/month',
      'views_total': 'total views',

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
      'change_password': 'Change password',
      'current_password': 'Current password',
      'new_password': 'New password',
      'confirm_password': 'Confirm new password',
      'password_changed': 'Password updated successfully',
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
