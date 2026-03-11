import 'package:flutter/material.dart';
import '../database/habit_repository.dart';
import '../database/idea_repository.dart';
import '../database/quote_repository.dart';
import '../services/settings_manager.dart';
import '../models/habit.dart';
import '../models/idea.dart';
import '../models/quote.dart';
import '../models/advice.dart';

class StorageService extends ChangeNotifier {
  late final HabitRepository _habitRepo;
  late final IdeaRepository _ideaRepo;
  late final QuoteRepository _quoteRepo;
  late final SettingsManager _settings;

  List<Habit> _habits = [];
  List<Idea> _ideas = [];
  List<Quote> _favoriteQuotes = [];

  List<Habit> get habits => _habits;
  List<Idea> get ideas => _ideas;
  List<Quote> get favoriteQuotes => _favoriteQuotes;

  StorageService() {
    _habitRepo = HabitRepository();
    _ideaRepo = IdeaRepository();
    _quoteRepo = QuoteRepository();
    _settings = SettingsManager();
  }

  static Future<StorageService> init() async {
    final service = StorageService();
    await service._settings.init();
    await service._loadAllData();
    return service;
  }

  Future<void> _loadAllData() async {
    await Future.wait([
      _loadHabits(),
      _loadIdeas(),
      _loadFavoriteQuotes(),
    ]);
    notifyListeners();
  }

  Future<void> refreshData() async {
    await _loadAllData();
    notifyListeners();
  }

  Future<void> _loadHabits() async {
    _habits = await _habitRepo.getAllHabits();
  }

  Future<void> _loadIdeas() async {
    _ideas = await _ideaRepo.getAllIdeas();
  }

  Future<void> _loadFavoriteQuotes() async {
    _favoriteQuotes = await _quoteRepo.getFavoriteQuotes();
  }

  // CRUD для привычек
  Future<void> addHabit(Habit habit) async {
    await _habitRepo.insertHabit(habit);
    await _loadHabits();
    notifyListeners();
  }

  Future<void> updateHabit(Habit habit) async {
    await _habitRepo.updateHabit(habit);
    await _loadHabits();
    notifyListeners();
  }

  Future<void> deleteHabit(String id) async {
    await _habitRepo.deleteHabit(id);
    await _loadHabits();
    notifyListeners();
  }

  Future<void> completeHabitToday(String habitId) async {
    await _habitRepo.completeHabitToday(habitId);
    await _loadHabits();
    notifyListeners();
  }

  // CRUD для идей
  Future<void> addIdea(Idea idea) async {
    await _ideaRepo.insertIdea(idea);
    await _loadIdeas();
    notifyListeners();
  }

  Future<void> updateIdea(Idea idea) async {
    await _ideaRepo.updateIdea(idea);
    await _loadIdeas();
    notifyListeners();
  }

  Future<void> deleteIdea(String id) async {
    await _ideaRepo.deleteIdea(id);
    await _loadIdeas();
    notifyListeners();
  }

  Future<List<Idea>> searchIdeas(String query) async {
    return await _ideaRepo.searchIdeas(query);
  }

  // Работа с цитатами
  Future<void> addFavoriteQuote(Quote quote) async {
    await _quoteRepo.addToFavorites(quote);
    await _loadFavoriteQuotes();
    notifyListeners();
  }

  Future<void> removeFavoriteQuote(String quoteId) async {
    await _quoteRepo.removeFromFavorites(quoteId);
    await _loadFavoriteQuotes();
    notifyListeners();
  }

  Future<void> saveAdvice(Advice advice) async {
    // Здесь можно реализовать сохранение советов
    print('Совет сохранен: ${advice.advice}');
  }

  // Статистика
  int get completedTodayCount {
    final today = DateTime.now();
    return _habits.where((h) => h.isCompletedToday).length;
  }

  int get totalHabitsCount => _habits.length;

  SettingsManager get settings => _settings;

  Future<Map<String, dynamic>> getStatistics() async {
    final habitStats = await _habitRepo.getStatistics();
    return {
      ...habitStats,
      'ideasCount': _ideas.length,
      'favoritesCount': _favoriteQuotes.length,
      'dailyGoal': _settings.dailyGoal,
    };
  }
}