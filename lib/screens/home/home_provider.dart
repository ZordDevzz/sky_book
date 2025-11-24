import 'package:flutter/material.dart';
import 'package:sky_book/models/book.dart';
import 'package:sky_book/repositories/book_repository.dart';

class HomeProvider with ChangeNotifier {
  final BookRepository _bookRepository;

  List<Book> _books = [];
  List<Book> _featuredBooks = [];
  List<Book> _newReleaseBooks = [];
  bool _isLoading = false;

  List<Book> get books => _books;
  List<Book> get featuredBooks => _featuredBooks;
  List<Book> get newReleaseBooks => _newReleaseBooks;
  bool get isLoading => _isLoading;

  HomeProvider(this._bookRepository) {
    fetchBooks();
  }

  Future<void> fetchBooks() async {
    _isLoading = true;
    notifyListeners();

    try {
      _books = await _bookRepository.getAllBooksWithDetails();
      
      // Featured books sorted by weekly view count
      _books.sort((a, b) => (b.viewCountWeekly.compareTo(a.viewCountWeekly)));
      _featuredBooks = _books.take(6).toList();

      // New release books sorted by release date
      _books.sort((a, b) {
        if (a.releaseDate == null && b.releaseDate == null) return 0;
        if (a.releaseDate == null) return 1;
        if (b.releaseDate == null) return -1;
        return b.releaseDate!.compareTo(a.releaseDate!);
      });
      _newReleaseBooks = _books.take(10).toList();
      
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
