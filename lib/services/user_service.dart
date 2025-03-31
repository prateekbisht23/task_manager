import 'package:supabase_flutter/supabase_flutter.dart';

class UserService {
  Future<String?> fetchUserName() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return null;

    final response =
        await Supabase.instance.client
            .from('users')
            .select('name')
            .eq('id', userId)
            .single();

    return response['name'] as String?;
  }
}
