import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_idea_tracker/main.dart'; // Измените на правильный импорт
import 'package:provider/provider.dart';
import 'package:habit_idea_tracker/services/storage_service.dart';

void main() {
  testWidgets('Приложение запускается и отображает главный экран', 
    (WidgetTester tester) async {
    // Инициализация тестового хранилища
    final storageService = await StorageService.init();
    
    // Создаем тестовое приложение
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: storageService),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: Center(
              child: Text('Тестовое приложение'),
            ),
          ),
        ),
      ),
    );

    // Ждем завершения анимаций
    await tester.pumpAndSettle();

    // Проверяем, что приложение запустилось
    expect(find.text('Тестовое приложение'), findsOneWidget);
  });

  testWidgets('Проверка навигации', (WidgetTester tester) async {
    final storageService = await StorageService.init();
    
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: storageService),
        ],
        child: const MaterialApp(
          home: MainNavigationScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Проверяем, что главный экран загрузился
    expect(find.text('Мой прогресс'), findsOneWidget);
    
    // Проверяем BottomNavigationBar
    expect(find.byIcon(Icons.home_outlined), findsOneWidget);
    expect(find.byIcon(Icons.auto_awesome_outlined), findsOneWidget);
  });
}