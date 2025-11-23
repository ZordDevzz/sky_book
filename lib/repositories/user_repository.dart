import 'package:sky_book/models/user.dart';
import 'package:sky_book/services/database_service.dart';

class UserRepository {
  final dbService = DatabaseService();

  Future<User?> getFirstUser() async {
    final db = await dbService.database;
    final maps = await db.query('User', limit: 1);
    if (maps.isNotEmpty) return User.fromMap(maps.first);
    return null;
  }

  Future<User?> getUserById(String userId) async {
    final db = await dbService.database;
    final maps = await db.query(
      'User',
      where: 'UserId = ?',
      whereArgs: [userId],
      limit: 1,
    );
    if (maps.isNotEmpty) return User.fromMap(maps.first);
    return null;
  }

  Future<int> insertUser(User user) async {
    final db = await dbService.database;
    return await db.insert('User', user.toMap());
  }

  Future<int> updateUser(User user) async {
    final db = await dbService.database;
    return await db.update(
      'User',
      user.toMap(),
      where: 'UserId = ?',
      whereArgs: [user.userId],
    );
  }
}
