import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

class AuthService {
  final SupabaseClient supabase = Supabase.instance.client;

  // Send OTP
  Future<bool> sendOTP(String phone) async {
    try {
      await supabase.auth.signInWithOtp(phone: phone);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Verify OTP
  Future<String?> verifyOTP(String phone, String otp) async {
    try {
      final response = await supabase.auth.verifyOTP(
        phone: phone,
        token: otp,
        type: OtpType.sms,
      );
      return response.user?.id;
    } catch (e) {
      return null;
    }
  }

  // Store user details in Supabase database
  Future<void> storeUserDetails(
    String userId,
    String name,
    String phone,
  ) async {
    try {
      await supabase.from('users').upsert({
        'id': userId,
        'name': name,
        'phone': phone,
      });
    } catch (e) {
      return;
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await supabase.auth.signOut();
    } catch (e) {
      return;
    }
  }
}
