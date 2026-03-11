import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/habit.dart';
import '../models/idea.dart';

class StorageService extends ChangeNotifier {
  late SharedPreferences _prefs;
  List<Habit> _habits = [];
  List<Idea> _ideas = [];

  List<Habit> get habits => _habits;
  List<Idea> get ideas => _ideas;

  // Инициализация сервиса
  static Future<StorageService> init() async {
    final service = StorageService();
    service._prefs = await SharedPreferences.getInstance();
    await service._loadData();
    return service;
  }

  // Загрузка данных из SharedPreferences
  Future<void> _loadData() async {
    // Загрузка привычек
    final habitsJson = _prefs.getString('habits');
    if (habitsJson != null) {
      final List<dynamic> habitsList = jsonDecode(habitsJson);
      _habits = habitsList.map((h) => Habit.fromJson(h)).toList();
    }

    // Загрузка идей
    final ideasJson = _prefs.getString('ideas');
    if (ideasJson != null) {
      final List<dynamic> ideasList = jsonDecode(ideasJson);
      _ideas = ideasList.map((i) => Idea.fromJson(i)).toList();
    }
  }

  // Сохранение данных
  Future<void> _saveData() async {
    // Сохранение привычек
    final habitsJson = jsonEncode(_habits.map((h) => h.toJson()).toList());
    await _prefs.setString('habits', habitsJson);

    // Сохранение идей
    final ideasJson = jsonEncode(_ideas.map((i) => i.toJson()).toList());
    await _prefs.setString('ideas', ideasJson);
    
    notifyListeners();
  }

  // CRUD для привычек
  Future<void> addHabit(Habit habit) async {
    _habits.add(habit);
    await _saveData();
  }

  Future<void> updateHabit(Habit updatedHabit) async {
    final index = _habits.indexWhere((h) => h.id == updatedHabit.id);
    if (index != -1) {
      _habits[index] = updatedHabit;
      await _saveData();
    }
  }

  Future<void> deleteHabit(String id) async {
    _habits.removeWhere((h) => h.id == id);
    await _saveData();
  }

  // CRUD для идей
  Future<void> addIdea(Idea idea) async {
    _ideas.add(idea);
    await _saveData();
  }

  Future<void> updateIdea(Idea updatedIdea) async {
    final index = _ideas.indexWhere((i) => i.id == updatedIdea.id);
    if (index != -1) {
      _ideas[index] = updatedIdea;
      await _saveData();
    }
  }

  Future<void> deleteIdea(String id) async {
    _ideas.removeWhere((i) => i.id == id);
    await _saveData();
  }

  // Отметка выполнения привычки
  Future<void> completeHabitToday(String habitId) async {
    final habit = _habits.firstWhere((h) => h.id == habitId);
    final today = DateTime.now();
    
    if (!habit.isCompletedToday) {
      habit.completionDates.add(today);
      await updateHabit(habit);
    }
  }

  // Статистика для главного экрана
  int get completedTodayCount {
    final today = DateTime.now();
    return _habits.where((h) => h.isCompletedToday).length;
  }

  int get totalHabitsCount => _habits.length;
}