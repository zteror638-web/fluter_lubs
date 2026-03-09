import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/storage_service.dart';
import '../widgets/habit_card.dart';
import '../widgets/idea_card.dart';
import '../widgets/progress_widget.dart';
import 'habit_constructor_screen.dart';
import '../models/idea.dart';
import 'dart:math';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _ideaController = TextEditingController();
  bool _showIdeaInput = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Мой прогресс',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).primaryColor,
      ),
      body: Consumer<StorageService>(
        builder: (context, storage, child) {
          return CustomScrollView(
            slivers: [
              // Блок прогресса дня
              SliverToBoxAdapter(
                child: ProgressWidget(
                  completed: storage.completedTodayCount,
                  total: storage.totalHabitsCount,
                ),
              ),
              
              // Заголовок "Привычки"
              const SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'Сегодняшние привычки',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              
              // Список привычек
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final habit = storage.habits[index];
                    return HabitCard(
                      habit: habit,
                      onTap: () async {
                        await storage.completeHabitToday(habit.id);
                      },
                      onDelete: () async {
                        await storage.deleteHabit(habit.id);
                      },
                    );
                  },
                  childCount: storage.habits.length,
                ),
              ),
              
              // Заголовок "Идеи"
              const SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'Мои идеи',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              
              // Кнопка добавления идеи
              SliverToBoxAdapter(
                child: _buildIdeaInput(context, storage),
              ),
              
              // Список идей
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final idea = storage.ideas[index];
                    return IdeaCard(
                      idea: idea,
                      onToggleFavorite: () async {
                        idea.isFavorite = !idea.isFavorite;
                        await storage.updateIdea(idea);
                      },
                      onDelete: () async {
                        await storage.deleteIdea(idea.id);
                      },
                    );
                  },
                  childCount: storage.ideas.length,
                ),
              ),
              
              // Нижний отступ
              const SliverToBoxAdapter(
                child: SizedBox(height: 80),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const HabitConstructorScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Добавить привычку',
      ),
    );
  }

  Widget _buildIdeaInput(BuildContext context, StorageService storage) {
    if (!_showIdeaInput) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton.icon(
          onPressed: () {
            setState(() {
              _showIdeaInput = true;
            });
          },
          icon: const Icon(Icons.lightbulb_outline),
          label: const Text('Записать идею'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _ideaController,
              decoration: InputDecoration(
                hintText: 'Введите вашу идею...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              autofocus: true,
              onSubmitted: (value) => _saveIdea(storage),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Theme.of(context).primaryColor,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: () => _saveIdea(storage),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Colors.grey.shade300,
            child: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _showIdeaInput = false;
                  _ideaController.clear();
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  void _saveIdea(StorageService storage) async {
    if (_ideaController.text.isNotEmpty) {
      final idea = Idea(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: _ideaController.text,
        createdAt: DateTime.now(),
      );
      
      await storage.addIdea(idea);
      
      setState(() {
        _showIdeaInput = false;
        _ideaController.clear();
      });
    }
  }

  @override
  void dispose() {
    _ideaController.dispose();
    super.dispose();
  }
}