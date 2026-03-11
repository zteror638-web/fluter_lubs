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
      child: Dismissible(
        key: Key(idea.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          color: Colors.red,
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        onDismissed: (direction) {
          onDelete();
        },
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: idea.isFavorite 
                  ? Colors.amber.withOpacity(0.1)
                  : idea.color?.withOpacity(0.1) ?? Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              idea.isFavorite ? Icons.star : Icons.lightbulb_outline,
              color: idea.isFavorite 
                  ? Colors.amber 
                  : idea.color ?? Colors.grey,
            ),
          ),
          title: Text(
            idea.content,
            style: const TextStyle(fontSize: 16),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (idea.description != null)
                Text(
                  idea.description!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    '${idea.createdAt.day}.${idea.createdAt.month}.${idea.createdAt.year}',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  if (idea.source != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        idea.source!,
                        style: TextStyle(
                          fontSize: 8,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  idea.isFavorite ? Icons.star : Icons.star_border,
                  color: idea.isFavorite ? Colors.amber : Colors.grey,
                ),
                onPressed: onToggleFavorite,
              ),
            ],
          ),
          onTap: onToggleFavorite,
        ),
      ),
    );
  }
}