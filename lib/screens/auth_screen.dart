import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_manager/services/auth_service.dart';
import 'package:pinput/pinput.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  AuthScreenState createState() => AuthScreenState();
}

class AuthScreenState extends ConsumerState<AuthScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  String countryCode = "+91";
  bool _isOtpSent = false;
  bool _isLoading = false;

  // Send OTP
  Future<void> sendOTP() async {
    setState(() => _isLoading = true);
    String phone = "$countryCode${_phoneController.text}".replaceAll(" ", "");

    final authService = ref.read(authServiceProvider);
    bool success = await authService.sendOTP(phone);

    if (!mounted) return;

    setState(() {
      _isOtpSent = success;
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? "OTP Sent!" : "Failed to send OTP")),
    );
  }

  // Verify OTP
  Future<void> verifyOTP() async {
    setState(() => _isLoading = true);
    String phone = "$countryCode${_phoneController.text}".replaceAll(" ", "");

    final authService = ref.read(authServiceProvider);
    String? userId = await authService.verifyOTP(phone, _otpController.text);

    setState(() => _isLoading = false);

    if (userId != null) {
      await authService.storeUserDetails(userId, _nameController.text, phone);

      saveUserSession(userId);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Login Successful!")));

      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("OTP Verification Failed")));
    }
  }

  Future<void> saveUserSession(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login / Sign Up")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Enter your details",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Full Name",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 15),

            IntlPhoneField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: "Phone Number",
                border: OutlineInputBorder(),
              ),
              initialCountryCode: 'IN',
              onChanged: (phone) {
                setState(() {
                  countryCode = phone.countryCode;
                });
              },
            ),
            SizedBox(height: 15),

            if (_isOtpSent)
              Pinput(
                length: 6,
                controller: _otpController,
                keyboardType: TextInputType.number,
                defaultPinTheme: PinTheme(
                  width: 50,
                  height: 50,
                  textStyle: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.black),
                  ),
                ),
              ),
            SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    _isLoading ? null : (_isOtpSent ? verifyOTP : sendOTP),
                child:
                    _isLoading
                        ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : Text(_isOtpSent ? "Login / Sign Up" : "Generate OTP"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
