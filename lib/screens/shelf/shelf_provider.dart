import 'package:flutter/material.dart';
import 'package:sky_book/models/book.dart';
import 'package:sky_book/models/shelf.dart';
import 'package:sky_book/repositories/book_repository.dart';
import 'package:sky_book/repositories/chapter_repository.dart';
import 'package:sky_book/repositories/shelf_repository.dart';
import 'package:sky_book/services/auth_provider.dart';

class ShelvedBookInfo {
  final Book book;
  final Shelf shelf;
  final int totalChapters;
  final int? lastReadChapterIndex;

  ShelvedBookInfo({
    required this.book,
    required this.shelf,
    required this.totalChapters,
    this.lastReadChapterIndex,
  });
}

class ShelfProvider with ChangeNotifier {
  final ShelfRepository _shelfRepository;
  final AuthProvider _authProvider;
  final BookRepository _bookRepository;
  final ChapterRepository _chapterRepository;

  ShelfProvider(
    this._shelfRepository,
    this._authProvider,
    this._bookRepository,
    this._chapterRepository,
  ) {
    _authProvider.addListener(_onAuthStateChanged);
    _onAuthStateChanged();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<ShelvedBookInfo> _shelvedBooksInfo = [];
  List<ShelvedBookInfo> get shelvedBooksInfo => _shelvedBooksInfo;

  Set<String> get shelvedBookIds => _shelvedBooksInfo.map((info) => info.book.bookId).toSet();

  bool isBookOnShelf(String bookId) => shelvedBookIds.contains(bookId);

  ShelvedBookInfo? getShelvedBookInfo(String bookId) {
    try {
      return _shelvedBooksInfo.firstWhere((info) => info.book.bookId == bookId);
    } catch (e) {
      return null;
    }
  }

  void update() {
    _onAuthStateChanged();
  }

  void _onAuthStateChanged() {
    if (_authProvider.isGuest) {
      _shelvedBooksInfo = [];
      notifyListeners();
    } else {
      _isLoading = true;
      _shelvedBooksInfo = [];
      notifyListeners();
      fetchShelves();
    }
  }

  Future<void> fetchShelves() async {
    if (_authProvider.isGuest) return;
    try {
      // 1. Get all shelves for the user
      final userShelves =
          await _shelfRepository.getShelvesByUserId(_authProvider.currentUser!.userId);

      if (userShelves.isEmpty) {
        _shelvedBooksInfo = [];
        return;
      }

      // 2. Extract IDs for batch fetching
      final bookIds = userShelves.map((s) => s.bookId).toList();
      final lastReadChapterIds = userShelves
          .where((s) => s.lastReadChapterId != null)
          .map((s) => s.lastReadChapterId!)
          .toList();

      // 3. Batch fetch all necessary data
      final booksById = await _bookRepository.getBooksByIds(bookIds);
      final chapterCountsByBookId = await _chapterRepository.getChapterCountsForBooks(bookIds);
      final lastReadChaptersById = await _chapterRepository.getChaptersByIds(lastReadChapterIds);

      // 4. Combine data in memory
      final List<ShelvedBookInfo> tempShelvedBooksInfo = [];
      for (var shelf in userShelves) {
        final book = booksById[shelf.bookId];
        if (book != null) {
          final totalChapters = chapterCountsByBookId[shelf.bookId] ?? 0;
          final lastReadChapter = lastReadChaptersById[shelf.lastReadChapterId];
          
          tempShelvedBooksInfo.add(
            ShelvedBookInfo(
              book: book,
              shelf: shelf,
              totalChapters: totalChapters,
              lastReadChapterIndex: lastReadChapter?.chapterIndex.toInt(),
            ),
          );
        }
      }
      _shelvedBooksInfo = tempShelvedBooksInfo;
    } catch (e) {
      // Handle error
      _shelvedBooksInfo = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addBookToShelf(String bookId) async {
    if (_authProvider.isGuest) return;
    final shelf = Shelf(userId: _authProvider.currentUser!.userId, bookId: bookId);
    await _shelfRepository.addBookToShelf(shelf);
    await fetchShelves();
  }

  Future<void> removeBookFromShelf(String bookId) async {
    if (_authProvider.isGuest) return;
    await _shelfRepository.removeBookFromShelf(_authProvider.currentUser!.userId, bookId);
    await fetchShelves();
  }

  Future<void> updateShelf(Shelf shelf) async {
    if (_authProvider.isGuest) return;
    await _shelfRepository.updateShelf(shelf);
    await fetchShelves();
  }

  @override
  void dispose() {
    _authProvider.removeListener(_onAuthStateChanged);
    super.dispose();
  }
}
