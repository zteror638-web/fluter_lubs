import 'package:shared_preferences/shared_preferences.dart';

class SettingsManager {
  static final SettingsManager _instance = SettingsManager._internal();
  factory SettingsManager() => _instance;
  SettingsManager._internal();

  late SharedPreferences _prefs;

  // Ключи для настроек
  static const String KEY_FIRST_LAUNCH = 'first_launch';
  static const String KEY_DARK_MODE = 'dark_mode';
  static const String KEY_NOTIFICATIONS_ENABLED = 'notifications_enabled';
  static const String KEY_REMINDER_TIME = 'reminder_time';
  static const String KEY_DEFAULT_HABIT_TARGET = 'default_habit_target';
  static const String KEY_SORT_BY = 'sort_by';
  static const String KEY_LAST_BACKUP = 'last_backup';
  static const String KEY_USER_NAME = 'user_name';
  static const String KEY_DAILY_GOAL = 'daily_goal';

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Первый запуск
  bool get isFirstLaunch => _prefs.getBool(KEY_FIRST_LAUNCH) ?? true;
  Future<void> setFirstLaunchComplete() => 
      _prefs.setBool(KEY_FIRST_LAUNCH, false);

  // Тема
  bool get isDarkMode => _prefs.getBool(KEY_DARK_MODE) ?? false;
  Future<void> setDarkMode(bool value) => 
      _prefs.setBool(KEY_DARK_MODE, value);

  // Уведомления
  bool get notificationsEnabled => _prefs.getBool(KEY_NOTIFICATIONS_ENABLED) ?? true;
  Future<void> setNotificationsEnabled(bool value) => 
      _prefs.setBool(KEY_NOTIFICATIONS_ENABLED, value);

  // Время напоминания
  TimeOfDay get reminderTime {
    final timeString = _prefs.getString(KEY_REMINDER_TIME) ?? '09:00';
    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }
  
  Future<void> setReminderTime(TimeOfDay time) => 
      _prefs.setString(KEY_REMINDER_TIME, '${time.hour}:${time.minute}');

  // Цель по умолчанию для привычек
  int get defaultHabitTarget => _prefs.getInt(KEY_DEFAULT_HABIT_TARGET) ?? 21;
  Future<void> setDefaultHabitTarget(int days) => 
      _prefs.setInt(KEY_DEFAULT_HABIT_TARGET, days);

  // Сортировка
  String get sortBy => _prefs.getString(KEY_SORT_BY) ?? 'date';
  Future<void> setSortBy(String value) => 
      _prefs.setString(KEY_SORT_BY, value);

  // Дата последнего бэкапа
  DateTime? get lastBackup {
    final timestamp = _prefs.getString(KEY_LAST_BACKUP);
    return timestamp != null ? DateTime.parse(timestamp) : null;
  }
  
  Future<void> setLastBackup(DateTime date) => 
      _prefs.setString(KEY_LAST_BACKUP, date.toIso8601String());

  // Имя пользователя
  String? get userName => _prefs.getString(KEY_USER_NAME);
  Future<void> setUserName(String name) => 
      _prefs.setString(KEY_USER_NAME, name);

  // Дневная цель (количество привычек)
  int get dailyGoal => _prefs.getInt(KEY_DAILY_GOAL) ?? 5;
  Future<void> setDailyGoal(int goal) => 
      _prefs.setInt(KEY_DAILY_GOAL, goal);

  // Сброс всех настроек
  Future<void> resetAllSettings() async {
    await _prefs.clear();
  }

  // Экспорт/импорт настроек
  Map<String, dynamic> exportSettings() {
    return {
      KEY_DARK_MODE: isDarkMode,
      KEY_NOTIFICATIONS_ENABLED: notificationsEnabled,
      KEY_REMINDER_TIME: reminderTime.format(context),
      KEY_DEFAULT_HABIT_TARGET: defaultHabitTarget,
      KEY_SORT_BY: sortBy,
      KEY_USER_NAME: userName,
      KEY_DAILY_GOAL: dailyGoal,
    };
  }

  Future<void> importSettings(Map<String, dynamic> settings) async {
    if (settings.containsKey(KEY_DARK_MODE)) 
      await setDarkMode(settings[KEY_DARK_MODE]);
    if (settings.containsKey(KEY_NOTIFICATIONS_ENABLED)) 
      await setNotificationsEnabled(settings[KEY_NOTIFICATIONS_ENABLED]);
    if (settings.containsKey(KEY_DEFAULT_HABIT_TARGET)) 
      await setDefaultHabitTarget(settings[KEY_DEFAULT_HABIT_TARGET]);
    if (settings.containsKey(KEY_SORT_BY)) 
      await setSortBy(settings[KEY_SORT_BY]);
    if (settings.containsKey(KEY_USER_NAME)) 
      await setUserName(settings[KEY_USER_NAME]);
    if (settings.containsKey(KEY_DAILY_GOAL)) 
      await setDailyGoal(settings[KEY_DAILY_GOAL]);
  }
}