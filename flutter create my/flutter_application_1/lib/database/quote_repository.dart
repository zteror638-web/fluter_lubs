import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';
import '../models/quote.dart';

class QuoteRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<void> addToFavorites(Quote quote) async {
    final Database db = await _dbHelper.database;
    
    await db.insert(
      DatabaseHelper.TABLE_QUOTES,
      {
        'id': quote.id,
        'content': quote.content,
        'author': quote.author,
        'isFavorite': 1,
        'dateAdded': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Quote>> getFavoriteQuotes() async {
    final Database db = await _dbHelper.database;
    
    final List<Map<String, dynamic>> quoteMaps = await db.query(
      DatabaseHelper.TABLE_QUOTES,
      where: 'isFavorite = ?',
      whereArgs: [1],
      orderBy: 'dateAdded DESC',
    );

    return quoteMaps.map((map) => Quote.fromDatabase(map)).toList();
  }

  Future<void> removeFromFavorites(String quoteId) async {
    final Database db = await _dbHelper.database;
    await db.delete(
      DatabaseHelper.TABLE_QUOTES,
      where: 'id = ?',
      whereArgs: [quoteId],
    );
  }

  Future<void> updateLastViewed(String quoteId) async {
    final Database db = await _dbHelper.database;
    await db.update(
      DatabaseHelper.TABLE_QUOTES,
      {'lastViewed': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [quoteId],
    );
  }
}