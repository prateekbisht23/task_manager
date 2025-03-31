import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  Future<void> _refreshTasks() async {
    _fetchTasks(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(taskProvider);

    final sortedTasks = [...tasks]..sort(
      (a, b) => DateTime.parse(
        a['due_date'],
      ).compareTo(DateTime.parse(b['due_date'])),
    );

    return RefreshIndicator(
      onRefresh: _refreshTasks,
      child:
          sortedTasks.isEmpty
              ? const Center(
                child: Text(
                  "No pending tasks",
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
              )
              : ListView.builder(
                controller: _scrollController,
                itemCount: sortedTasks.length,
                itemBuilder: (context, index) {
                  return TaskTile(sortedTasks[index]);
                },
              ),
    );
  }
}
