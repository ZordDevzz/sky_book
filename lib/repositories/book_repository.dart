import 'package:postgres/postgres.dart';
import '../models/book.dart';
import '../services/database_service.dart';
import 'author_repository.dart';

class BookRepository {
  final DatabaseService _dbService;
  final AuthorRepository _authorRepository;

  BookRepository({
    required DatabaseService dbService,
    required AuthorRepository authorRepository,
  }) : _dbService = dbService,
       _authorRepository = authorRepository;

  Future<List<Book>> getAllBooks() async {
    final Connection connection = _dbService.connection;
    print("Getting all books from database...");
    final List<List<dynamic>> results = await connection.execute(
      Sql.named('SELECT * FROM book'),
    );

    List<Book> books = [];
    for (var row in results) {
      final book = Book(
        bookId: row[0].toString(),
        title: row[1] as String,
        authorId: row[2].toString(),
        description: row[3] as String?,
        coverImageUrl: row[4] as String?,
        releaseDate: row[5] != null ? (row[5] as DateTime) : null,
        status: row[6] as String?,
        rating: double.tryParse(row[7]?.toString() ?? ''),
        viewCountTotal: row[8] as int?,
        viewCountMonthly: row[9] as int?,
        viewCountWeekly: row[10] as int?,
      );
      books.add(book);
    }
    return books;
  }

  Future<List<Book>> getAllBooksWithAuthors() async {
    final sw = Stopwatch()..start();
    final books = await getAllBooks();
    print('getAllBooks took: ${sw.elapsedMilliseconds} ms');

    sw.reset();
    sw.start();
    if (books.isEmpty) return books;

    final authorIds = books.map((b) => b.authorId).toSet().toList();

    final authorsById = await _authorRepository.getAuthorsByIds(authorIds);
    print('attach authors took: ${sw.elapsedMilliseconds} ms');

    for (final book in books) {
      book.author = authorsById[book.authorId];
    }

    return books;
  }

  Future<Book?> getBookById(String id) async {
    final Connection connection = _dbService.connection;
    final List<List<dynamic>> results = await connection.execute(
      Sql.named('SELECT * FROM book WHERE book_id = @id'),
      parameters: {'id': id},
    );

    if (results.isEmpty) {
      return null;
    }

    final row = results.first;
    final book = Book(
      bookId: row[0].toString(),
      title: row[1] as String,
      authorId: row[2].toString(),
      description: row[3] as String?,
      coverImageUrl: row[4] as String?,
      releaseDate: row[5] != null ? (row[5] as DateTime) : null,
      status: row[6] as String?,
      rating: double.tryParse(row[7]?.toString() ?? ''),
      viewCountTotal: row[8] as int?,
      viewCountMonthly: row[9] as int?,
      viewCountWeekly: row[10] as int?,
    );
    book.author = await _authorRepository.getAuthorById(book.authorId);
    return book;
  }

  Future<void> addBook(Book book) async {
    final Connection connection = _dbService.connection;
    await connection.execute(
      Sql.named('''
      INSERT INTO book (book_id, title, author_id, description, cover_image_url, release_date, status, rating, view_count_total, view_count_monthly, view_count_weekly)
      VALUES (@book_id, @title, @author_id, @description, @cover_image_url, @release_date, @status, @rating, @view_count_total, @view_count_monthly, @view_count_weekly)
      '''),
      parameters: {
        'book_id': book.bookId,
        'title': book.title,
        'author_id': book.authorId,
        'description': book.description,
        'cover_image_url': book.coverImageUrl,
        'release_date': book.releaseDate,
        'status': book.status,
        'rating': book.rating,
        'view_count_total': book.viewCountTotal,
        'view_count_monthly': book.viewCountMonthly,
        'view_count_weekly': book.viewCountWeekly,
      },
    );
  }
}
