import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';
import 'database_helper.dart';
import '../models/idea.dart';

class IdeaRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Создание идеи
  Future<void> insertIdea(Idea idea) async {
    final Database db = await _dbHelper.database;
    
    await db.insert(
      DatabaseHelper.TABLE_IDEAS,
      {
        'id': idea.id,
        'content': idea.content,
        'description': idea.description,
        'createdAt': idea.createdAt.toIso8601String(),
        'isFavorite': idea.isFavorite ? 1 : 0,
        'source': idea.source,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Получение всех идей
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

    return ideaMaps.map((map) {
      return Idea(
        id: map['id'],
        content: map['content'],
        description: map['description'],
        createdAt: DateTime.parse(map['createdAt']),
        isFavorite: map['isFavorite'] == 1,
        source: map['source'],
      );
    }).toList();
  }

  // Обновление идеи
  Future<void> updateIdea(Idea idea) async {
    final Database db = await _dbHelper.database;
    
    await db.update(
      DatabaseHelper.TABLE_IDEAS,
      {
        'content': idea.content,
        'description': idea.description,
        'isFavorite': idea.isFavorite ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [idea.id],
    );
  }

  // Удаление идеи
  Future<void> deleteIdea(String id) async {
    final Database db = await _dbHelper.database;
    await db.delete(
      DatabaseHelper.TABLE_IDEAS,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Поиск идей
  Future<List<Idea>> searchIdeas(String query) async {
    final Database db = await _dbHelper.database;
    
    final List<Map<String, dynamic>> ideaMaps = await db.query(
      DatabaseHelper.TABLE_IDEAS,
      where: 'content LIKE ? OR description LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'createdAt DESC',
    );

    return ideaMaps.map((map) => Idea(
      id: map['id'],
      content: map['content'],
      description: map['description'],
      createdAt: DateTime.parse(map['createdAt']),
      isFavorite: map['isFavorite'] == 1,
      source: map['source'],
    )).toList();
  }
}