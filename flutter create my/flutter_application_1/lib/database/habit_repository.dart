import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';
import 'database_helper.dart';
import '../models/habit.dart';

class HabitRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Создание привычки
  Future<void> insertHabit(Habit habit) async {
    final Database db = await _dbHelper.database;
    
    // Сохраняем иконку как JSON
    final iconData = {
      'codePoint': habit.icon.codePoint,
      'fontFamily': habit.icon.fontFamily,
      'fontPackage': habit.icon.fontPackage,
    };

    await db.insert(
      DatabaseHelper.TABLE_HABITS,
      {
        'id': habit.id,
        'title': habit.title,
        'iconCodePoint': habit.icon.codePoint,
        'iconFontFamily': habit.icon.fontFamily,
        'iconFontPackage': habit.icon.fontPackage,
        'colorValue': habit.color.value,
        'periodicity': habit.periodicity,
        'createdAt': habit.createdAt.toIso8601String(),
        'targetDays': habit.targetDays,
        'isActive': 1,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Сохраняем историю выполнений
    for (var date in habit.completionDates) {
      await _recordCompletion(habit.id, date);
    }
  }

  // Получение всех привычек
  Future<List<Habit>> getAllHabits() async {
    final Database db = await _dbHelper.database;
    
    final List<Map<String, dynamic>> habitMaps = await db.query(
      DatabaseHelper.TABLE_HABITS,
      where: 'isActive = ?',
      whereArgs: [1],
      orderBy: 'createdAt DESC',
    );

    return await Future.wait(habitMaps.map((map) async {
      // Восстанавливаем иконку
      final icon = IconData(
        map['iconCodePoint'],
        fontFamily: map['iconFontFamily'],
        fontPackage: map['iconFontPackage'],
      );

      // Получаем даты выполнений
      final completions = await getCompletionsForHabit(map['id']);

      return Habit(
        id: map['id'],
        title: map['title'],
        icon: icon,
        color: Color(map['colorValue']),
        periodicity: map['periodicity'],
        createdAt: DateTime.parse(map['createdAt']),
        completionDates: completions,
        targetDays: map['targetDays'],
      );
    }).toList());
  }

  // Получение выполнений для привычки
  Future<List<DateTime>> getCompletionsForHabit(String habitId) async {
    final Database db = await _dbHelper.database;
    
    final List<Map<String, dynamic>> completionMaps = await db.query(
      DatabaseHelper.TABLE_HABIT_COMPLETIONS,
      where: 'habitId = ?',
      whereArgs: [habitId],
      orderBy: 'completionDate DESC',
    );

    return completionMaps
        .map((map) => DateTime.parse(map['completionDate']))
        .toList();
  }

  // Запись выполнения привычки
  Future<void> _recordCompletion(String habitId, DateTime date) async {
    final Database db = await _dbHelper.database;
    
    // Проверяем, не записано ли уже выполнение на эту дату
    final existing = await db.query(
      DatabaseHelper.TABLE_HABIT_COMPLETIONS,
      where: 'habitId = ? AND date(completionDate) = date(?)',
      whereArgs: [habitId, date.toIso8601String()],
    );

    if (existing.isEmpty) {
      await db.insert(
        DatabaseHelper.TABLE_HABIT_COMPLETIONS,
        {
          'habitId': habitId,
          'completionDate': date.toIso8601String(),
        },
      );
    }
  }

  // Отметка выполнения привычки сегодня
  Future<void> completeHabitToday(String habitId) async {
    await _recordCompletion(habitId, DateTime.now());
  }

  // Обновление привычки
  Future<void> updateHabit(Habit habit) async {
    final Database db = await _dbHelper.database;
    
    await db.update(
      DatabaseHelper.TABLE_HABITS,
      {
        'title': habit.title,
        'periodicity': habit.periodicity,
        'targetDays': habit.targetDays,
      },
      where: 'id = ?',
      whereArgs: [habit.id],
    );
  }

  // Удаление привычки (мягкое удаление)
  Future<void> deleteHabit(String id) async {
    final Database db = await _dbHelper.database;
    await db.update(
      DatabaseHelper.TABLE_HABITS,
      {'isActive': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Получение статистики
  Future<Map<String, dynamic>> getHabitStatistics() async {
    final Database db = await _dbHelper.database;
    
    // Общее количество привычек
    final totalCount = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM ${DatabaseHelper.TABLE_HABITS} WHERE isActive = 1'
    )) ?? 0;

    // Количество выполненных сегодня
    final today = DateTime.now();
    final todayStr = today.toIso8601String().split('T')[0];
    
    final completedToday = Sqflite.firstIntValue(await db.rawQuery('''
      SELECT COUNT(DISTINCT habitId) 
      FROM ${DatabaseHelper.TABLE_HABIT_COMPLETIONS}
      WHERE date(completionDate) = ?
    ''', [todayStr])) ?? 0;

    // Лучшая серия
    final bestStreak = await _calculateBestStreak();

    return {
      'total': totalCount,
      'completedToday': completedToday,
      'bestStreak': bestStreak,
    };
  }

  Future<int> _calculateBestStreak() async {
    final habits = await getAllHabits();
    int maxStreak = 0;
    
    for (var habit in habits) {
      if (habit.currentStreak > maxStreak) {
        maxStreak = habit.currentStreak;
      }
    }
    
    return maxStreak;
  }
}