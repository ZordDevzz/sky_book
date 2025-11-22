import 'package:shadcn_flutter/shadcn_flutter.dart';

class UserProvider extends ChangeNotifier {
  // Reading preferences
  double _fontSize = 16.0;
  String _fontFamily = 'Default';
  double _lineSpacing = 1.5;
  Color _backgroundColor = const Color(0xFFFFFFFF);
  bool _nightMode = false;

  double get fontSize => _fontSize;
  String get fontFamily => _fontFamily;
  double get lineSpacing => _lineSpacing;
  Color get backgroundColor => _backgroundColor;
  bool get nightMode => _nightMode;

  void setFontSize(double size) {
    _fontSize = size;
    notifyListeners();
  }

  void setFontFamily(String family) {
    _fontFamily = family;
    notifyListeners();
  }

  void setLineSpacing(double spacing) {
    _lineSpacing = spacing;
    notifyListeners();
  }

  void setBackgroundColor(Color color) {
    _backgroundColor = color;
    notifyListeners();
  }

  void toggleNightMode() {
    _nightMode = !_nightMode;
    _backgroundColor = _nightMode
        ? const Color(0xFF000000)
        : const Color(0xFFFFFFFF);
    notifyListeners();
  }

  // Reading statistics
  int _totalReadingTime = 0; // in minutes
  int _booksCompleted = 0;
  int _currentStreak = 0;

  int get totalReadingTime => _totalReadingTime;
  int get booksCompleted => _booksCompleted;
  int get currentStreak => _currentStreak;

  void addReadingTime(int minutes) {
    _totalReadingTime += minutes;
    notifyListeners();
  }

  void completeBook() {
    _booksCompleted++;
    notifyListeners();
  }

  void updateStreak(int streak) {
    _currentStreak = streak;
    notifyListeners();
  }
}
