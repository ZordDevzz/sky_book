import 'package:flutter/material.dart';
import 'package:sky_book/models/book.dart';
import 'package:sky_book/repositories/book_repository.dart';

enum LeaderboardRange { weekly, monthly, allTime }

class LeaderboardProvider with ChangeNotifier {
  LeaderboardProvider(this._bookRepository) {
    fetchLeaderboard();
  }

  final BookRepository _bookRepository;
  List<Book> _entries = [];
  bool _isLoading = false;
  LeaderboardRange _range = LeaderboardRange.weekly;

  List<Book> get entries => _entries;
  bool get isLoading => _isLoading;
  LeaderboardRange get range => _range;

  Future<void> fetchLeaderboard() async {
    _isLoading = true;
    notifyListeners();
    try {
      final books = await _bookRepository.getAllBooksWithDetails();
      _entries = _sortBooks(books, _range).take(20).toList();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setRange(LeaderboardRange range) {
    if (_range == range) return;
    _range = range;
    fetchLeaderboard();
  }

  Iterable<Book> _sortBooks(List<Book> books, LeaderboardRange range) {
    final list = [...books];
    switch (range) {
      case LeaderboardRange.weekly:
        list.sort((a, b) => b.viewCountWeekly.compareTo(a.viewCountWeekly));
        return list;
      case LeaderboardRange.monthly:
        list.sort((a, b) => b.viewCountMonthly.compareTo(a.viewCountMonthly));
        return list;
      case LeaderboardRange.allTime:
        list.sort((a, b) => b.viewCountTotal.compareTo(a.viewCountTotal));
        return list;
    }
  }

  int countFor(Book book) {
    switch (_range) {
      case LeaderboardRange.weekly:
        return book.viewCountWeekly;
      case LeaderboardRange.monthly:
        return book.viewCountMonthly;
      case LeaderboardRange.allTime:
        return book.viewCountTotal;
    }
  }


}
