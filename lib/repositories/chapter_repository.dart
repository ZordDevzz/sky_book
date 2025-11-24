import 'package:postgres/postgres.dart';
import '../models/chapter.dart';
import '../services/database_service.dart';

class ChapterRepository {
  final DatabaseService _dbService;

  ChapterRepository() : _dbService = DatabaseService();

  Future<List<Chapter>> getChaptersForBook(String bookId) async {
    final Connection connection = _dbService.connection;
    final List<List<dynamic>> results = await connection.execute(
      Sql.named(
        'SELECT * FROM chapter WHERE book_id = @book_id ORDER BY chapter_index',
      ),
      parameters: {'book_id': bookId},
    );

    return results.map((row) {
      return Chapter(
        chapterId: row[0].toString(), // Assuming chapter_id is the first column
        bookId: row[1].toString(), // Assuming book_id is the second column
        title: row[2] as String,
        content: row[3] as String,
        chapterIndex: (row[4] as num).toDouble(),
        wordCount: row[5] as int?,
        publishDate: row[6] != null ? (row[6] as DateTime) : null,
      );
    }).toList();
  }

  Future<Chapter?> getChapterContent(String chapterId) async {
    final Connection connection = _dbService.connection;
    final List<List<dynamic>> results = await connection.execute(
      Sql.named(
        'SELECT * FROM chapter WHERE chapter_id = @chapter_id',
      ),
      parameters: {'chapter_id': chapterId},
    );

    if (results.isEmpty) {
      return null;
    }

    final row = results.first;
    return Chapter(
      chapterId: row[0].toString(),
      bookId: row[1].toString(),
      title: row[2] as String,
      content: row[3] as String,
      chapterIndex: (row[4] as num).toDouble(),
      wordCount: row[5] as int?,
      publishDate: row[6] != null ? (row[6] as DateTime) : null,
    );
  }
}
