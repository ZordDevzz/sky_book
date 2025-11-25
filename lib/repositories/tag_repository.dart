import 'package:postgres/postgres.dart';
import 'package:sky_book/models/tag.dart';
import 'package:sky_book/services/database_service.dart';

class TagRepository {
  final DatabaseService _dbService;

  TagRepository({required DatabaseService dbService}) : _dbService = dbService;

  Future<Map<String, List<Tag>>> getTagsForBooks(List<String> bookIds) async {
    if (bookIds.isEmpty) return {};

    final connection = await _dbService.getConnection();

    final results = await connection.execute(
      Sql.named('''
        SELECT bt.book_id, t.tag_id, t.name
        FROM book_tag bt
        JOIN tag t ON bt.tag_id = t.tag_id
        WHERE bt.book_id = ANY(@bookIds)
      '''),
      parameters: {'bookIds': bookIds},
    );

    final map = <String, List<Tag>>{};

    for (final row in results) {
      final bookId = row[0].toString();
      final tag = Tag(
        tagId: row[1] as int,
        name: row[2] as String,
      );

      if (!map.containsKey(bookId)) {
        map[bookId] = [];
      }
      map[bookId]!.add(tag);
    }

    return map;
  }
}
