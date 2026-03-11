import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  static const String TABLE_HABITS = 'habits';
  static const String TABLE_IDEAS = 'ideas';
  static const String TABLE_QUOTES = 'quotes';
  static const String TABLE_ADVICES = 'advices';
  static const String TABLE_HABIT_COMPLETIONS = 'habit_completions';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'habit_tracker.db');
    
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Таблица привычек
    await db.execute('''
      CREATE TABLE $TABLE_HABITS(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        iconCodePoint INTEGER NOT NULL,
        iconFontFamily TEXT,
        iconFontPackage TEXT,
        colorValue INTEGER NOT NULL,
        periodicity TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        targetDays INTEGER NOT NULL,
        reminderTime TEXT,
        isActive INTEGER DEFAULT 1
      )
    ''');

    // Таблица выполнений привычек
    await db.execute('''
      CREATE TABLE $TABLE_HABIT_COMPLETIONS(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        habitId TEXT NOT NULL,
        completionDate TEXT NOT NULL,
        FOREIGN KEY (habitId) REFERENCES $TABLE_HABITS(id) ON DELETE CASCADE
      )
    ''');

    // Таблица идей
    await db.execute('''
      CREATE TABLE $TABLE_IDEAS(
        id TEXT PRIMARY KEY,
        content TEXT NOT NULL,
        description TEXT,
        createdAt TEXT NOT NULL,
        isFavorite INTEGER DEFAULT 0,
        source TEXT,
        colorValue INTEGER,
        category TEXT
      )
    ''');

    // Таблица цитат
    await db.execute('''
      CREATE TABLE $TABLE_QUOTES(
        id TEXT PRIMARY KEY,
        content TEXT NOT NULL,
        author TEXT NOT NULL,
        isFavorite INTEGER DEFAULT 1,
        dateAdded TEXT NOT NULL,
        lastViewed TEXT
      )
    ''');

    // Таблица советов
    await db.execute('''
      CREATE TABLE $TABLE_ADVICES(
        id INTEGER PRIMARY KEY,
        advice TEXT NOT NULL,
        isUsed INTEGER DEFAULT 0,
        dateSaved TEXT NOT NULL
      )
    ''');

    // Индексы
    await db.execute('CREATE INDEX idx_habits_active ON $TABLE_HABITS(isActive)');
    await db.execute('CREATE INDEX idx_completions_habit ON $TABLE_HABIT_COMPLETIONS(habitId)');
    await db.execute('CREATE INDEX idx_completions_date ON $TABLE_HABIT_COMPLETIONS(completionDate)');
    await db.execute('CREATE INDEX idx_ideas_favorite ON $TABLE_IDEAS(isFavorite)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE $TABLE_HABITS ADD COLUMN reminderTime TEXT');
      await db.execute('ALTER TABLE $TABLE_IDEAS ADD COLUMN category TEXT');
    }
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}