import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsManager {
  static final SettingsManager _instance = SettingsManager._internal();
  factory SettingsManager() => _instance;
  SettingsManager._internal();

  late SharedPreferences _prefs;

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

  bool get isFirstLaunch => _prefs.getBool(KEY_FIRST_LAUNCH) ?? true;
  Future<void> setFirstLaunchComplete() => _prefs.setBool(KEY_FIRST_LAUNCH, false);

  bool get isDarkMode => _prefs.getBool(KEY_DARK_MODE) ?? false;
  Future<void> setDarkMode(bool value) => _prefs.setBool(KEY_DARK_MODE, value);

  bool get notificationsEnabled => _prefs.getBool(KEY_NOTIFICATIONS_ENABLED) ?? true;
  Future<void> setNotificationsEnabled(bool value) => _prefs.setBool(KEY_NOTIFICATIONS_ENABLED, value);

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

  int get defaultHabitTarget => _prefs.getInt(KEY_DEFAULT_HABIT_TARGET) ?? 21;
  Future<void> setDefaultHabitTarget(int days) => 
      _prefs.setInt(KEY_DEFAULT_HABIT_TARGET, days);

  String get sortBy => _prefs.getString(KEY_SORT_BY) ?? 'date';
  Future<void> setSortBy(String value) => _prefs.setString(KEY_SORT_BY, value);

  DateTime? get lastBackup {
    final timestamp = _prefs.getString(KEY_LAST_BACKUP);
    return timestamp != null ? DateTime.parse(timestamp) : null;
  }
  
  Future<void> setLastBackup(DateTime date) => 
      _prefs.setString(KEY_LAST_BACKUP, date.toIso8601String());

  String? get userName => _prefs.getString(KEY_USER_NAME);
  Future<void> setUserName(String name) => _prefs.setString(KEY_USER_NAME, name);

  int get dailyGoal => _prefs.getInt(KEY_DAILY_GOAL) ?? 5;
  Future<void> setDailyGoal(int goal) => _prefs.setInt(KEY_DAILY_GOAL, goal);

  Future<void> resetAllSettings() async {
    await _prefs.clear();
  }
}