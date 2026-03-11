import 'package:flutter/material.dart';
import '../models/habit.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const HabitCard({
    super.key,
    required this.habit,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: habit.color.withOpacity(0.1),
          child: Icon(
            habit.icon,
            color: habit.color,
          ),
        ),
        title: Text(
          habit.title,
          style: TextStyle(
            decoration: habit.isCompletedToday ? TextDecoration.lineThrough : null,
            color: habit.isCompletedToday ? Colors.grey : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: habit.progress,
              backgroundColor: habit.color.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(habit.color),
            ),
            const SizedBox(height: 4),
            Text(
              'Серия: ${habit.currentStreak} из ${habit.targetDays} дней',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Кнопка выполнения
            IconButton(
              icon: Icon(
                habit.isCompletedToday ? Icons.check_circle : Icons.check_circle_outline,
                color: habit.isCompletedToday ? habit.color : Colors.grey,
              ),
              onPressed: onTap,
            ),
            // Кнопка удаления
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}