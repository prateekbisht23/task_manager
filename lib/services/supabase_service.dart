import 'dart:convert';
import 'package:http/http.dart' as http;

class SupabaseService {
  final String supabaseFunctionUrl =
      "http://127.0.0.1:54321/functions/v1/getTaskRecommendations";

  Future<List<dynamic>> fetchTaskRecommendations(String authToken) async {
    try {
      final response = await http.post(
        Uri.parse(supabaseFunctionUrl),
        headers: {
          "Authorization": "Bearer $authToken",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['recommendations'] ?? [];
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}
