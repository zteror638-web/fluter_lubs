import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';
import '../models/idea.dart';

class IdeaRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<void> insertIdea(Idea idea) async {
    final Database db = await _dbHelper.database;
    
    await db.insert(
      DatabaseHelper.TABLE_IDEAS,
      idea.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Idea>> getAllIdeas({bool onlyFavorites = false}) async {
    final Database db = await _dbHelper.database;
    
    String? where;
    List<dynamic>? whereArgs;
    
    if (onlyFavorites) {
      where = 'isFavorite = ?';
      whereArgs = [1];
    }
    
    final List<Map<String, dynamic>> ideaMaps = await db.query(
      DatabaseHelper.TABLE_IDEAS,
      where: where,
      whereArgs: whereArgs,
      orderBy: 'createdAt DESC',
    );

    return ideaMaps.map((map) => Idea.fromJson(map)).toList();
  }

  Future<void> updateIdea(Idea idea) async {
    final Database db = await _dbHelper.database;
    
    await db.update(
      DatabaseHelper.TABLE_IDEAS,
      {
        'content': idea.content,
        'description': idea.description,
        'isFavorite': idea.isFavorite ? 1 : 0,
        'category': idea.category,
      },
      where: 'id = ?',
      whereArgs: [idea.id],
    );
  }

  Future<void> deleteIdea(String id) async {
    final Database db = await _dbHelper.database;
    await db.delete(
      DatabaseHelper.TABLE_IDEAS,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Idea>> searchIdeas(String query) async {
    final Database db = await _dbHelper.database;
    
    final List<Map<String, dynamic>> ideaMaps = await db.query(
      DatabaseHelper.TABLE_IDEAS,
      where: 'content LIKE ? OR description LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'createdAt DESC',
    );

    return ideaMaps.map((map) => Idea.fromJson(map)).toList();
  }
}