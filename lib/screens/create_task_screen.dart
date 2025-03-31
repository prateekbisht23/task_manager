import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_manager/services/task_service.dart';

class CreateTaskScreen extends ConsumerStatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  CreateTaskScreenState createState() => CreateTaskScreenState();
}

class CreateTaskScreenState extends ConsumerState<CreateTaskScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  DateTime? dueDate;
  String priority = "medium";
  String status = "pending";

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Create New Task",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: titleController,
            decoration: const InputDecoration(labelText: "Title"),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: descController,
            decoration: const InputDecoration(labelText: "Description"),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: priority,
            decoration: const InputDecoration(labelText: "Priority"),
            items:
                ["low", "medium", "high"].map((priority) {
                  return DropdownMenuItem(
                    value: priority,
                    child: Text(priority),
                  );
                }).toList(),
            onChanged: (value) {
              if (value != null) setState(() => priority = value);
            },
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: status,
            decoration: const InputDecoration(labelText: "Status"),
            items:
                ["pending", "in-progress", "completed"].map((status) {
                  return DropdownMenuItem(value: status, child: Text(status));
                }).toList(),
            onChanged: (value) {
              if (value != null) setState(() => status = value);
            },
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
                initialDate: DateTime.now(),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () {
                  titleController.clear();
                  descController.clear();
                  setState(() {
                    dueDate = null;
                    priority = "medium";
                    status = "pending";
                  });
                },
                child: const Text("Clear"),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    await TaskService().addTask(
                      titleController.text.trim(),
                      descController.text.trim(),
                      priority,
                      dueDate ?? DateTime.now(),
                      status,
                      ref,
                    );

                    titleController.clear();
                    descController.clear();
                    setState(() {
                      priority = 'medium';
                      dueDate = null;
                      status = 'pending';
                    });

                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Task Added Successfully!")),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: ${e.toString()}")),
                    );
                  }
                },
                child: const Text("Add Task"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
