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

  // Singleton Instance
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, _databaseName);

    bool exists = await databaseExists(path);

    if (!exists) {
      if (kDebugMode) {
        print("Database thar a ni a, assets aṭangin kan copy lût rih dawn...");
      }
      try {
        await Directory(dirname(path)).create(recursive: true);

        ByteData data = await rootBundle.load('assets/$_databaseName');
        List<int> bytes = data.buffer.asUint8List(
          data.offsetInBytes,
          data.lengthInBytes,
        );

        await File(path).writeAsBytes(bytes, flush: true);
        if (kDebugMode) print("Database copy luh a hlawhtling ta!");
      } catch (e) {
        if (kDebugMode) print("Database copy luhah buaina a awm: $e");
        if (await File(path).exists()) {
          await File(path).delete();
        }
        rethrow;
      }
    } else {
      if (kDebugMode) print("Database a awm sa tawh e.");
    }

    final db = await openDatabase(path, version: _databaseVersion);

    // History leh column mamawh dangte va chei fel
    await _setupTablesAndColumns(db);

    return db;
  }

  // --- HISTORY LEH COLUMN FIX ---
  Future<void> _setupTablesAndColumns(Database db) async {
    // 1. History Table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        word_id INTEGER,
        word TEXT,
        meaning TEXT,
        timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // 2. Column belh tur ho
    List<String> alterQueries = [
      'ALTER TABLE "$_tableName" ADD COLUMN is_favorite INTEGER NOT NULL DEFAULT 0',
      'ALTER TABLE "$_tableName" ADD COLUMN synonyms TEXT',
      'ALTER TABLE "$_tableName" ADD COLUMN antonyms TEXT',
    ];

    for (String query in alterQueries) {
      try {
        await db.execute(query);
      } catch (_) {
        // Column a awm sa chuan a pass mai ang
      }
    }

    // 3. FIX: NULL data ho zawng zawng 0-ah siam chhuah leh nan
    try {
      await db.execute(
        'UPDATE "$_tableName" SET is_favorite = 0 WHERE is_favorite IS NULL',
      );
    } catch (e) {
      if (kDebugMode) print("Error normalizing favorites: $e");
    }
  }

  // ==========================================================
  // APP FUNCTIONS
  // ==========================================================

  // 1. Browse Screen (Hawrawp thlîrna)
  Future<List<WordModel>> getWordsByLetter(String letter) async {
    final db = await instance.database;
    final result = await db.rawQuery(
      'SELECT rowid AS id, word, definition, is_favorite, synonyms, antonyms FROM "$_tableName" WHERE word LIKE ? ORDER BY word ASC',
      ['$letter%'],
    );
    return result.map((json) => WordModel.fromMap(json)).toList();
  }

  // 2. Search Screen
  Future<List<WordModel>> searchWords(String query) async {
    final db = await instance.database;
    final result = await db.rawQuery(
      'SELECT rowid AS id, word, definition, is_favorite, synonyms, antonyms FROM "$_tableName" WHERE word LIKE ?',
      ['$query%'],
    );
    return result.map((json) => WordModel.fromMap(json)).toList();
  }

  // 3. Random Word
  Future<WordModel?> getRandomWord() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT rowid AS id, word, definition, is_favorite, synonyms, antonyms FROM "$_tableName" ORDER BY RANDOM() LIMIT 1',
    );
    if (maps.isNotEmpty) return WordModel.fromMap(maps.first);
    return null;
  }

  // 4. FAVORITE FUNCTIONS
  Future<List<WordModel>> getFavoriteWords() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT rowid AS id, word, definition, is_favorite, synonyms, antonyms FROM "$_tableName" WHERE is_favorite = 1 ORDER BY word ASC',
    );
    if (kDebugMode) print("Favorites fetched count: ${maps.length}");
    return maps.map((json) => WordModel.fromMap(json)).toList();
  }

  Future<int> updateFavoriteStatus(int id, int isFavorite) async {
    final db = await instance.database;

    // rowid leh id column awm palh pawha match ve ve thei turin rawUpdate kan hmang
    int count = await db.rawUpdate(
      'UPDATE "$_tableName" SET is_favorite = ? WHERE rowid = ? OR id = ?',
      [isFavorite, id, id],
    );

    if (kDebugMode) {
      print(
        "Favorite status updated. Row ID: $id, New Status: $isFavorite, Rows Affected: $count",
      );
    }
    return count;
  }

  Future<bool> isWordFavorited(int id) async {
    final db = await instance.database;
    final maps = await db.rawQuery(
      'SELECT is_favorite FROM "$_tableName" WHERE rowid = ? OR id = ? LIMIT 1',
      [id, id],
    );
    if (maps.isNotEmpty) {
      return (maps.first['is_favorite'] ?? 0) == 1;
    }
    return false;
  }

  // 5. HISTORY FUNCTIONS
  Future<void> addToHistory(int wordId, String word, String meaning) async {
    final db = await instance.database;
    await db.delete('history', where: 'word_id = ?', whereArgs: [wordId]);
    await db.insert('history', {
      'word_id': wordId,
      'word': word,
      'meaning': meaning,
    });
  }

  Future<List<Map<String, dynamic>>> getHistory() async {
    final db = await instance.database;
    return await db.query('history', orderBy: 'id DESC');
  }

  Future<void> clearHistory() async {
    final db = await instance.database;
    await db.delete('history');
  }

  // 6. Synonyms & Antonyms
  Future<int> updateWordSynAnt(int id, String synonyms, String antonyms) async {
    final db = await instance.database;
    return await db.rawUpdate(
      'UPDATE "$_tableName" SET synonyms = ?, antonyms = ? WHERE rowid = ? OR id = ?',
      [synonyms, antonyms, id, id],
    );
  }

  // 7. GET WORD DETAILS
  Future<WordModel?> getWordDetails(String wordText) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT rowid AS id, word, definition, is_favorite, synonyms, antonyms FROM "$_tableName" WHERE word = ? LIMIT 1',
      [wordText],
    );
    if (maps.isNotEmpty) {
      return WordModel.fromMap(maps.first);
    }
    return null;
  }

  // 8. Database kharna
  Future<void> close() async {
    final db = await instance.database;
    db.close();
    _database = null;
  }
}
