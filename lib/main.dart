import 'package:flutter/material.dart';
import 'core/token_storage.dart';
import 'repositories/auth_repository.dart';
import 'screens/sign_up_screen.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const EmergencyAuthApp());
}

class EmergencyAuthApp extends StatelessWidget {
  const EmergencyAuthApp({super.key});

  Future<bool> _hasValidSession() async {
    final hasLocalToken = await TokenStorage().isLoggedIn;
    if (!hasLocalToken) return false;

    try {
      // Confirms the stored token is still accepted by the backend.
      await AuthRepository().getMe();
      return true;
    } catch (_) {
      // Token expired/revoked server-side — clear it and send to sign up.
      await TokenStorage().clearAll();
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Soteria – Emergency Response',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      home: FutureBuilder<bool>(
        future: _hasValidSession(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          final isLoggedIn = snapshot.data ?? false;
          return isLoggedIn ? const HomeScreen() : const SignUpScreen();
        },
      ),
    );
  }
}