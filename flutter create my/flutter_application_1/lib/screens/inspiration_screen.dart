import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../models/quote.dart';
import '../models/advice.dart';
import '../models/idea.dart';
import '../widgets/quote_card.dart';

class InspirationScreen extends StatefulWidget {
  const InspirationScreen({super.key});

  @override
  State<InspirationScreen> createState() => _InspirationScreenState();
}

class _InspirationScreenState extends State<InspirationScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  Quote? _currentQuote;
  Advice? _currentAdvice;
  List<Quote> _popularQuotes = [];
  String _selectedTag = 'motivation';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _tags = [
    'motivation',
    'inspiration',
    'wisdom',
    'success',
    'happiness',
    'life',
    'love',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadRandomQuote();
    _loadRandomAdvice();
  }

  Future<void> _loadRandomQuote() async {
    setState(() => _isLoading = true);
    try {
      final quote = await ApiService.getRandomQuote();
      setState(() {
        _currentQuote = quote;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Не удалось загрузить цитату');
    }
  }

  Future<void> _loadQuoteByTag() async {
    setState(() => _isLoading = true);
    try {
      final quote = await ApiService.getQuoteByTag(_selectedTag);
      setState(() {
        _currentQuote = quote;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Не удалось загрузить цитату по тегу');
    }
  }

  Future<void> _loadRandomAdvice() async {
    try {
      final advice = await ApiService.getRandomAdvice();
      setState(() {
        _currentAdvice = advice;
      });
    } catch (e) {
      _showError('Не удалось загрузить совет');
    }
  }

  Future<void> _loadPopularQuotes() async {
    setState(() => _isLoading = true);
    try {
      final quotes = await ApiService.getPopularQuotes(limit: 20);
      setState(() {
        _popularQuotes = quotes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Не удалось загрузить популярные цитаты');
    }
  }

  Future<void> _searchQuotes() async {
    if (_searchController.text.isEmpty) return;
    
    setState(() => _isLoading = true);
    try {
      final quotes = await ApiService.searchQuotes(_searchController.text);
      setState(() {
        _popularQuotes = quotes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Ошибка при поиске');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _saveQuoteAsIdea(Quote quote) async {
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Вдохновение'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.auto_awesome), text: 'Случайное'),
            Tab(icon: Icon(Icons.explore), text: 'Популярное'),
            Tab(icon: Icon(Icons.favorite), text: 'Избранное'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRandomTab(),
          _buildPopularTab(),
          _buildFavoritesTab(),
        ],
      ),
    );
  }

  Widget _buildRandomTab() {
    return RefreshIndicator(
      onRefresh: () async {
        await _loadRandomQuote();
        await _loadRandomAdvice();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Цитата дня',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _currentQuote != null
                    ? _buildQuoteCard(_currentQuote!)
                    : const SizedBox(),
            
            const SizedBox(height: 24),
            
            // Выбор тега
            const Text(
              'Выберите тему:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _tags.map((tag) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(tag),
                      selected: _selectedTag == tag,
                      onSelected: (selected) {
                        setState(() {
                          _selectedTag = tag;
                        });
                        _loadQuoteByTag();
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Совет дня
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb, color: Colors.amber.shade600),
                        const SizedBox(width: 8),
                        const Text(
                          'Совет дня',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _currentAdvice?.advice ?? 'Загрузка...',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: _loadRandomAdvice,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Новый совет'),
                        ),
                        const SizedBox(width: 8),
                        Consumer<StorageService>(
                          builder: (context, storage, child) {
                            return TextButton.icon(
                              onPressed: _currentAdvice != null
                                  ? () async {
                                      await storage.saveAdvice(_currentAdvice!);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Совет сохранен!'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    }
                                  : null,
                              icon: const Icon(Icons.bookmark),
                              label: const Text('Сохранить'),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuoteCard(Quote quote) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '"${quote.content}"',
              style: const TextStyle(
                fontSize: 18,
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '— ${quote.author}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
                Row(
                  children: [
                    // Кнопка сохранения в избранное
                    Consumer<StorageService>(
                      builder: (context, storage, child) {
                        final isFavorite = storage.favoriteQuotes
                            .any((q) => q.id == quote.id);
                        return IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.red : null,
                          ),
                          onPressed: () async {
                            if (isFavorite) {
                              await storage.removeFavoriteQuote(quote.id);
                            } else {
                              await storage.addFavoriteQuote(quote);
                            }
                          },
                        );
                      },
                    ),
                    // Кнопка сохранения в идеи
                    IconButton(
                      icon: const Icon(Icons.lightbulb_outline),
                      onPressed: () => _saveQuoteAsIdea(quote),
                    ),
                    // Кнопка обновления
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: _loadRandomQuote,
                    ),
                  ],
                ),
              ],
            ),
            if (quote.tags.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 4,
                children: quote.tags.map((tag) {
                  return Chip(
                    label: Text('#$tag'),
                    backgroundColor: Colors.blue.shade50,
                    labelStyle: TextStyle(fontSize: 12, color: Colors.blue.shade700),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPopularTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Поиск цитат...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  _loadPopularQuotes();
                },
              ),
            ),
            onSubmitted: (_) => _searchQuotes(),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadPopularQuotes,
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _popularQuotes.length,
                    itemBuilder: (context, index) {
                      return QuoteCard(
                        quote: _popularQuotes[index],
                        onSave: () => _saveQuoteAsIdea(_popularQuotes[index]),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildFavoritesTab() {
    return Consumer<StorageService>(
      builder: (context, storage, child) {
        if (storage.favoriteQuotes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.favorite_border,
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
                  'Сохраняйте понравившиеся цитаты',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: storage.favoriteQuotes.length,
          itemBuilder: (context, index) {
            final quote = storage.favoriteQuotes[index];
            return QuoteCard(
              quote: quote,
              isFavorite: true,
              onSave: () => _saveQuoteAsIdea(quote),
              onRemove: () => storage.removeFavoriteQuote(quote.id),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}