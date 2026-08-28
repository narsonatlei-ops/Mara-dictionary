import 'dart:io';
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
    // Standard Sqflite database path hman a him ber
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, _databaseName);

    bool exists = await databaseExists(path);

    if (!exists) {
      print("Database thar a ni a, assets aṭangin kan copy lût rih dawn...");
      try {
        await Directory(dirname(path)).create(recursive: true);

        // Assets folder aṭangin .db file kan chhiar ang (Slash '/' ngei hman tur)
        ByteData data = await rootBundle.load('assets/$_databaseName');
        List<int> bytes = data.buffer.asUint8List(
          data.offsetInBytes,
          data.lengthInBytes,
        );

        // Phone chhung hmun himah kan va dah (write) dawn a ni
        await File(path).writeAsBytes(bytes, flush: true);
        print("Database copy luh a hlawhtling ta!");
      } catch (e) {
        print("Database copy luhah buaina a awm: $e");
        // Copy a fail chuan DB ruak in-create lo nan file awm hman kha delete leh rawh
        if (await File(path).exists()) {
          await File(path).delete();
        }
        rethrow;
      }
    } else {
      print("Database a awm sa tawh e.");
    }

    // Database kan hawng ang
    final db = await openDatabase(path, version: _databaseVersion);

    // History leh column mamawh dangte kan va chei fel ang
    await _setupTablesAndColumns(db);

    return db;
  }

  // --- HISTORY LEH COLUMN NALH SAWNNA ---
  Future<void> _setupTablesAndColumns(Database db) async {
    // 1. History Table a la awm loh chuan kan siam chawp ang
    await db.execute('''
      CREATE TABLE IF NOT EXISTS history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        word_id INTEGER,
        word TEXT,
        meaning TEXT,
        timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // 2. word table-ah khan favorite leh custom column te kan va belh chawp ang
    List<String> alterQueries = [
      'ALTER TABLE "$_tableName" ADD COLUMN is_favorite INTEGER NOT NULL DEFAULT 0',
      'ALTER TABLE "$_tableName" ADD COLUMN synonyms TEXT',
      'ALTER TABLE "$_tableName" ADD COLUMN antonyms TEXT',
    ];

    for (String query in alterQueries) {
      try {
        await db.execute(query);
      } catch (_) {
        // Column a awm sa chuan ngaihthah (ignore) mai tur
      }
    }
  }

  // ==========================================================
  // APP BROWSE, SEARCH LEH FUNCTIONS DANG HO ZAWNG ZAWNG
  // ==========================================================

  // 1. Browse Screen atan (A bîka Hawrawp thlîrna)
  Future<List<WordModel>> getWordsByLetter(String letter) async {
    final db = await instance.database;
    final result = await db.rawQuery(
      'SELECT rowid AS id, word, definition, is_favorite, synonyms, antonyms FROM "$_tableName" WHERE word LIKE ? ORDER BY word ASC',
      ['$letter%'],
    );
    return result.map((json) => WordModel.fromMap(json)).toList();
  }

  // 2. Search Screen atan (Thumal zawnna)
  Future<List<WordModel>> searchWords(String query) async {
    final db = await instance.database;
    final result = await db.rawQuery(
      'SELECT rowid AS id, word, definition, is_favorite, synonyms, antonyms FROM "$_tableName" WHERE word LIKE ?',
      ['$query%'],
    );
    return result.map((json) => WordModel.fromMap(json)).toList();
  }

  // 3. Random Word (Home Screen vel atan)
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
    return maps.map((json) => WordModel.fromMap(json)).toList();
  }

  Future<int> updateFavoriteStatus(int id, int isFavorite) async {
    final db = await instance.database;
    return await db.update(
      _tableName,
      {'is_favorite': isFavorite},
      where: 'rowid = ?',
      whereArgs: [id],
    );
  }

  Future<bool> isWordFavorited(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      _tableName,
      where: 'rowid = ?',
      whereArgs: [id],
      columns: ['is_favorite'],
    );
    return maps.isNotEmpty && maps.first['is_favorite'] == 1;
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

  // 6. Synonyms & Antonyms update-na
  Future<int> updateWordSynAnt(int id, String synonyms, String antonyms) async {
    final db = await instance.database;
    return await db.update(
      _tableName,
      {'synonyms': synonyms, 'antonyms': antonyms},
      where: 'rowid = ?',
      whereArgs: [id],
    );
  }

  // 7. Database kharna
  Future<void> close() async {
    final db = await instance.database;
    db.close();
    _database = null;
  }
}
