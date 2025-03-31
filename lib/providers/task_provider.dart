import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

final taskProvider =
    StateNotifierProvider<TaskNotifier, List<Map<String, dynamic>>>((ref) {
      return TaskNotifier();
    });

final completedTaskProvider =
    StateNotifierProvider<TaskNotifier, List<Map<String, dynamic>>>((ref) {
      return TaskNotifier(isCompleted: true);
    });

class TaskNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  TaskNotifier({this.isCompleted = false}) : super([]);

  final SupabaseClient supabase = Supabase.instance.client;
  final int _pageSize = 10;
  bool _isFetching = false;
  int _page = 0;
  final bool isCompleted;

  // URL to the Supabase Edge function for recommendations
  final String supabaseFunctionUrl =
      "http://127.0.0.1:54321/functions/v1/getTaskRecommendations";

  Future<void> fetchTasks({bool refresh = false}) async {
    final user = supabase.auth.currentUser;
    if (_isFetching || user == null) return;

    _isFetching = true;
    if (refresh) {
      state = [];
      _page = 0;
    }

    try {
      final response = await supabase
          .from('tasks')
          .select('*')
          .eq('user_id', user.id)
          .inFilter(
            'status',
            isCompleted ? ['completed'] : ['pending', 'in-progress'],
          )
          .order('due_date', ascending: false)
          .range(_page * _pageSize, (_page + 1) * _pageSize - 1);

      if (response.isNotEmpty) {
        state = refresh ? response : [...state, ...response];
        _page++;
      }
    } catch (e) {
      return;
    } finally {
      _isFetching = false;
    }
  }

  // Method to fetch recommended tasks
  Future<void> fetchRecommendedTasks() async {
    final user = supabase.auth.currentUser;
    if (_isFetching || user == null) return;

    _isFetching = true;

    try {
      final session = supabase.auth.currentSession;
      final authToken = session?.accessToken ?? '';

      if (authToken.isEmpty) {
        return;
      }

      final response = await http.post(
        Uri.parse(supabaseFunctionUrl),
        headers: {
          "Authorization": "Bearer $authToken",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final recommendations = data['recommendations'] ?? [];

        if (recommendations.isNotEmpty) {
          state = [...state, ...recommendations];
        } else {
          return;
        }
      } else {
        return;
      }
    } catch (e) {
      return;
    } finally {
      _isFetching = false;
    }
  }
}
