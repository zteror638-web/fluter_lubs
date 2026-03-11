import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/habit_constructor_screen.dart';
import 'screens/inspiration_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/about_screen.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storageService = await StorageService.init();
  runApp(MyApp(storageService: storageService));
}

class MyApp extends StatelessWidget {
  final StorageService storageService;

  const MyApp({super.key, required this.storageService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: storageService),
      ],
      child: Consumer<StorageService>(
        builder: (context, storage, child) {
          final isDarkMode = storage.settings.isDarkMode;
          
          return MaterialApp(
                title: 'Habit & Idea Tracker',
                themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
                theme: ThemeData(
                  primarySwatch: Colors.blue,
                  useMaterial3: true,
                  fontFamily: 'Roboto',
                  appBarTheme: const AppBarTheme(
                    elevation: 0,
                    centerTitle: true,
                  ),
                  // Убираем cardTheme полностью
                ),
                darkTheme: ThemeData.dark().copyWith(
                  primaryColor: Colors.blue,
                  appBarTheme: const AppBarTheme(
                    elevation: 0,
                    centerTitle: true,
                  ),
                  // Убираем cardTheme полностью
                ),
                initialRoute: '/',
                routes: {
                  '/': (context) => const MainNavigationScreen(),
                  '/habitConstructor': (context) => const HabitConstructorScreen(),
                  '/settings': (context) => const SettingsScreen(),
                  '/inspiration': (context) => const InspirationScreen(),
                  '/favorites': (context) => const FavoritesScreen(),
                  '/about': (context) => const AboutScreen(),
                },
                debugShowCheckedModeBanner: false,
              );
        },
      ),
    );
  }
}

// Главный экран с BottomNavigationBar
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => MainNavigationScreenState();
}

class MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  
  late final List<Widget> _screens = [
    const HomeScreen(),
    const InspirationScreen(),
    const FavoritesScreen(),
    const AboutScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Главная',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome_outlined),
            activeIcon: Icon(Icons.auto_awesome),
            label: 'Вдохновение',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline),
            activeIcon: Icon(Icons.favorite),
            label: 'Избранное',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info_outline),
            activeIcon: Icon(Icons.info),
            label: 'О нас',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, '/habitConstructor');
              },
              child: const Icon(Icons.add),
              tooltip: 'Добавить привычку',
            )
          : null,
    );
  }
}