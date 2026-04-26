import 'package:postgres/postgres.dart';

Connection? _connection;

/// Returns a PostgreSQL connection, reconnecting if the existing one is closed.
Future<Connection> getConnection() async {
  if (_connection == null || _connection!.isOpen == false) {
    _connection = await Connection.open(
      Endpoint(
        host: 'localhost',
        database: 'nrs',
        username: 'postgres',
        password: '2007',
      ),
      settings: const ConnectionSettings(sslMode: SslMode.disable),
    );
  }
  return _connection!;
}
