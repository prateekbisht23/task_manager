import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_manager/screens/landing_page.dart';
import 'package:task_manager/screens/auth_screen.dart';
import 'package:task_manager/screens/home_screen.dart';

// Dark mode provider
final darkModeProvider = StateProvider<bool>((ref) => false);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://qdapuftzmahhmhupwvty.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFkYXB1ZnR6bWFoaG1odXB3dnR5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDMxNDk5NTgsImV4cCI6MjA1ODcyNTk1OH0.PoBOGLjDQsowyGzO2DLQLd07yTbYhQMhC4ml6cgpkM8',
  );

  final isLoggedIn = await isUserLoggedIn();
  final initialRoute = isLoggedIn ? '/home' : '/';

  runApp(ProviderScope(child: TaskManagerApp(initialRoute: initialRoute)));
}

Future<bool> isUserLoggedIn() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.containsKey('auth_token');
}

class TaskManagerApp extends ConsumerWidget {
  final String initialRoute;

  const TaskManagerApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(darkModeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Task Manager',
      theme: ThemeData(primarySwatch: Colors.blue),
      darkTheme: ThemeData.dark(),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      initialRoute: initialRoute,
      routes: {
        '/': (context) => LandingPage(),
        '/auth': (context) => AuthScreen(),
        '/home': (context) => HomeScreen(),
      },
    );
  }
}
