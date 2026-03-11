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
      child: Dismissible(
        key: Key(habit.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          color: Colors.red,
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        onDismissed: (direction) {
          onDelete();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${habit.title} удалена'),
              action: SnackBarAction(
                label: 'Отмена',
                onPressed: () {
                  // Здесь можно добавить отмену удаления
                },
              ),
            ),
          );
        },
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
              fontWeight: habit.isCompletedToday ? FontWeight.normal : FontWeight.w500,
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
                minHeight: 4,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.whatshot,
                    size: 14,
                    color: habit.currentStreak > 0 ? Colors.orange : Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Серия: ${habit.currentStreak} из ${habit.targetDays}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  if (habit.reminderTime != null) ...[
                    const SizedBox(width: 12),
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      habit.reminderTime!.format(context),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          trailing: IconButton(
            icon: Icon(
              habit.isCompletedToday ? Icons.check_circle : Icons.check_circle_outline,
              color: habit.isCompletedToday ? habit.color : Colors.grey,
              size: 28,
            ),
            onPressed: onTap,
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}