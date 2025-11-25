import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:postgres/postgres.dart';

class DatabaseService {
  DatabaseService() {
    _connectionFuture = _connect();
  }

  Connection? _connection;
  late Future<void> _connectionFuture;

  bool get isConnected => _connection != null && _connection?.isOpen == true;

  Future<void> _connect() async {
    await dotenv.load(fileName: ".env");
    final dbHost = dotenv.env['HOST'];
    final dbPort = int.tryParse(dotenv.env['PORT'] ?? '');
    final dbName = dotenv.env['DB_NAME'];
    final dbUser = dotenv.env['DB_USER'];
    final dbPassword = dotenv.env['DB_PASSWORD'];
    if (dbHost == null ||
        dbPort == null ||
        dbName == null ||
        dbUser == null ||
        dbPassword == null) {
      throw Exception("Database configuration not found in .env file");
    }

    try {
      _connection = await Connection.open(
        Endpoint(
          host: dbHost,
          port: dbPort,
          database: dbName,
          username: dbUser,
          password: dbPassword,
        ),
        settings: const ConnectionSettings(
          connectTimeout: Duration(seconds: 15),
        ),
      );
      print('Database connection opened successfully.');
    } catch (e) {
      print('Error connecting to database: $e');
      _connection = null; // Reset connection on error
      rethrow;
    }
  }

  Future<void> dispose() async {
    if (isConnected) {
      await _connection!.close();
      _connection = null;
      print('Database connection closed.');
    }
  }

  Future<Connection> getConnection() async {
    if (!isConnected) {
      print('Connection is not open. Reconnecting...');
      _connectionFuture = _connect();
      await _connectionFuture;
    }
    if (_connection == null) {
      throw Exception(
        'Database not connected. The connection might still be initializing or it failed.',
      );
    }
    return _connection!;
  }

  Future<void> get connectionFuture => _connectionFuture;
}
