import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:task_manager/providers/task_provider.dart';

class TaskService {
  final SupabaseClient supabase = Supabase.instance.client;

  /// **Add Task**
  /// Adds a new task to the Supabase database.
  Future<void> addTask(
    String title,
    String description,
    String priority,
    DateTime dueDate,
    String status,
    WidgetRef ref,
  ) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw Exception("User not authenticated");
      }

      final response =
          await supabase.from('tasks').insert({
            'title': title,
            'description': description,
            'priority': priority,
            'due_date': dueDate.toIso8601String(),
            'status': status,
            'user_id': user.id,
          }).select();

      if (response.isEmpty) {
        throw Exception("Task creation failed");
      }

      await ref.read(taskProvider.notifier).fetchTasks(refresh: true);
      await ref.read(completedTaskProvider.notifier).fetchTasks(refresh: true);
    } catch (e) {
      throw Exception("Error adding task: $e");
    }
  }

  Future<void> updateTask(
    String taskId,
    String title,
    String description,
    String priority,
    DateTime dueDate,
    String status,
  ) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw Exception("User not authenticated");
      }

      final response =
          await Supabase.instance.client
              .from('tasks')
              .update({
                'title': title,
                'description': description,
                'priority': priority,
                'due_date': dueDate.toIso8601String(),
                'status': status,
              })
              .eq('id', taskId)
              .eq('user_id', user.id)
              .select();

      if (response.isEmpty) {
        throw Exception("Task not found or unauthorized");
      }
    } catch (e) {
      throw Exception("Error updating task: $e");
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw Exception("User not authenticated");
      }

      await supabase
          .from('tasks')
          .delete()
          .eq('id', taskId)
          .eq('user_id', user.id);

    } catch (e) {
      throw Exception("Error deleting task: $e");
    }
  }
}
