import 'package:shadcn_flutter/shadcn_flutter.dart';
import '../models/shelf.dart';

class ShelfProvider extends ChangeNotifier {
  List<Shelf> _shelfs = [];
  List<Shelf> _myShelf = [];
  List<Shelf> _currentlyReading = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Shelf> get shelfs => _shelfs;
  List<Shelf> get myShelf => _myShelf;
  List<Shelf> get currentlyReading => _currentlyReading;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Fetch all books
  Future<void> fetchShelfs() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 1));

      // Mock data
      _shelfs = [
        Shelf(
          id: '1',
          title: 'The Great Adventure',
          author: 'John Doe',
          coverUrl: 'https://via.placeholder.com/150',
          description: 'An epic tale of courage and discovery...',
          genres: ['Fantasy', 'Adventure'],
          totalChapters: 45,
          rating: 4.5,
          views: 10000,
          publishedDate: DateTime.now().subtract(const Duration(days: 30)),
          isCompleted: true,
        ),
        Shelf(
          id: '2',
          title: 'Mystery of the Night',
          author: 'Jane Smith',
          coverUrl: 'https://via.placeholder.com/150',
          description: 'A thrilling mystery that will keep you guessing...',
          genres: ['Mystery', 'Thriller'],
          totalChapters: 30,
          rating: 4.8,
          views: 15000,
          publishedDate: DateTime.now().subtract(const Duration(days: 15)),
          isCompleted: false,
        ),
        Shelf(
          id: '3',
          title: 'Romance Under Stars',
          author: 'Emily Rose',
          coverUrl: 'https://via.placeholder.com/150',
          description: 'A heartwarming love story...',
          genres: ['Romance', 'Drama'],
          totalChapters: 25,
          rating: 4.3,
          views: 8000,
          publishedDate: DateTime.now().subtract(const Duration(days: 7)),
          isCompleted: false,
        ),
      ];

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to fetch books: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add book to shelf
  void addToShelf(Shelf shelf) {
    if (!_myShelf.any((s) => s.id == shelf.id)) {
      _myShelf.add(shelf);
      notifyListeners();
    }
  }

  // Remove book from shelf
  void removeFromShelf(String shelfId) {
    _myShelf.removeWhere((shelf) => shelf.id == shelfId);
    notifyListeners();
  }

  // Add to currently reading
  void addToCurrentlyReading(Shelf shelf) {
    if (!_currentlyReading.any((s) => s.id == shelf.id)) {
      _currentlyReading.add(shelf);
      notifyListeners();
    }
  }

  // Remove from currently reading
  void removeFromCurrentlyReading(String bookId) {
    _currentlyReading.removeWhere((book) => book.id == bookId);
    notifyListeners();
  }

  // Search books
  List<Shelf> searchShelfs(String query) {
    if (query.isEmpty) return _shelfs;

    return _shelfs.where((shelf) {
      return shelf.title.toLowerCase().contains(query.toLowerCase()) ||
          shelf.author.toLowerCase().contains(query.toLowerCase()) ||
          shelf.genres.any(
            (genre) => genre.toLowerCase().contains(query.toLowerCase()),
          );
    }).toList();
  }

  // Filter by genre
  List<Shelf> filterByGenre(String genre) {
    return _shelfs.where((shelf) => shelf.genres.contains(genre)).toList();
  }
}
