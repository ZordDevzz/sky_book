import 'package:flutter/material.dart';
import 'package:sky_book/models/book.dart';
import 'package:sky_book/models/chapter.dart';
import 'package:sky_book/repositories/book_repository.dart';
import 'package:sky_book/repositories/chapter_repository.dart';

class BookDetailsProvider with ChangeNotifier {
  final BookRepository _bookRepository;
  final ChapterRepository _chapterRepository;
  final String bookId;

  Book? _book;
  List<Chapter> _chapters = [];
  bool _isLoading = false;

  Book? get book => _book;
  List<Chapter> get chapters => _chapters;
  bool get isLoading => _isLoading;

  BookDetailsProvider(
    this._bookRepository,
    this._chapterRepository,
    this.bookId,
  ) {
    fetchBookDetails();
  }

  Future<void> fetchBookDetails() async {
    _isLoading = true;
    notifyListeners();

    try {
      _book = await _bookRepository.getBookById(bookId);
      if (_book != null) {
        _chapters = await _chapterRepository.getChaptersForBook(bookId);
      }
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
