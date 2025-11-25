import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:postgres/postgres.dart';
import 'package:uuid/uuid.dart';

import '../models/user.dart';
import '../services/database_service.dart';

class UserRepository {
  UserRepository({required DatabaseService dbService}) : _dbService = dbService;

  final DatabaseService _dbService;
  final Uuid _uuid = const Uuid();

  Future<User?> getUserById(String userId) async {
    final Connection connection = await _dbService.getConnection();
    final results = await connection.execute(
      Sql.named(
        '''
        SELECT user_id, username, passwd_hash, pfp_url, created_at
        FROM users
        WHERE user_id = @user_id
        LIMIT 1
        ''',
      ),
      parameters: {'user_id': userId},
    );

    if (results.isEmpty) return null;
    return _mapRowToUser(results.first);
  }

  Future<User?> getUserByUsername(String username) async {
    final Connection connection = await _dbService.getConnection();
    final results = await connection.execute(
      Sql.named(
        '''
        SELECT user_id, username, passwd_hash, pfp_url, created_at
        FROM users
        WHERE username = @username
        LIMIT 1
        ''',
      ),
      parameters: {'username': username},
    );

    if (results.isEmpty) return null;
    return _mapRowToUser(results.first);
  }

  Future<User> register({
    required String username,
    required String password,
  }) async {
    final existing = await getUserByUsername(username);
    if (existing != null) {
      throw Exception('Tên người dùng đã tồn tại');
    }

    final Connection connection = await _dbService.getConnection();
    final now = DateTime.now();
    final userId = _uuid.v4();
    final hashedPassword = _hashPassword(password);

    final results = await connection.execute(
      Sql.named(
        '''
        INSERT INTO users (user_id, username, passwd_hash, created_at)
        VALUES (@user_id, @username, @passwd_hash, @created_at)
        RETURNING user_id, username, passwd_hash, pfp_url, created_at
        ''',
      ),
      parameters: {
        'user_id': userId,
        'username': username,
        'passwd_hash': hashedPassword,
        'created_at': now,
      },
    );

    return _mapRowToUser(results.first);
  }

  Future<User> login({
    required String username,
    required String password,
  }) async {
    final user = await getUserByUsername(username);
    if (user == null) {
      throw Exception('Sai tài khoản hoặc mật khẩu');
    }

    final hashed = _hashPassword(password);
    if (hashed != user.passwdHash) {
      throw Exception('Sai tài khoản hoặc mật khẩu');
    }

    return user;
  }

  Future<User> updateProfile({
    required String userId,
    required String username,
    String? pfpUrl,
  }) async {
    final Connection connection = await _dbService.getConnection();
    final results = await connection.execute(
      Sql.named(
        '''
        UPDATE users
        SET username = @username, pfp_url = @pfp_url
        WHERE user_id = @user_id
        RETURNING user_id, username, passwd_hash, pfp_url, created_at
        ''',
      ),
      parameters: {
        'user_id': userId,
        'username': username,
        'pfp_url': pfpUrl,
      },
    );

    if (results.isEmpty) {
      throw Exception('Không tìm thấy người dùng');
    }

    return _mapRowToUser(results.first);
  }

  User _mapRowToUser(List<dynamic> row) {
    return User(
      userId: row[0].toString(),
      username: row[1] as String,
      passwdHash: row[2] as String,
      pfpUrl: row[3] as String?,
      createdAt: row[4] is DateTime ? row[4] as DateTime : null,
    );
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }
}
