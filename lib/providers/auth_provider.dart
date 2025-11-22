import 'package:shadcn_flutter/shadcn_flutter.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  // Login method
  Future<void> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call

      // Mock user data
      _currentUser = User(
        id: '1',
        username: 'reader123',
        email: email,
        avatarUrl: null,
        memberSince: DateTime.now(),
        storiesRead: 42,
        readingStreak: 7,
        followersCount: 5,
        followingCount: 10,
        badges: [],
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Login failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Register method
  Future<void> register(String username, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 1));

      _currentUser = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        username: username,
        email: email,
        memberSince: DateTime.now(),
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Registration failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Logout method
  void logout() {
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }

  // Update user profile
  void updateUser(User updatedUser) {
    _currentUser = updatedUser;
    notifyListeners();
  }
}
