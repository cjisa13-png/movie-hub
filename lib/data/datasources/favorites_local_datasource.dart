import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/movie_model.dart';

/// =============================================================================
///  FavoritesLocalDataSource
/// =============================================================================
///  Guarda la "Watchlist" (favoritos) en una base de datos local SQLite,
///  usando el paquete `sqflite`. Los datos persisten en el dispositivo aunque
///  se cierre la app o no haya conexión.
///
///  Elegimos SQLite (en vez de shared_preferences) porque guardamos una lista
///  de objetos con varios campos, y una tabla es la forma más ordenada y
///  escalable de hacerlo.
/// =============================================================================
class FavoritesLocalDataSource {
  static const _dbName = 'movie_hub.db';
  static const _dbVersion = 1;
  static const _table = 'favorites';

  Database? _db;

  /// Devuelve la base de datos, creándola/abriéndola la primera vez.
  Future<Database> get _database async {
    if (_db != null) return _db!;
    _db = await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _dbName);

    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        // Tabla de favoritos. La clave primaria es el id de TMDB, así que no
        // se pueden duplicar películas.
        await db.execute('''
          CREATE TABLE $_table (
            id            INTEGER PRIMARY KEY,
            title         TEXT NOT NULL,
            overview      TEXT,
            poster_path   TEXT,
            backdrop_path TEXT,
            vote_average  REAL,
            vote_count    INTEGER,
            release_date  TEXT,
            genre_ids     TEXT,
            added_at      INTEGER
          )
        ''');
      },
    );
  }

  /// Devuelve todos los favoritos, los más recientes primero.
  Future<List<MovieModel>> getAll() async {
    final db = await _database;
    final rows = await db.query(_table, orderBy: 'added_at DESC');
    return rows.map((r) => MovieModel.fromDbMap(r)).toList();
  }

  /// Añade (o reemplaza) una película en favoritos.
  Future<void> add(MovieModel movie) async {
    final db = await _database;
    final data = movie.toDbMap()
      ..['added_at'] = DateTime.now().millisecondsSinceEpoch;
    await db.insert(
      _table,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Elimina una película de favoritos por su id.
  Future<void> remove(int movieId) async {
    final db = await _database;
    await db.delete(_table, where: 'id = ?', whereArgs: [movieId]);
  }

  /// Comprueba si una película está en favoritos.
  Future<bool> isFavorite(int movieId) async {
    final db = await _database;
    final rows = await db.query(
      _table,
      columns: ['id'],
      where: 'id = ?',
      whereArgs: [movieId],
      limit: 1,
    );
    return rows.isNotEmpty;
  }
}
