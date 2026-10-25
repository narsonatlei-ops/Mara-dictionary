import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/word_model.dart';

class DatabaseHelper {
  static const _databaseName = "word.db";
  static const int _databaseVersion = 1;
  static const _tableName = "word";
  static const _columns =
      'rowid AS id, word, definition, is_favorite, synonyms, antonyms';

  // Singleton: only one connection in the whole app
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  // ---------- Web version: word list kept in memory ----------
  static List<WordModel>? _webWords;

  Future<List<WordModel>> _loadWebWords() async {
    if (_webWords != null) return _webWords!;
    final jsonStr = await rootBundle.loadString('assets/dictionary.json');
    final List<dynamic> data = json.decode(jsonStr);
    _webWords = [
      for (int i = 0; i < data.length; i++)
        WordModel.fromMap({
          ...Map<String, dynamic>.from(data[i] as Map),
          'id': i + 1,
        }),
    ];
    return _webWords!;
  }

  // ---------- Android version: SQLite ----------
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);

    // First launch: copy the ready-made word.db from the assets
    if (!await databaseExists(path)) {
      try {
        await Directory(dirname(path)).create(recursive: true);
        final data = await rootBundle.load('assets/$_databaseName');
        final bytes = data.buffer.asUint8List(
          data.offsetInBytes,
          data.lengthInBytes,
        );
        await File(path).writeAsBytes(bytes, flush: true);
      } catch (e) {
        if (await File(path).exists()) await File(path).delete();
        rethrow;
      }
    }

    final db = await openDatabase(path, version: _databaseVersion);
    await _setupTablesAndColumns(db);
    return db;
  }

  Future<void> _setupTablesAndColumns(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        word_id INTEGER,
        word TEXT,
        meaning TEXT,
        timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Add the extra columns; an error means the column already exists
    for (final query in [
      'ALTER TABLE "$_tableName" ADD COLUMN is_favorite INTEGER NOT NULL DEFAULT 0',
      'ALTER TABLE "$_tableName" ADD COLUMN synonyms TEXT',
      'ALTER TABLE "$_tableName" ADD COLUMN antonyms TEXT',
    ]) {
      try {
        await db.execute(query);
      } catch (_) {}
    }

    await db.execute(
      'UPDATE "$_tableName" SET is_favorite = 0 WHERE is_favorite IS NULL',
    );
  }

  // ==========================================================
  // WORD QUERIES
  // ==========================================================

  Future<List<WordModel>> getWordsByLetter(String letter) async {
    if (kIsWeb) {
      final all = await _loadWebWords();
      final l = letter.toLowerCase();
      final list = all
          .where((w) => w.word.toLowerCase().startsWith(l))
          .toList();
      list.sort((a, b) => a.word.toLowerCase().compareTo(b.word.toLowerCase()));
      return list;
    }
    final db = await instance.database;
    final result = await db.rawQuery(
      'SELECT $_columns FROM "$_tableName" WHERE word LIKE ? ORDER BY word ASC',
      ['$letter%'],
    );
    return result.map((json) => WordModel.fromMap(json)).toList();
  }

  // Search: words that start with the text, or (contains = true) that contain it
  Future<List<WordModel>> searchWords(
    String query, {
    bool contains = false,
  }) async {
    if (kIsWeb) {
      final all = await _loadWebWords();
      final q = query.toLowerCase();
      final list = all.where((w) {
        final word = w.word.toLowerCase();
        return contains ? word.contains(q) : word.startsWith(q);
      }).toList();
      if (contains) {
        // words that start with the text come first
        list.sort((a, b) {
          final aw = a.word.toLowerCase();
          final bw = b.word.toLowerCase();
          final aStarts = aw.startsWith(q) ? 0 : 1;
          final bStarts = bw.startsWith(q) ? 0 : 1;
          return aStarts != bStarts ? aStarts - bStarts : aw.compareTo(bw);
        });
      }
      return list.take(100).toList();
    }

    final db = await instance.database;
    final result = contains
        ? await db.rawQuery(
            'SELECT $_columns FROM "$_tableName" WHERE word LIKE ? '
            'ORDER BY CASE WHEN word LIKE ? THEN 0 ELSE 1 END, word LIMIT 100',
            ['%$query%', '$query%'],
          )
        : await db.rawQuery(
            'SELECT $_columns FROM "$_tableName" WHERE word LIKE ? '
            'ORDER BY word LIMIT 100',
            ['$query%'],
          );
    return result.map((json) => WordModel.fromMap(json)).toList();
  }

  Future<WordModel?> getRandomWord() async {
    if (kIsWeb) {
      final all = await _loadWebWords();
      if (all.isEmpty) return null;
      return (all.toList()..shuffle()).first;
    }
    final db = await instance.database;
    final maps = await db.rawQuery(
      'SELECT $_columns FROM "$_tableName" ORDER BY RANDOM() LIMIT 1',
    );
    return maps.isNotEmpty ? WordModel.fromMap(maps.first) : null;
  }

  Future<WordModel?> getWordDetails(String wordText) async {
    if (kIsWeb) {
      final all = await _loadWebWords();
      for (final w in all) {
        if (w.word == wordText) return w;
      }
      return null;
    }
    final db = await instance.database;
    final maps = await db.rawQuery(
      'SELECT $_columns FROM "$_tableName" WHERE word = ? LIMIT 1',
      [wordText],
    );
    return maps.isNotEmpty ? WordModel.fromMap(maps.first) : null;
  }

  // ==========================================================
  // FAVORITES (Android only)
  // ==========================================================

  Future<List<WordModel>> getFavoriteWords() async {
    if (kIsWeb) return [];
    final db = await instance.database;
    final maps = await db.rawQuery(
      'SELECT $_columns FROM "$_tableName" WHERE is_favorite = 1 ORDER BY word ASC',
    );
    return maps.map((json) => WordModel.fromMap(json)).toList();
  }

  Future<int> updateFavoriteStatus(int id, int isFavorite) async {
    if (kIsWeb) return 0;
    final db = await instance.database;
    return await db.rawUpdate(
      'UPDATE "$_tableName" SET is_favorite = ? WHERE rowid = ?',
      [isFavorite, id],
    );
  }

  Future<bool> isWordFavorited(int id) async {
    if (kIsWeb) return false;
    final db = await instance.database;
    final maps = await db.rawQuery(
      'SELECT is_favorite FROM "$_tableName" WHERE rowid = ? LIMIT 1',
      [id],
    );
    return maps.isNotEmpty && (maps.first['is_favorite'] ?? 0) == 1;
  }

  // Remove every word from the favorites (Favorites screen: Clear all)
  Future<int> clearFavorites() async {
    if (kIsWeb) return 0;
    final db = await instance.database;
    return await db.rawUpdate(
      'UPDATE "$_tableName" SET is_favorite = 0 WHERE is_favorite = 1',
    );
  }

  // ==========================================================
  // HISTORY (Android only)
  // ==========================================================

  Future<void> addToHistory(int wordId, String word, String meaning) async {
    if (kIsWeb) return;
    final db = await instance.database;
    await db.delete('history', where: 'word_id = ?', whereArgs: [wordId]);
    await db.insert('history', {
      'word_id': wordId,
      'word': word,
      'meaning': meaning,
    });
  }

  Future<List<Map<String, dynamic>>> getHistory() async {
    if (kIsWeb) return [];
    final db = await instance.database;
    return await db.query('history', orderBy: 'id DESC');
  }

  Future<void> clearHistory() async {
    if (kIsWeb) return;
    final db = await instance.database;
    await db.delete('history');
  }

  // ==========================================================
  // SYNONYMS AND ANTONYMS CACHE (Android only)
  // ==========================================================

  Future<int> updateWordSynAnt(int id, String synonyms, String antonyms) async {
    if (kIsWeb) return 0;
    final db = await instance.database;
    return await db.rawUpdate(
      'UPDATE "$_tableName" SET synonyms = ?, antonyms = ? WHERE rowid = ?',
      [synonyms, antonyms, id],
    );
  }
}
