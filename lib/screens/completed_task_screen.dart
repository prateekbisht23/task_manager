import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/task_provider.dart';
import '../widgets/task_tile.dart';

class CompletedTaskScreen extends ConsumerStatefulWidget {
  const CompletedTaskScreen({super.key});

  @override
  CompletedTaskScreenState createState() => CompletedTaskScreenState();
}

class CompletedTaskScreenState extends ConsumerState<CompletedTaskScreen> {
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

    await ref.read(completedTaskProvider.notifier).fetchTasks(refresh: refresh);

    _isFetching = false;
  }

  Future<void> _refreshTasks() async {
    _fetchTasks(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(completedTaskProvider);

    return RefreshIndicator(
      onRefresh: _refreshTasks,
      child:
          tasks.isEmpty
              ? const Center(
                child: Text(
                  "No completed tasks",
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
              )
              : ListView.builder(
                controller: _scrollController,
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  return TaskTile(tasks[index]);
                },
              ),
    );
  }
}
