import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';
import '../models/quote.dart';

class QuoteRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Сохранение цитаты в избранное
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

    // Сохраняем теги, если они есть
    for (var tag in quote.tags) {
      await _addTag(tag);
      await _linkQuoteToTag(quote.id, tag);
    }
  }

  Future<void> _addTag(String tagName) async {
    final Database db = await _dbHelper.database;
    
    await db.insert(
      DatabaseHelper.TABLE_TAGS,
      {'name': tagName},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> _linkQuoteToTag(String quoteId, String tagName) async {
    final Database db = await _dbHelper.database;
    
    // Получаем ID тега
    final List<Map<String, dynamic>> tagMaps = await db.query(
      DatabaseHelper.TABLE_TAGS,
      where: 'name = ?',
      whereArgs: [tagName],
    );

    if (tagMaps.isNotEmpty) {
      final tagId = tagMaps.first['id'];
      
      await db.insert(
        DatabaseHelper.TABLE_QUOTE_TAGS,
        {'quoteId': quoteId, 'tagId': tagId},
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  // Получение избранных цитат
  Future<List<Quote>> getFavoriteQuotes() async {
    final Database db = await _dbHelper.database;
    
    final List<Map<String, dynamic>> quoteMaps = await db.query(
      DatabaseHelper.TABLE_QUOTES,
      where: 'isFavorite = ?',
      whereArgs: [1],
      orderBy: 'dateAdded DESC',
    );

    List<Quote> quotes = [];
    for (var map in quoteMaps) {
      // Получаем теги для цитаты
      final tags = await getTagsForQuote(map['id']);
      
      quotes.add(Quote(
        id: map['id'],
        content: map['content'],
        author: map['author'],
        tags: tags,
        isFavorite: true,
      ));
    }
    
    return quotes;
  }

  // Получение тегов для цитаты
  Future<List<String>> getTagsForQuote(String quoteId) async {
    final Database db = await _dbHelper.database;
    
    final List<Map<String, dynamic>> tagMaps = await db.rawQuery('''
      SELECT t.name 
      FROM ${DatabaseHelper.TABLE_TAGS} t
      INNER JOIN ${DatabaseHelper.TABLE_QUOTE_TAGS} qt ON t.id = qt.tagId
      WHERE qt.quoteId = ?
    ''', [quoteId]);

    return tagMaps.map((map) => map['name'] as String).toList();
  }

  // Удаление из избранного
  Future<void> removeFromFavorites(String quoteId) async {
    final Database db = await _dbHelper.database;
    await db.delete(
      DatabaseHelper.TABLE_QUOTES,
      where: 'id = ?',
      whereArgs: [quoteId],
    );
  }

  // Обновление времени просмотра
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