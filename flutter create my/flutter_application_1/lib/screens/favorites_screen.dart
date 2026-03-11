import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/storage_service.dart';
import '../models/quote.dart';
import '../models/idea.dart';
import '../widgets/quote_card.dart';
import '../widgets/idea_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Избранное'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.format_quote), text: 'Цитаты'),
            Tab(icon: Icon(Icons.lightbulb), text: 'Идеи'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildQuotesTab(),
          _buildIdeasTab(),
        ],
      ),
    );
  }

  Widget _buildQuotesTab() {
    return Consumer<StorageService>(
      builder: (context, storage, child) {
        if (storage.favoriteQuotes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.format_quote,
                  size: 80,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'Нет избранных цитат',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Сохраняйте цитаты на экране "Вдохновение"',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    // Переход на экран вдохновения
                    final parentState = context.findAncestorStateOfType<_MainNavigationScreenState>();
                    parentState?.setState(() {
                      // Изменяем индекс BottomNavigationBar на 1 (Вдохновение)
                      // Это требует доступа к состоянию родителя
                    });
                  },
                  icon: const Icon(Icons.explore),
                  label: const Text('Найти цитаты'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: storage.favoriteQuotes.length,
          itemBuilder: (context, index) {
            final quote = storage.favoriteQuotes[index];
            return QuoteCard(
              quote: quote,
              isFavorite: true,
              onSave: () => _saveQuoteAsIdea(context, quote),
              onRemove: () => _removeQuote(context, quote.id),
            );
          },
        );
      },
    );
  }

  Widget _buildIdeasTab() {
    return Consumer<StorageService>(
      builder: (context, storage, child) {
        final favoriteIdeas = storage.ideas.where((i) => i.isFavorite).toList();
        
        if (favoriteIdeas.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  size: 80,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'Нет избранных идей',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Отмечайте идеи звездочкой на главном экране',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: favoriteIdeas.length,
          itemBuilder: (context, index) {
            final idea = favoriteIdeas[index];
            return IdeaCard(
              idea: idea,
              onToggleFavorite: () async {
                idea.isFavorite = false;
                await storage.updateIdea(idea);
              },
              onDelete: () async {
                await storage.deleteIdea(idea.id);
              },
            );
          },
        );
      },
    );
  }

  Future<void> _saveQuoteAsIdea(BuildContext context, Quote quote) async {
    final storage = Provider.of<StorageService>(context, listen: false);
    
    final idea = Idea(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: quote.content,
      description: '- ${quote.author}',
      createdAt: DateTime.now(),
      source: 'quote',
    );
    
    await storage.addIdea(idea);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Цитата сохранена в идеи!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _removeQuote(BuildContext context, String quoteId) async {
    final storage = Provider.of<StorageService>(context, listen: false);
    await storage.removeFavoriteQuote(quoteId);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Цитата удалена из избранного'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}