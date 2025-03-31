import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
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

  Widget buildShimmerLoading() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(completedTaskProvider);

    return RefreshIndicator(
      onRefresh: _refreshTasks,
      child:
          tasks.isEmpty
              ? buildShimmerLoading()
              : ListView.builder(
                controller: _scrollController,
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  return FadeInAnimation(
                    delay: index * 100,
                    child: TaskTile(tasks[index]),
                  );
                },
              ),
    );
  }
}

class FadeInAnimation extends StatelessWidget {
  final Widget child;
  final int delay;

  const FadeInAnimation({super.key, required this.child, required this.delay});

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: 1.0,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeIn,
      child: child,
    );
  }
}
