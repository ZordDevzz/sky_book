import '../models/book.dart';
import '../models/chapter.dart';
import '../services/database_service.dart';

class BookRepository {
  final dbService = DatabaseService();

  Future<List<Book>> fetchFeaturedBooks() async {
    final db = await dbService.database;
    final List<Map<String, dynamic>> maps = await db.query('Book', orderBy: 'ViewCount_Weekly DESC', limit: 10);

    return List.generate(maps.length, (i) {
      return Book.fromMap(maps[i]);
    });
  }

  Future<Chapter?> getChapterContent(String bookId, double chapterIndex) async {
    final db = await dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Chapter',
      where: 'BookId = ? AND ChapterIndex = ?',
      whereArgs: [bookId, chapterIndex],
    );

    if (maps.isNotEmpty) {
      return Chapter.fromMap(maps.first);
    }
    return null;
  }
}
