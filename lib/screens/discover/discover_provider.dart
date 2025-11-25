import 'package:flutter/material.dart';
import 'package:sky_book/models/book.dart';
import 'package:sky_book/models/tag.dart';
import 'package:sky_book/repositories/book_repository.dart';

enum DiscoverSort { newest, rating }

class DiscoverProvider with ChangeNotifier {
  DiscoverProvider(this._bookRepository) {
    fetchBooks();
  }

  final BookRepository _bookRepository;

  List<Book> _allBooks = [];
  List<Book> _filteredBooks = [];
  bool _isLoading = false;
  String _query = '';
  DiscoverSort _sort = DiscoverSort.newest;
  Tag? _selectedTag;

  List<Book> get books => _filteredBooks;
  bool get isLoading => _isLoading;
  DiscoverSort get sort => _sort;
  Tag? get selectedTag => _selectedTag;
  String get query => _query;
  List<Tag> get availableTags {
    final tags = <int, Tag>{};
    for (final book in _allBooks) {
      for (final tag in book.tags) {
        tags[tag.tagId] = tag;
      }
    }
    return tags.values.toList()..sort((a, b) => a.name.compareTo(b.name));
  }

  Future<void> fetchBooks() async {
    _isLoading = true;
    notifyListeners();
    try {
      _allBooks = await _bookRepository.getAllBooksWithDetails();
      _applyFilters();
    } catch (_) {
      _filteredBooks = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateQuery(String value) {
    _query = value;
    _applyFilters();
    notifyListeners();
  }

  void setSort(DiscoverSort sort) {
    _sort = sort;
    _applyFilters();
    notifyListeners();
  }

  void toggleTag(Tag tag) {
    if (_selectedTag?.tagId == tag.tagId) {
      _selectedTag = null;
    } else {
      _selectedTag = tag;
    }
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    final q = _query.trim().toLowerCase();
    _filteredBooks = _allBooks.where((book) {
      final matchesQuery =
          q.isEmpty ||
          book.title.toLowerCase().contains(q) ||
          (book.author?.name.toLowerCase().contains(q) ?? false);
      final matchesTag =
          _selectedTag == null ||
          book.tags.any((tag) => tag.tagId == _selectedTag!.tagId);
      return matchesQuery && matchesTag;
    }).toList();

    _filteredBooks.sort((a, b) {
      switch (_sort) {
        case DiscoverSort.newest:
          final aDate = a.releaseDate ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bDate = b.releaseDate ?? DateTime.fromMillisecondsSinceEpoch(0);
          return bDate.compareTo(aDate);
        case DiscoverSort.rating:
          return (b.rating ?? 0).compareTo(a.rating ?? 0);
      }
    });
  }


}
