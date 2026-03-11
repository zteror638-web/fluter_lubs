class Habit {
  final String id;
  String title;
  IconData icon;
  Color color;
  String periodicity; // 'daily', 'weekly', 'custom'
  DateTime createdAt;
  List<DateTime> completionDates; // Даты выполнения
  int targetDays; // Целевое количество дней (например, 21 день для привычки)
  
  Habit({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
    required this.periodicity,
    required this.createdAt,
    required this.completionDates,
    required this.targetDays,
  });

  // Подсчет текущей серии выполнения
  int get currentStreak {
    if (completionDates.isEmpty) return 0;
    
    var streak = 1;
    var currentDate = DateTime.now();
    var sortedDates = [...completionDates]..sort((a, b) => b.compareTo(a));
    
    for (var i = 0; i < sortedDates.length - 1; i++) {
      var diff = sortedDates[i].difference(sortedDates[i + 1]).inDays;
      if (diff == 1) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  // Прогресс в процентах
  double get progress {
    if (targetDays == 0) return 0;
    return (currentStreak / targetDays).clamp(0.0, 1.0);
  }

  // Проверка, выполнена ли привычка сегодня
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
      'icon': icon.codePoint,
      'color': color.value,
      'periodicity': periodicity,
      'createdAt': createdAt.toIso8601String(),
      'completionDates': completionDates.map((d) => d.toIso8601String()).toList(),
      'targetDays': targetDays,
    };
  }

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'],
      title: json['title'],
      icon: IconData(json['icon'], fontFamily: 'MaterialIcons'),
      color: Color(json['color']),
      periodicity: json['periodicity'],
      createdAt: DateTime.parse(json['createdAt']),
      completionDates: (json['completionDates'] as List)
          .map((d) => DateTime.parse(d))
          .toList(),
      targetDays: json['targetDays'],
    );
  }
}