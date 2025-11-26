import 'package:postgres/postgres.dart';
import '../models/chapter.dart';
import '../services/database_service.dart';

class ChapterRepository {
  final DatabaseService _dbService;
  final Map<String, List<Chapter>> _chaptersByBookId = {};
  final Map<String, Chapter> _chapterCache = {};

  ChapterRepository({required DatabaseService dbService})
      : _dbService = dbService;

  Future<List<Chapter>> getChaptersForBook(String bookId) async {
    if (_chaptersByBookId.containsKey(bookId)) {
      return _chaptersByBookId[bookId]!;
    }

    final Connection connection = await _dbService.getConnection();
    final List<List<dynamic>> results = await connection.execute(
      Sql.named(
        '''SELECT chapter_id, book_id, title, content, chapter_index, word_count, publish_date 
        FROM chapter 
        WHERE book_id = @book_id
        ORDER BY chapter_index''',
      ),
      parameters: {'book_id': bookId},
    );

    final chapters = results.map((row) {
      return Chapter(
        chapterId: row[0].toString(),
        bookId: row[1].toString(),
        title: row[2] as String,
        content: row[3] as String? ?? '',
        chapterIndex: double.parse(row[4].toString()),
        wordCount: row[5] as int?,
        publishDate: row[6] != null ? (row[6] as DateTime) : null,
      );
    }).toList();

    _chaptersByBookId[bookId] = chapters;
    for (final c in chapters) {
      _chapterCache[c.chapterId] = c;
    }
    return chapters;
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
    final cached = <String, Chapter>{};
    final missing = <String>[];
    for (final id in chapterIds) {
      if (_chapterCache.containsKey(id)) {
        cached[id] = _chapterCache[id]!;
      } else {
        missing.add(id);
      }
    }
    if (missing.isEmpty) return cached;

    final Connection connection = await _dbService.getConnection();
    final results = await connection.execute(
      Sql.named(
        'SELECT chapter_id, book_id, title, content, chapter_index, word_count, publish_date FROM chapter WHERE chapter_id = ANY(@ids)',
      ),
      parameters: {'ids': missing},
    );

    for (final row in results) {
      final chapter = Chapter(
        chapterId: row[0].toString(),
        bookId: row[1].toString(),
        title: row[2] as String,
        content: row[3] as String? ?? '',
        chapterIndex: double.parse(row[4].toString()),
        wordCount: row[5] as int?,
        publishDate: row[6] != null ? (row[6] as DateTime) : null,
      );
      _chapterCache[chapter.chapterId] = chapter;
      cached[chapter.chapterId] = chapter;
    }
    return cached;
  }

  Future<Chapter?> getChapterContent(String chapterId) async {
    if (_chapterCache.containsKey(chapterId) &&
        _chapterCache[chapterId]!.content.isNotEmpty) {
      return _chapterCache[chapterId];
    }
    final Connection connection = await _dbService.getConnection();
    final List<List<dynamic>> results = await connection.execute(
      Sql.named('SELECT * FROM chapter WHERE chapter_id = @chapter_id'),
      parameters: {'chapter_id': chapterId},
    );

    if (results.isEmpty) {
      return null;
    }

    final row = results.first;
    final chapter = Chapter(
      chapterId: row[0].toString(),
      bookId: row[1].toString(),
      title: row[2] as String,
      content: row[3] as String,
      chapterIndex: double.tryParse(row[4].toString()) ?? 0.0,
      wordCount: row[5] as int?,
      publishDate: row[6] != null ? (row[6] as DateTime) : null,
    );
    _chapterCache[chapter.chapterId] = chapter;
    return chapter;
  }
}
