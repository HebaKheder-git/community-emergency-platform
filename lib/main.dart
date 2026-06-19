import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/sign_up_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const EmergencyAuthApp());
}

class EmergencyAuthApp extends StatelessWidget {
  const EmergencyAuthApp({super.key});

  // ── Simulate whether user is already authenticated ──────────────────────
  // Replace this with your real auth-check logic (e.g. SharedPreferences /
  // SecureStorage / backend token validation).
  static const bool _isLoggedIn = false;
  static const String _loggedInUserName = 'Heba Kheder'; // pull from storage

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Soteria – Emergency Response',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      // If user is already signed in → land on HomeScreen directly.
      // Otherwise → start from SignUpScreen as before.
      home: _isLoggedIn
          ? const HomeScreen(userName: _loggedInUserName)
          : const SignUpScreen(),
    );
  }
}