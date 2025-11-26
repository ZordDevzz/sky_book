import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sky_book/models/book.dart';
import 'package:sky_book/models/chapter.dart';
import 'package:sky_book/models/shelf.dart';
import 'package:sky_book/repositories/book_repository.dart';
import 'package:sky_book/repositories/chapter_repository.dart';
import 'package:sky_book/repositories/shelf_repository.dart';
import 'package:sky_book/screens/shelf/shelf_provider.dart'; // Import ShelfProvider
import 'package:sky_book/services/auth_provider.dart';

class ReaderProvider with ChangeNotifier {
  final ChapterRepository _chapterRepository;
  final BookRepository _bookRepository;
  final ShelfRepository _shelfRepository;
  final AuthProvider _authProvider;
  final ShelfProvider _shelfProvider; // Add ShelfProvider
  final bool _defaultDarkMode;

  // Preference keys
  static const String _fontSizeKey = 'reader_font_size';
  static const String _backgroundColorKey = 'reader_bg_color';
  static const String _textColorKey = 'reader_text_color';
  static const String _readerDarkKey = 'reader_dark_mode';

  ReaderProvider(
    this._chapterRepository,
    this._bookRepository,
    this._shelfRepository,
    this._authProvider,
    this._shelfProvider, // Add to constructor
    String initialChapterId, {
    bool defaultDarkMode = false,
  }) : _defaultDarkMode = defaultDarkMode {
    _loadInitialChapter(initialChapterId);
    _loadPreferences();
  }

  ReaderProvider.fromData(
    this._chapterRepository,
    this._bookRepository,
    this._shelfRepository,
    this._authProvider,
    this._shelfProvider, // Add to fromData constructor
    {
    required Book book,
    required List<Chapter> chapters,
    required Chapter currentChapter,
    bool defaultDarkMode = false,
  }) : _defaultDarkMode = defaultDarkMode {
    _loadFromData(book, chapters, currentChapter);
    _loadPreferences();
  }

  bool _isLoading = true;
  Book? _currentBook;
  Chapter? _currentChapter;
  List<Chapter> _bookChapters = [];

  // Reader settings
  double _fontSize = 16.0;
  Color? _backgroundColor;
  Color? _textColor;
  bool _readerDarkMode = false;

  // Getters
  bool get isLoading => _isLoading;
  Book? get currentBook => _currentBook;
  Chapter? get currentChapter => _currentChapter;
  double get fontSize => _fontSize;
  Color? get backgroundColor => _backgroundColor;
  Color? get textColor => _textColor;
  bool get readerDarkMode => _readerDarkMode;

  bool get isFirstChapter =>
      _bookChapters.isNotEmpty &&
      _currentChapter?.chapterId == _bookChapters.first.chapterId;
  bool get isLastChapter =>
      _bookChapters.isNotEmpty &&
      _currentChapter?.chapterId == _bookChapters.last.chapterId;

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _fontSize = prefs.getDouble(_fontSizeKey) ?? 16.0;

    final bgColorValue = prefs.getInt(_backgroundColorKey);
    if (bgColorValue != null) {
      _backgroundColor = Color(bgColorValue);
    }

    final textColorValue = prefs.getInt(_textColorKey);
    if (textColorValue != null) {
      _textColor = Color(textColorValue);
    }

    _readerDarkMode = prefs.getBool(_readerDarkKey) ?? _defaultDarkMode;
    if (_readerDarkMode) {
      _backgroundColor ??= const Color(0xFF0F141A);
      _textColor ??= Colors.white;
    }
    notifyListeners();
  }

  void _loadFromData(Book book, List<Chapter> chapters, Chapter currentChapter) {
    _isLoading = true;
    notifyListeners();
    _currentBook = book;
    _bookChapters = chapters;
    _loadChapterById(currentChapter.chapterId);
    _updateProgress();
  }

  Future<void> _loadInitialChapter(String chapterId) async {
    _isLoading = true;
    notifyListeners();

    final chapter =
        await _chapterRepository.getChapterContent(chapterId.toString());
    if (chapter == null) {
      _isLoading = false;
      notifyListeners();
      return;
    }
    _currentChapter = chapter;

    final bookId = chapter.bookId;
    final book = await _bookRepository.getBookById(bookId);
    final allChapters = await _chapterRepository.getChaptersForBook(bookId);
    _currentBook = book;
    _bookChapters = allChapters;
    _updateProgress();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadChapterById(String chapterId) async {
    _isLoading = true;
    notifyListeners();
    _currentChapter = await _chapterRepository.getChapterContent(chapterId);
    _isLoading = false;
    notifyListeners();
    _updateProgress();
  }

  Future<void> _updateProgress() async {
    if (_authProvider.currentUser == null || _currentBook == null) return;
    
    // Check from cached ShelfProvider first
    if (_shelfProvider.isBookOnShelf(_currentBook!.bookId)) {
      // If book is on shelf, just update progress
      final shelf = _shelfProvider.getShelvedBookInfo(_currentBook!.bookId)?.shelf;
      if (shelf != null) {
        shelf.lastReadChapterId = _currentChapter!.chapterId;
        shelf.lastReadDate = DateTime.now();
        await _shelfRepository.updateShelf(shelf);
      }
    } else {
      // If not on shelf, add it
      final newShelf = Shelf(
        userId: _authProvider.currentUser!.userId,
        bookId: _currentBook!.bookId,
        lastReadChapterId: _currentChapter!.chapterId,
        lastReadDate: DateTime.now(),
      );
      await _shelfRepository.addBookToShelf(newShelf);
      _shelfProvider.update(); // Notify ShelfProvider of change
    }
  }

  Future<void> goToNextChapter() async {
    if (isLastChapter) return;
    final currentIndex = _bookChapters
        .indexWhere((c) => c.chapterId == _currentChapter!.chapterId);
    if (currentIndex != -1 && currentIndex + 1 < _bookChapters.length) {
      final nextChapter = _bookChapters[currentIndex + 1];
      await _loadChapterById(nextChapter.chapterId);
    }
  }

  Future<void> goToPreviousChapter() async {
    if (isFirstChapter) return;
    final currentIndex = _bookChapters
        .indexWhere((c) => c.chapterId == _currentChapter!.chapterId);
    if (currentIndex > 0) {
      final previousChapter = _bookChapters[currentIndex - 1];
      await _loadChapterById(previousChapter.chapterId);
    }
  }

  Future<void> _updateAndSave<T>(
      String key, T value, void Function() update) async {
    update();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    if (value is double) {
      prefs.setDouble(key, value);
    } else if (value is int) {
      prefs.setInt(key, value);
    } else if (value == null) {
      prefs.remove(key);
    }
  }

  Future<void> increaseFontSize() async {
    if (_fontSize < 30.0) {
      await _updateAndSave(
          _fontSizeKey, _fontSize + 1.0, () => _fontSize += 1.0);
    }
  }

  Future<void> decreaseFontSize() async {
    if (_fontSize > 10.0) {
      await _updateAndSave(
          _fontSizeKey, _fontSize - 1.0, () => _fontSize -= 1.0);
    }
  }

  Future<void> changeBackgroundColor(Color? color) async {
    await _updateAndSave(_backgroundColorKey, color?.value, () {
      _backgroundColor = color;
    });
  }

  Future<void> changeTextColor(Color? color) async {
    await _updateAndSave(_textColorKey, color?.value, () {
      _textColor = color;
    });
  }

  Future<void> toggleReaderDarkMode(bool isDark) async {
    _readerDarkMode = isDark;
    if (isDark) {
      _backgroundColor ??= const Color(0xFF0F141A);
      _textColor ??= Colors.white;
    } else {
      _backgroundColor = null;
      _textColor = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_readerDarkKey, _readerDarkMode);
    if (!isDark) {
      prefs.remove(_backgroundColorKey);
      prefs.remove(_textColorKey);
    }
  }
}
