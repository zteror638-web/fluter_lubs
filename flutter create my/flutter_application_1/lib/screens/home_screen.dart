import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/storage_service.dart';
import '../widgets/habit_card.dart';
import '../widgets/idea_card.dart';
import '../widgets/progress_widget.dart';
import 'habit_constructor_screen.dart';
import '../models/idea.dart';

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
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: HabitSearchDelegate(),
              );
            },
          ),
        ],
      ),
      drawer: _buildDrawer(context),
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
              
              // Карточка вдохновения
              SliverToBoxAdapter(
                child: _buildInspirationCard(context),
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
                child: SizedBox(height: 20),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade400, Colors.purple.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.auto_awesome,
                    size: 35,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Habit & Idea Tracker',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Версия 1.0.0',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Главная'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.auto_awesome_outlined),
            title: const Text('Вдохновение'),
            onTap: () {
              Navigator.pop(context);
              // Переход на экран вдохновения через родительскую навигацию
              final parentState = context.findAncestorStateOfType<_MainNavigationScreenState>();
              parentState?.setState(() {
                // Меняем индекс BottomNavigationBar
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite_outline),
            title: const Text('Избранное'),
            onTap: () {
              Navigator.pop(context);
              final parentState = context.findAncestorStateOfType<_MainNavigationScreenState>();
              parentState?.setState(() {
                // Меняем индекс BottomNavigationBar на 2 (Избранное)
              });
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.add_circle_outline),
            title: const Text('Создать привычку'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/habitConstructor');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.share_outlined),
            title: const Text('Поделиться приложением'),
            onTap: () {
              Navigator.pop(context);
              // Логика шаринга
            },
          ),
          ListTile(
            leading: const Icon(Icons.star_outline),
            title: const Text('Оценить приложение'),
            onTap: () {
              Navigator.pop(context);
              // Логика оценки
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('О приложении'),
            onTap: () {
              Navigator.pop(context);
              final parentState = context.findAncestorStateOfType<_MainNavigationScreenState>();
              parentState?.setState(() {
                // Меняем индекс BottomNavigationBar на 3 (О нас)
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInspirationCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: InkWell(
        onTap: () {
          final parentState = context.findAncestorStateOfType<_MainNavigationScreenState>();
          parentState?.setState(() {
            // Меняем индекс BottomNavigationBar на 1 (Вдохновение)
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.amber,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Вдохновение',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Цитаты, советы и идеи со всего мира',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
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

// Класс для поиска
class HabitSearchDelegate extends SearchDelegate {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    return Consumer<StorageService>(
      builder: (context, storage, child) {
        final habits = storage.habits.where((h) => 
          h.title.toLowerCase().contains(query.toLowerCase())
        ).toList();
        
        final ideas = storage.ideas.where((i) => 
          i.content.toLowerCase().contains(query.toLowerCase())
        ).toList();

        if (habits.isEmpty && ideas.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 80,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'Ничего не найдено',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (habits.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Привычки',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ...habits.map((habit) => ListTile(
                leading: Icon(habit.icon, color: habit.color),
                title: Text(habit.title),
                subtitle: Text('Серия: ${habit.currentStreak} дней'),
              )),
            ],
            if (ideas.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Идеи',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ...ideas.map((idea) => ListTile(
                leading: const Icon(Icons.lightbulb_outline, color: Colors.amber),
                title: Text(idea.content),
                subtitle: Text('${idea.createdAt.day}.${idea.createdAt.month}.${idea.createdAt.year}'),
              )),
            ],
          ],
        );
      },
    );
  }
}