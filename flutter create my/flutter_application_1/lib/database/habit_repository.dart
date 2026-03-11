import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';
import 'database_helper.dart';
import '../models/habit.dart';

class HabitRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<void> insertHabit(Habit habit) async {
    final Database db = await _dbHelper.database;
    
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
        'reminderTime': habit.reminderTime != null 
            ? '${habit.reminderTime!.hour}:${habit.reminderTime!.minute}' 
            : null,
        'isActive': 1,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    for (var date in habit.completionDates) {
      await _recordCompletion(habit.id, date);
    }
  }

  Future<List<Habit>> getAllHabits() async {
    final Database db = await _dbHelper.database;
    
    final List<Map<String, dynamic>> habitMaps = await db.query(
      DatabaseHelper.TABLE_HABITS,
      where: 'isActive = ?',
      whereArgs: [1],
      orderBy: 'createdAt DESC',
    );

    List<Habit> habits = [];
    for (var map in habitMaps) {
      final completions = await getCompletionsForHabit(map['id']);
      
      final icon = IconData(
        map['iconCodePoint'],
        fontFamily: map['iconFontFamily'],
        fontPackage: map['iconFontPackage'],
      );

      TimeOfDay? reminderTime;
      if (map['reminderTime'] != null) {
        final parts = map['reminderTime'].split(':');
        reminderTime = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }

      habits.add(Habit(
        id: map['id'],
        title: map['title'],
        icon: icon,
        color: Color(map['colorValue']),
        periodicity: map['periodicity'],
        createdAt: DateTime.parse(map['createdAt']),
        completionDates: completions,
        targetDays: map['targetDays'],
        reminderTime: reminderTime,
        isActive: map['isActive'] == 1,
      ));
    }
    
    return habits;
  }

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

  Future<void> _recordCompletion(String habitId, DateTime date) async {
    final Database db = await _dbHelper.database;
    
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

  Future<void> completeHabitToday(String habitId) async {
    await _recordCompletion(habitId, DateTime.now());
  }

  Future<void> updateHabit(Habit habit) async {
    final Database db = await _dbHelper.database;
    
    await db.update(
      DatabaseHelper.TABLE_HABITS,
      {
        'title': habit.title,
        'periodicity': habit.periodicity,
        'targetDays': habit.targetDays,
        'reminderTime': habit.reminderTime != null 
            ? '${habit.reminderTime!.hour}:${habit.reminderTime!.minute}' 
            : null,
      },
      where: 'id = ?',
      whereArgs: [habit.id],
    );
  }

  Future<void> deleteHabit(String id) async {
    final Database db = await _dbHelper.database;
    await db.update(
      DatabaseHelper.TABLE_HABITS,
      {'isActive': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Map<String, dynamic>> getStatistics() async {
    final Database db = await _dbHelper.database;
    
    final totalCount = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM ${DatabaseHelper.TABLE_HABITS} WHERE isActive = 1'
    )) ?? 0;

    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    
    final completedToday = Sqflite.firstIntValue(await db.rawQuery('''
      SELECT COUNT(DISTINCT habitId) 
      FROM ${DatabaseHelper.TABLE_HABIT_COMPLETIONS}
      WHERE date(completionDate) = ?
    ''', [todayStr])) ?? 0;

    return {
      'total': totalCount,
      'completedToday': completedToday,
    };
  }
}