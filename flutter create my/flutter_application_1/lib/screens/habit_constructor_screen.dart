import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/storage_service.dart';
import '../models/habit.dart';
import '../utils/constants.dart';

class HabitConstructorScreen extends StatefulWidget {
  const HabitConstructorScreen({super.key});

  @override
  State<HabitConstructorScreen> createState() => _HabitConstructorScreenState();
}

class _HabitConstructorScreenState extends State<HabitConstructorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  
  IconData _selectedIcon = Icons.fitness_center;
  Color _selectedColor = Colors.blue;
  String _selectedPeriodicity = 'daily';
  int _targetDays = 21;
  TimeOfDay? _reminderTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Создать привычку'),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Название привычки',
                hintText: 'Например: Пить воду',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Введите название привычки';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 20),
            
            const Text(
              'Выберите иконку:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 100,
              child: GridView.builder(
                scrollDirection: Axis.horizontal,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: AppConstants.habitIcons.length,
                itemBuilder: (context, index) {
                  final icon = AppConstants.habitIcons[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIcon = icon;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: _selectedIcon == icon
                            ? _selectedColor.withOpacity(0.2)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedIcon == icon
                              ? _selectedColor
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        icon,
                        color: _selectedIcon == icon
                            ? _selectedColor
                            : Colors.grey.shade600,
                        size: 30,
                      ),
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 20),
            
            const Text(
              'Выберите цвет:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppConstants.habitColors.map((color) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColor = color;
                    });
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _selectedColor == color
                            ? Colors.black
                            : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: _selectedColor == color
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                          )
                        : null,
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 20),
            
            const Text(
              'Периодичность:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'daily',
                  label: Text('Ежедневно'),
                  icon: Icon(Icons.calendar_today),
                ),
                ButtonSegment(
                  value: 'weekly',
                  label: Text('Еженедельно'),
                  icon: Icon(Icons.calendar_view_week),
                ),
              ],
              selected: {_selectedPeriodicity},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  _selectedPeriodicity = newSelection.first;
                });
              },
            ),
            
            const SizedBox(height: 20),
            
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Напоминание'),
              subtitle: Text(_reminderTime != null
                  ? _reminderTime!.format(context)
                  : 'Не установлено'),
              trailing: IconButton(
                icon: Icon(_reminderTime != null 
                    ? Icons.edit 
                    : Icons.add),
                onPressed: _selectReminderTime,
              ),
            ),
            
            const SizedBox(height: 20),
            
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Цель: сформировать привычку за $_targetDays дней',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 10),
                Slider(
                  value: _targetDays.toDouble(),
                  min: 7,
                  max: 66,
                  divisions: 59,
                  label: _targetDays.toString(),
                  onChanged: (value) {
                    setState(() {
                      _targetDays = value.round();
                    });
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 30),
            
            ElevatedButton(
              onPressed: _saveHabit,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: _selectedColor,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Создать привычку',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectReminderTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _reminderTime = picked;
      });
    }
  }

  Future<void> _saveHabit() async {
    if (_formKey.currentState!.validate()) {
      final storage = Provider.of<StorageService>(context, listen: false);
      
      final habit = Habit(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        icon: _selectedIcon,
        color: _selectedColor,
        periodicity: _selectedPeriodicity,
        createdAt: DateTime.now(),
        completionDates: [],
        targetDays: _targetDays,
        reminderTime: _reminderTime,
      );
      
      await storage.addHabit(habit);
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Привычка "${habit.title}" создана!'),
            backgroundColor: _selectedColor,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }
}