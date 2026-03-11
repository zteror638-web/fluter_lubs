import 'package:flutter/material.dart';

class Habit {
  final String id;
  String title;
  IconData icon;
  Color color;
  String periodicity;
  DateTime createdAt;
  List<DateTime> completionDates;
  int targetDays;
  TimeOfDay? reminderTime;
  bool isActive;

  Habit({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
    required this.periodicity,
    required this.createdAt,
    required this.completionDates,
    required this.targetDays,
    this.reminderTime,
    this.isActive = true,
  });

  int get currentStreak {
    if (completionDates.isEmpty) return 0;
    
    var streak = 1;
    var sortedDates = [...completionDates]..sort((a, b) => b.compareTo(a));
    var today = DateTime.now();
    
    for (var i = 0; i < sortedDates.length - 1; i++) {
      var diff = sortedDates[i].difference(sortedDates[i + 1]).inDays;
      if (diff == 1) {
        streak++;
      } else {
        break;
      }
    }
    
    bool completedToday = sortedDates.first.year == today.year &&
                          sortedDates.first.month == today.month &&
                          sortedDates.first.day == today.day;
    
    return completedToday ? streak : streak - 1;
  }

  double get progress {
    if (targetDays == 0) return 0;
    return (currentStreak / targetDays).clamp(0.0, 1.0);
  }

  bool get isCompletedToday {
    final today = DateTime.now();
    return completionDates.any((date) => 
      date.year == today.year && 
      date.month == today.month && 
      date.day == today.day
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'iconCodePoint': icon.codePoint,
      'iconFontFamily': icon.fontFamily,
      'iconFontPackage': icon.fontPackage,
      'colorValue': color.value,
      'periodicity': periodicity,
      'createdAt': createdAt.toIso8601String(),
      'targetDays': targetDays,
      'reminderTime': reminderTime != null 
          ? '${reminderTime!.hour}:${reminderTime!.minute}' 
          : null,
      'isActive': isActive ? 1 : 0,
    };
  }

  factory Habit.fromJson(Map<String, dynamic> json, List<DateTime> completions) {
    return Habit(
      id: json['id'],
      title: json['title'],
      icon: IconData(
        json['iconCodePoint'],
        fontFamily: json['iconFontFamily'],
        fontPackage: json['iconFontPackage'],
      ),
      color: Color(json['colorValue']),
      periodicity: json['periodicity'],
      createdAt: DateTime.parse(json['createdAt']),
      completionDates: completions,
      targetDays: json['targetDays'],
      reminderTime: json['reminderTime'] != null
          ? TimeOfDay(
              hour: int.parse(json['reminderTime'].split(':')[0]),
              minute: int.parse(json['reminderTime'].split(':')[1]),
            )
          : null,
      isActive: json['isActive'] == 1,
    );
  }
}