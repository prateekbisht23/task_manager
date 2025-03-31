import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_manager/services/task_service.dart';
import '../providers/task_provider.dart';

class EditTaskScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> task;

  const EditTaskScreen({super.key, required this.task});

  @override
  EditTaskScreenState createState() => EditTaskScreenState();
}

class EditTaskScreenState extends ConsumerState<EditTaskScreen> {
  late TextEditingController titleController;
  late TextEditingController descController;
  late String priority;
  late String status;
  DateTime? dueDate;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.task['title']);
    descController = TextEditingController(text: widget.task['description']);
    priority = widget.task['priority'];
    status = widget.task['status'];
    dueDate = DateTime.tryParse(widget.task['due_date']);
  }

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    super.dispose();
  }

  Future<void> _updateTask() async {
    if (titleController.text.trim().isEmpty || dueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Title and Due Date are required")),
      );
      return;
    }

    await TaskService().updateTask(
      widget.task['id'],
      titleController.text.trim(),
      descController.text.trim(),
      priority,
      dueDate!,
      status,
    );

    if (!mounted) return;

    await ref.read(taskProvider.notifier).fetchTasks(refresh: true);
    await ref.read(completedTaskProvider.notifier).fetchTasks(refresh: true);

    Navigator.pop(context);
  }

  Future<void> _deleteTask() async {
    final confirmDelete = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Delete Task"),
            content: const Text("Are you sure you want to delete this task?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  "Delete",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirmDelete == true) {
      await TaskService().deleteTask(widget.task['id']);

      if (!mounted) return;

      await ref.read(taskProvider.notifier).fetchTasks(refresh: true);
      await ref.read(completedTaskProvider.notifier).fetchTasks(refresh: true);

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Task")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Title"),
              ),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: "Description"),
              ),
              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                value: priority,
                decoration: const InputDecoration(labelText: "Priority"),
                items:
                    ["low", "medium", "high"].map((p) {
                      return DropdownMenuItem(value: p, child: Text(p));
                    }).toList(),
                onChanged: (value) => setState(() => priority = value!),
              ),
              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                value: status,
                decoration: const InputDecoration(labelText: "Status"),
                items:
                    ["pending", "in-progress", "completed"].map((s) {
                      return DropdownMenuItem(value: s, child: Text(s));
                    }).toList(),
                onChanged: (value) => setState(() => status = value!),
              ),
              const SizedBox(height: 8),

              ListTile(
                title: Text(
                  dueDate == null
                      ? "Select Due Date"
                      : "Due Date: ${dueDate!.toString().split(' ')[0]}",
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: dueDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    setState(() => dueDate = pickedDate);
                  }
                },
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _updateTask,
                    child: const Text("Update Task"),
                  ),
                  ElevatedButton(
                    onPressed: _deleteTask,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Delete Task"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
