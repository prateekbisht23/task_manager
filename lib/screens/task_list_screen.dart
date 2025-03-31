import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_manager/services/task_service.dart';
import '../providers/task_provider.dart';
import '../widgets/task_tile.dart';

class TaskListScreen extends ConsumerStatefulWidget {
  const TaskListScreen({super.key});

  @override
  TaskListScreenState createState() => TaskListScreenState();
}

class TaskListScreenState extends ConsumerState<TaskListScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isFetching = false;

  @override
  void initState() {
    super.initState();
    _fetchTasks();
    _fetchRecommendedTasks();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _fetchTasks();
      }
    });
  }

  void _fetchTasks({bool refresh = false}) async {
    if (_isFetching) return;
    _isFetching = true;

    await ref.read(taskProvider.notifier).fetchTasks(refresh: refresh);

    _isFetching = false;
  }

  Future<void> _fetchRecommendedTasks() async {
    await ref.read(taskProvider.notifier).fetchRecommendedTasks();
  }

  Future<void> _refreshTasks() async {
    _fetchTasks(refresh: true);
  }

  void _addTaskToList(Map<String, dynamic> task) async {
    await TaskService().addTask(
      task['title'],
      task['description'],
      task['priority'],
      DateTime.parse(task['due_date']),
      task['status'],
      ref,
    );

    ref.read(taskProvider.notifier).fetchTasks(refresh: true);
    ref
        .read(taskProvider.notifier)
        .fetchRecommendedTasks();
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(taskProvider);
    final recommendedTasks = ref.watch(taskProvider.notifier).state;

    // Limit the recommended tasks to 2 tasks only
    final limitedRecommendedTasks = recommendedTasks.take(2).toList();

    final sortedTasks = [...tasks]..sort(
      (a, b) => DateTime.parse(
        a['due_date'],
      ).compareTo(DateTime.parse(b['due_date'])),
    );

    return RefreshIndicator(
      onRefresh: _refreshTasks,
      child: ListView(
        controller: _scrollController,
        children: [
          // Display the regular tasks section
          if (sortedTasks.isEmpty)
            const Center(
              child: Text(
                "No pending tasks",
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            )
          else
            Column(
              children:
                  sortedTasks
                      .map(
                        (task) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: TaskTile(task),
                        ),
                      )
                      .toList(),
            ),

          // Display the recommended tasks section at the bottom
          if (limitedRecommendedTasks.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recommended Tasks',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  ...limitedRecommendedTasks.map(
                    (task) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Card(
                        elevation: 4,
                        color: Colors.grey.shade200,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12.0,
                            horizontal: 6.0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TaskTile(task),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () {
                                  _addTaskToList(task);
                                },
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.blueGrey,
                                ),
                                child: const Text('Add Task'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
