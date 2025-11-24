import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sky_book/models/user.dart';
import 'package:sky_book/repositories/user_repository.dart';

class AuthProvider with ChangeNotifier {
  AuthProvider({required UserRepository userRepository})
      : _userRepository = userRepository {
    _restoreSession();
  }

  static const String _sessionKey = 'current_user_id';

  UserRepository _userRepository;
  User? _currentUser;
  bool _isLoading = false;
  bool _restoringSession = true;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  bool get isReady => !_restoringSession;
  String? get errorMessage => _errorMessage;

  void updateRepository(UserRepository repo) {
    _userRepository = repo;
  }

  Future<void> login(String username, String password) async {
    await _performAuthAction(() async {
      _currentUser =
          await _userRepository.login(username: username, password: password);
      await _persistUserId(_currentUser!.userId);
    });
  }

  Future<void> register(String username, String password) async {
    await _performAuthAction(() async {
      _currentUser = await _userRepository.register(
        username: username,
        password: password,
      );
      await _persistUserId(_currentUser!.userId);
    });
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
    _currentUser = null;
    notifyListeners();
  }

  Future<void> updateProfile({
    required String username,
    String? pfpUrl,
  }) async {
    if (_currentUser == null) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _currentUser = await _userRepository.updateProfile(
        userId: _currentUser!.userId,
        username: username,
        pfpUrl: pfpUrl,
      );
      await _persistUserId(_currentUser!.userId);
    } catch (e) {
      _errorMessage = _cleanMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUserId = prefs.getString(_sessionKey);
    if (savedUserId != null) {
      try {
        _currentUser = await _userRepository.getUserById(savedUserId);
      } catch (_) {
        await prefs.remove(_sessionKey);
        _currentUser = null;
      }
    }
    _restoringSession = false;
    notifyListeners();
  }

  Future<void> _performAuthAction(
    Future<void> Function() action,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await action();
    } catch (e) {
      _errorMessage = _cleanMessage(e);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _cleanMessage(Object error) {
    final message = error.toString();
    if (message.startsWith('Exception: ')) {
      return message.replaceFirst('Exception: ', '');
    }
    return message;
  }

  Future<void> _persistUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, userId);
  }
}
