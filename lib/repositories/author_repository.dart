import 'package:postgres/postgres.dart';
import 'package:sky_book/models/author.dart';
import 'package:sky_book/services/database_service.dart';

class AuthorRepository {
  final DatabaseService _dbService;
  final Map<String, Author> _authorCache = {};

  AuthorRepository({required DatabaseService dbService}) : _dbService = dbService;

  Future<Author?> getAuthorById(String id) async {
    if (_authorCache.containsKey(id)) {
      return _authorCache[id];
    }

    final Connection connection = _dbService.connection;
    final List<List<dynamic>> results = await connection.execute(
      Sql.named('SELECT author_id, name FROM author WHERE author_id = @id'),
      parameters: {'id': id},
    );

    if (results.isEmpty) {
      return null;
    }

    final row = results.first;
    final author = Author(
      authorId: row[0].toString(),
      name: row[1] as String,
    );

    _authorCache[id] = author;
    return author;
  }
}
