import 'package:flutter/material.dart';
import 'package:sky_book/models/book.dart';
import 'package:sky_book/repositories/book_repository.dart';

class HomeProvider with ChangeNotifier {
  final BookRepository _bookRepository;

  List<Book> _books = [];
  List<Book> _featuredBooks = [];
  bool _isLoading = false;

  List<Book> get books => _books;
  List<Book> get featuredBooks => _featuredBooks;
  bool get isLoading => _isLoading;

  HomeProvider(this._bookRepository) {
    fetchBooks();
  }

  Future<void> fetchBooks() async {
    _isLoading = true;
    notifyListeners();

    try {
      _books = await _bookRepository.getAllBooksWithDetails();
      _books.sort((a, b) => (b.viewCountWeekly.compareTo(a.viewCountWeekly)));
      _featuredBooks = _books.take(6).toList();
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
