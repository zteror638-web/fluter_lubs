import 'package:flutter/material.dart';

class AppConstants {
  // Иконки для привычек
  static const List<IconData> habitIcons = [
    Icons.fitness_center,
    Icons.local_drink,
    Icons.restaurant,
    Icons.directions_run,
    Icons.book,
    Icons.brush,
    Icons.music_note,
    Icons.self_improvement,
    Icons.emoji_emotions,
    Icons.pets,
    Icons.water_drop,
    Icons.coffee,
    Icons.night_shelter,
    Icons.light_mode,
  ];

  // Цвета для привычек
  static const List<Color> habitColors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.pink,
    Colors.teal,
    Colors.red,
    Colors.amber,
    Colors.indigo,
    Colors.cyan,
  ];

  // Периодичность
  static const Map<String, String> periodicityLabels = {
    'daily': 'Ежедневно',
    'weekly': 'Еженедельно',
    'custom': 'Своя периодичность',
  };
}