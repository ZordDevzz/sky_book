import 'package:postgres/postgres.dart';
import '../models/chapter.dart';
import '../services/database_service.dart';

class ChapterRepository {
  final DatabaseService _dbService;

  ChapterRepository({required DatabaseService dbService})
    : _dbService = dbService;

  Future<List<Chapter>> getChaptersForBook(String bookId) async {
    final Connection connection = await _dbService.getConnection();

    print("Getting chapters for book $bookId from database...");
    final List<List<dynamic>> results = await connection.execute(
      Sql.named(
        '''SELECT chapter_id, book_id, title, chapter_index, word_count, publish_date 
        FROM chapter 
        WHERE book_id = @book_id
        ORDER BY chapter_index''',
      ),
      parameters: {'book_id': bookId},
    );
    print('Chapters fetched: ${results.length}');
    return results.map((row) {
      return Chapter(
        chapterId: row[0].toString(), // Assuming chapter_id is the first column
        bookId: row[1].toString(), 
        title: row[2] as String,
        content: '',
        chapterIndex: double.parse(row[3].toString()),
        wordCount: row[4] as int?,
        publishDate: row[5] != null ? (row[5] as DateTime) : null,
      );
    }).toList();
  }

  Future<Map<String, int>> getChapterCountsForBooks(List<String> bookIds) async {
    if (bookIds.isEmpty) {
      return {};
    }
    final Connection connection = await _dbService.getConnection();
    final results = await connection.execute(
      Sql.named('''
        SELECT book_id, COUNT(chapter_id) as chapter_count
        FROM chapter
        WHERE book_id = ANY(@book_ids)
        GROUP BY book_id
      '''),
      parameters: {'book_ids': bookIds},
    );

    final counts = <String, int>{};
    for (final row in results) {
      counts[row[0].toString()] = row[1] as int;
    }
    return counts;
  }

  Future<Map<String, Chapter>> getChaptersByIds(List<String> chapterIds) async {
    if (chapterIds.isEmpty) {
      return {};
    }
    final Connection connection = await _dbService.getConnection();
    final results = await connection.execute(
      Sql.named('SELECT chapter_id, book_id, title, chapter_index, word_count, publish_date FROM chapter WHERE chapter_id = ANY(@ids)'),
      parameters: {'ids': chapterIds},
    );

    final chaptersById = <String, Chapter>{};
    for (final row in results) {
      chaptersById[row[0].toString()] = Chapter(
        chapterId: row[0].toString(),
        bookId: row[1].toString(),
        title: row[2] as String,
        content: '',
        chapterIndex: double.parse(row[3].toString()),
        wordCount: row[4] as int?,
        publishDate: row[5] != null ? (row[5] as DateTime) : null,
      );
    }
    return chaptersById;
  }

  Future<Chapter?> getChapterContent(String chapterId) async {
    final Connection connection = await _dbService.getConnection();
    final List<List<dynamic>> results = await connection.execute(
      Sql.named('SELECT * FROM chapter WHERE chapter_id = @chapter_id'),
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
      chapterIndex: double.tryParse(row[4].toString()) ?? 0.0,
      wordCount: row[5] as int?,
      publishDate: row[6] != null ? (row[6] as DateTime) : null,
    );
  }
}
