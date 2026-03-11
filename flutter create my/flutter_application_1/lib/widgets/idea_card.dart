import 'package:flutter/material.dart';
import '../models/idea.dart';

class IdeaCard extends StatelessWidget {
  final Idea idea;
  final VoidCallback onToggleFavorite;
  final VoidCallback onDelete;

  const IdeaCard({
    super.key,
    required this.idea,
    required this.onToggleFavorite,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.lightbulb_outline,
            color: Colors.amber,
          ),
        ),
        title: Text(
          idea.content,
          style: const TextStyle(fontSize: 16),
        ),
        subtitle: Text(
          '${idea.createdAt.day}.${idea.createdAt.month}.${idea.createdAt.year}',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Избранное
            IconButton(
              icon: Icon(
                idea.isFavorite ? Icons.star : Icons.star_border,
                color: idea.isFavorite ? Colors.amber : Colors.grey,
              ),
              onPressed: onToggleFavorite,
            ),
            // Удаление
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}