import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:postgres/postgres.dart';

class DatabaseService {
  static final DatabaseService _singleton = DatabaseService._internal();

  factory DatabaseService() {
    return _singleton;
  }

  DatabaseService._internal();

  Connection? _connection;

  Future<void> connect() async {
    if (_connection != null) {
      return; // Already connected
    }

    await dotenv.load(fileName: ".env");
    final connectionString = dotenv.env['DATABASE_URL'];

    if (connectionString == null) {
      throw Exception("DATABASE_URL not found in .env file");
    }

    try {
      _connection = await Connection.openFromUrl(connectionString);
      print('Database connection opened successfully.');
    } catch (e) {
      print('Error connecting to database: $e');
      _connection = null; // Reset connection on error
      rethrow;
    }
  }

  Future<void> disconnect() async {
    if (_connection != null) {
      await _connection!.close();
      _connection = null;
      print('Database connection closed.');
    }
  }

  Connection get connection {
    if (_connection == null) {
      throw Exception('Database not connected. Call connect() first.');
    }
    return _connection!;
  }
}
