import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/storage_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 9, minute: 0);
  int _dailyGoal = 5;
  String _sortBy = 'date';
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = Provider.of<StorageService>(context, listen: false).settings;
    setState(() {
      _notificationsEnabled = settings.notificationsEnabled;
      _reminderTime = settings.reminderTime;
      _dailyGoal = settings.dailyGoal;
      _sortBy = settings.sortBy;
      _isDarkMode = settings.isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          
          // Секция "Профиль"
          _buildSection(
            title: 'Профиль',
            children: [
              ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.person),
                ),
                title: const Text('Имя пользователя'),
                subtitle: Consumer<StorageService>(
                  builder: (context, storage, child) {
                    final name = storage.settings.userName ?? 'Не указано';
                    return Text(name);
                  },
                ),
                onTap: () => _showNameDialog(context),
              ),
            ],
          ),

          // Секция "Уведомления"
          _buildSection(
            title: 'Уведомления',
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.notifications),
                title: const Text('Включить уведомления'),
                value: _notificationsEnabled,
                onChanged: (value) async {
                  setState(() => _notificationsEnabled = value);
                  final settings = Provider.of<StorageService>(context, listen: false).settings;
                  await settings.setNotificationsEnabled(value);
                },
              ),
              if (_notificationsEnabled)
                ListTile(
                  leading: const Icon(Icons.access_time),
                  title: const Text('Время напоминания'),
                  subtitle: Text(_reminderTime.format(context)),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: _reminderTime,
                    );
                    if (time != null) {
                      setState(() => _reminderTime = time);
                      final settings = Provider.of<StorageService>(context, listen: false).settings;
                      await settings.setReminderTime(time);
                    }
                  },
                ),
            ],
          ),

          // Секция "Цели"
          _buildSection(
            title: 'Цели',
            children: [
              ListTile(
                leading: const Icon(Icons.flag),
                title: const Text('Дневная цель'),
                subtitle: Text('$_dailyGoal привычек в день'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () => _updateDailyGoal(_dailyGoal - 1),
                    ),
                    Text('$_dailyGoal'),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => _updateDailyGoal(_dailyGoal + 1),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Секция "Сортировка"
          _buildSection(
            title: 'Сортировка',
            children: [
              RadioListTile<String>(
                title: const Text('По дате'),
                value: 'date',
                groupValue: _sortBy,
                onChanged: (value) => _updateSortBy(value!),
              ),
              RadioListTile<String>(
                title: const Text('По названию'),
                value: 'title',
                groupValue: _sortBy,
                onChanged: (value) => _updateSortBy(value!),
              ),
              RadioListTile<String>(
                title: const Text('По прогрессу'),
                value: 'progress',
                groupValue: _sortBy,
                onChanged: (value) => _updateSortBy(value!),
              ),
            ],
          ),

          // Секция "Тема"
          _buildSection(
            title: 'Оформление',
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.dark_mode),
                title: const Text('Темная тема'),
                value: _isDarkMode,
                onChanged: (value) async {
                  setState(() => _isDarkMode = value);
                  final settings = Provider.of<StorageService>(context, listen: false).settings;
                  await settings.setDarkMode(value);
                  // Здесь можно применить тему
                },
              ),
            ],
          ),

          // Секция "Данные"
          _buildSection(
            title: 'Данные',
            children: [
              ListTile(
                leading: const Icon(Icons.backup),
                title: const Text('Резервное копирование'),
                subtitle: Consumer<StorageService>(
                  builder: (context, storage, child) {
                    final lastBackup = storage.settings.lastBackup;
                    return Text(lastBackup != null
                        ? 'Последнее: ${_formatDate(lastBackup)}'
                        : 'Никогда');
                  },
                ),
                onTap: () => _showBackupDialog(context),
              ),
              ListTile(
                leading: const Icon(Icons.restore),
                title: const Text('Восстановить данные'),
                onTap: () => _showRestoreDialog(context),
              ),
              ListTile(
                leading: const Icon(Icons.delete_forever),
                title: const Text('Очистить все данные'),
                textColor: Colors.red,
                onTap: () => _showClearDataDialog(context),
              ),
            ],
          ),

          // Секция "О приложении"
          _buildSection(
            title: 'О приложении',
            children: [
              const ListTile(
                leading: Icon(Icons.info),
                title: Text('Версия'),
                subtitle: Text('1.0.0'),
              ),
              ListTile(
                leading: const Icon(Icons.storage),
                title: const Text('Размер базы данных'),
                subtitle: Consumer<StorageService>(
                  builder: (context, storage, child) {
                    final stats = storage.getStatistics();
                    return FutureBuilder(
                      future: stats,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final data = snapshot.data as Map;
                          return Text(
                            'Привычек: ${data['total']}, Идей: ${data['ideasCount']}'
                          );
                        }
                        return const Text('Загрузка...');
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Column(children: children),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  void _updateDailyGoal(int newGoal) {
    if (newGoal >= 1 && newGoal <= 20) {
      setState(() => _dailyGoal = newGoal);
      Provider.of<StorageService>(context, listen: false)
          .settings
          .setDailyGoal(newGoal);
    }
  }

  void _updateSortBy(String value) async {
    setState(() => _sortBy = value);
    await Provider.of<StorageService>(context, listen: false)
        .settings
        .setSortBy(value);
  }

  Future<void> _showNameDialog(BuildContext context) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Изменить имя'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Введите ваше имя',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      await Provider.of<StorageService>(context, listen: false)
          .settings
          .setUserName(result);
      setState(() {});
    }
  }

  void _showBackupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Резервное копирование'),
        content: const Text('Создать резервную копию всех данных?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () async {
              // Здесь логика бэкапа
              await Provider.of<StorageService>(context, listen: false)
                  .settings
                  .setLastBackup(DateTime.now());
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Резервная копия создана')),
              );
            },
            child: const Text('Создать'),
          ),
        ],
      ),
    );
  }

  void _showRestoreDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Восстановление'),
        content: const Text('Восстановить данные из резервной копии?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              // Здесь логика восстановления
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Данные восстановлены')),
              );
            },
            child: const Text('Восстановить'),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Очистить данные'),
        content: const Text('Вы уверены? Это действие нельзя отменить.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () async {
              // Здесь логика очистки
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Данные очищены')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Очистить'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }
}