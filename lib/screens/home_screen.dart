import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_manager/main.dart';
import 'package:task_manager/screens/completed_task_screen.dart';
import 'package:task_manager/screens/create_task_screen.dart';
import 'package:task_manager/screens/task_list_screen.dart';
import 'package:task_manager/services/auth_service.dart';
import 'package:task_manager/services/user_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(darkModeProvider);

    return Scaffold(
      appBar: AppBar(
        leading: FutureBuilder<String?>(
          future: UserService().fetchUserName(),
          builder: (context, snapshot) {
            String userName = snapshot.data ?? "User";
            return PopupMenuButton<String>(
              icon: const Icon(Icons.person),
              onSelected: (value) async {
                if (value == 'logout') {
                  final authService = ref.read(authServiceProvider);
                  await authService.logout();
                  if (context.mounted) {
                    Navigator.pushReplacementNamed(context, '/');
                  }
                }
              },
              itemBuilder:
                  (context) => [
                    PopupMenuItem(
                      enabled: false,
                      child: Row(
                        children: [
                          const Icon(Icons.account_circle, size: 24),
                          const SizedBox(width: 10),
                          Text(
                            userName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      enabled: false,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Dark Mode"),
                          Switch(
                            value: isDarkMode,
                            onChanged: (value) {
                              Navigator.of(context).pop();
                              ref.read(darkModeProvider.notifier).state = value;
                            },
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.logout, color: Colors.redAccent),
                          SizedBox(width: 10),
                          Text(
                            'Logout',
                            style: TextStyle(color: Colors.redAccent),
                          ),
                        ],
                      ),
                    ),
                  ],
            );
          },
        ),
        title: const Text('Task Manager'),
        centerTitle: true,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          TaskListScreen(),
          CreateTaskScreen(),
          CompletedTaskScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "Task List"),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: "Create Task"),
          BottomNavigationBarItem(
            icon: Icon(Icons.check),
            label: "Completed Tasks",
          ),
        ],
      ),
    );
  }
}
