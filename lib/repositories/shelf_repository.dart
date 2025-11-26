import 'package:postgres/postgres.dart';
import 'package:sky_book/models/shelf.dart';
import 'package:sky_book/services/database_service.dart';

class ShelfRepository {
  final DatabaseService _databaseService;

  ShelfRepository(this._databaseService);

  Future<List<Shelf>> getShelvesByUserId(String userId) async {
    final conn = await _databaseService.getConnection();
    final results = await conn.execute(
      Sql.named('SELECT * FROM shelf WHERE user_id = @userId'),
      parameters: {'userId': userId},
    );
    // print(  results);
    List<Shelf> shelves = [];
    for (final row in results) {
      final shelf = Shelf(
        userId: row[0] as String,
        bookId: row[1] as String,
        lastReadChapterId: row[2] != null ? row[2].toString() : null,
        lastReadDate: row[3] != null ? (row[3] as DateTime) : null,
        isArchived: row[4] as bool,
      );
      shelves.add(shelf);
    }
    return shelves;
  }

  Future<Shelf?> getShelfByBookAndUser(String bookId, String userId) async {
    final conn = await _databaseService.getConnection();
    final results = await conn.execute(
      Sql.named(
        'SELECT * FROM shelf WHERE user_id = @userId AND book_id = @bookId',
      ),
      parameters: {'userId': userId, 'bookId': bookId},
    );

    if (results.isEmpty) {
      return null;
    }

    final row = results.first;
    return Shelf(
      userId: row[0] as String,
      bookId: row[1] as String,
      lastReadChapterId: row[2] != null ? row[2].toString() : null,
      lastReadDate: row[3] != null ? (row[3] as DateTime) : null,
      isArchived: row[4] as bool,
    );
  }

  Future<void> addBookToShelf(Shelf shelf) async {
    final conn = await _databaseService.getConnection();
    await conn.execute(
      Sql.named(
        'INSERT INTO shelf (user_id, book_id, last_read_date) VALUES (@userId, @bookId, @lastReadDate) ON CONFLICT (user_id, book_id) DO NOTHING',
      ),
      parameters: {
        'userId': shelf.userId,
        'bookId': shelf.bookId,
        'lastReadDate': DateTime.now(),
      },
    );
  }

  Future<void> removeBookFromShelf(String userId, String bookId) async {
    final conn = await _databaseService.getConnection();
    await conn.execute(
      Sql.named(
        'DELETE FROM shelf WHERE user_id = @userId AND book_id = @bookId',
      ),
      parameters: {'userId': userId, 'bookId': bookId},
    );
  }

  Future<void> updateShelf(Shelf shelf) async {
    final conn = await _databaseService.getConnection();
    await conn.execute(
      Sql.named(
        'UPDATE shelf SET last_read_chapter_id = @lastReadChapterId, last_read_date = @lastReadDate, is_archived = @isArchived WHERE user_id = @userId AND book_id = @bookId',
      ),
      parameters: {
        'lastReadChapterId': shelf.lastReadChapterId,
        'lastReadDate': shelf.lastReadDate,
        'isArchived': shelf.isArchived,
        'userId': shelf.userId,
        'bookId': shelf.bookId,
      },
    );
  }
}
