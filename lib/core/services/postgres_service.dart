import 'package:postgres/postgres.dart';

class PostgresService {
  static const String _dbUrl = "postgresql://postgres:KEgzKGWblurkVUFSvOHTuGYjaFvwaPiB@postgres.railway.internal:5432/railway";
  
  static Connection? _connection;
  static bool _hasConnectionError = false;

  static bool get hasConnectionError => _hasConnectionError;

  static Future<Connection?> getConnection() async {
    if (_connection != null) {
      return _connection!;
    }

    try {
      // Parse database credentials from the URL
      // Scheme: postgresql://postgres:KEgzKGWblurkVUFSvOHTuGYjaFvwaPiB@postgres.railway.internal:5432/railway
      final uri = Uri.parse(_dbUrl);
      final userInfo = uri.userInfo.split(':');
      final username = userInfo[0];
      final password = userInfo.length > 1 ? userInfo[1] : '';
      final host = uri.host;
      final port = uri.port;
      final database = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : 'railway';

      _connection = await Connection.open(
        Endpoint(
          host: host,
          database: database,
          username: username,
          password: password,
          port: port,
        ),
        settings: const ConnectionSettings(
          sslMode: SslMode.disable,
          connectTimeout: Duration(seconds: 5),
        ),
      );
      _hasConnectionError = false;
      return _connection;
    } catch (e) {
      _hasConnectionError = true;
      _connection = null;
      // Fail gracefully for local simulation fallback
      return null;
    }
  }

  static Future<void> closeConnection() async {
    if (_connection != null) {
      await _connection!.close();
      _connection = null;
    }
  }
}
