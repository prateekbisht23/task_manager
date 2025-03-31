import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_manager/services/task_service.dart';
import '../providers/task_provider.dart';
import '../screens/edit_task_screen.dart';

class TaskTile extends ConsumerStatefulWidget {
  final Map<String, dynamic> task;

  const TaskTile(this.task, {super.key});

  @override
  TaskTileState createState() => TaskTileState();
}

class TaskTileState extends ConsumerState<TaskTile> {
  late String status;

  @override
  void initState() {
    super.initState();
    status = widget.task['status'];
  }

  @override
  void didUpdateWidget(covariant TaskTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.task['status'] != widget.task['status']) {
      setState(() {
        status = widget.task['status'];
      });
    }
  }

  Future<void> _toggleTaskCompletion(bool? value) async {
    if (value == null) return;

    String newStatus = value ? 'completed' : 'pending';

    setState(() {
      status = newStatus; // Instantly update UI
    });

    await TaskService().updateTask(
      widget.task['id'],
      widget.task['title'],
      widget.task['description'],
      widget.task['priority'],
      DateTime.parse(widget.task['due_date']),
      newStatus,
    );

    if (!mounted) return;

    // Refresh the correct task list
    ref.read(taskProvider.notifier).fetchTasks(refresh: true);
    ref.read(completedTaskProvider.notifier).fetchTasks(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    bool isCompleted = status == 'completed';

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title & Checkbox
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.task['title'],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      decoration:
                          isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
                Checkbox(value: isCompleted, onChanged: _toggleTaskCompletion),
              ],
            ),
            const SizedBox(height: 4),

            // Description
            Text(
              widget.task['description'],
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),

            // Due Date
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  "Due: ${_formatDate(widget.task['due_date'])}",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Priority & Status Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildLabel(
                  "Priority: ${widget.task['priority']}",
                  _getPriorityColor(widget.task['priority']),
                ),
                _buildLabel("Status: $status", _getStatusColor(status)),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditTaskScreen(task: widget.task),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha((0.2 * 255).toInt()),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'in-progress':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String date) {
    try {
      DateTime parsedDate = DateTime.parse(date);
      return "${parsedDate.day}-${parsedDate.month}-${parsedDate.year}";
    } catch (e) {
      return "Invalid date";
    }
  }
}
