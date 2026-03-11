import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('О приложении'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Логотип
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade400, Colors.purple.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_awesome,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            
            // Название
            const Text(
              'Habit & Idea Tracker',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Версия 1.0.0',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Описание
            const Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      'Приложение для формирования полезных привычек и сохранения вдохновляющих идей.',
                      style: TextStyle(fontSize: 16, height: 1.5),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Особенности:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    _FeatureRow(
                      icon: Icons.fitness_center,
                      text: 'Отслеживание привычек с прогресом',
                    ),
                    _FeatureRow(
                      icon: Icons.lightbulb,
                      text: 'Быстрая запись идей',
                    ),
                    _FeatureRow(
                      icon: Icons.auto_awesome,
                      text: 'Вдохновляющие цитаты из API',
                    ),
                    _FeatureRow(
                      icon: Icons.favorite,
                      text: 'Избранное для важного',
                    ),
                    _FeatureRow(
                      icon: Icons.storage,
                      text: 'Локальное хранение данных',
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Используемые технологии
            const Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Используемые технологии:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    _TechChip(label: 'Flutter', icon: Icons.flutter_dash),
                    _TechChip(label: 'Provider', icon: Icons.architecture),
                    _TechChip(label: 'Shared Preferences', icon: Icons.storage),
                    _TechChip(label: 'HTTP', icon: Icons.http),
                    _TechChip(label: 'Quotable API', icon: Icons.format_quote),
                    _TechChip(label: 'Advice Slip API', icon: Icons.lightbulb),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Контакты
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      'Разработчик',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      leading: const Icon(Icons.person, color: Colors.blue),
                      title: const Text('Hukutuk'),
                      subtitle: const Text('Разработчик мобильных приложений'),
                      onTap: () async {
                        final url = Uri.parse('https://github.com/Hukutuk');
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url);
                        }
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.email, color: Colors.red),
                      title: const Text('Связаться с разработчиком'),
                      subtitle: const Text('hukutuk@example.com'),
                      onTap: () {
                        // Здесь можно добавить отправку email
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Кнопка оценки
            ElevatedButton.icon(
              onPressed: () {
                // Здесь можно добавить ссылку на App Store / Google Play
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Спасибо за оценку!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              icon: const Icon(Icons.star),
              label: const Text('Оценить приложение'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue.shade400),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _TechChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _TechChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade700),
          const SizedBox(width: 12),
          Text(label),
        ],
      ),
    );
  }
}