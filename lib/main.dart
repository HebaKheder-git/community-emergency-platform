// EDITED — the build() method was a stub ("//FILLED WITH CODE"). The old
// hardcoded `_isLoggedIn = false` constant is replaced with a real check
// against TokenStorage (was there a token saved by a previous
// login/register/reset-password call?). There's still no GET /me endpoint,
// so we can't validate the token against the backend here — just that one
// exists locally. Add a token-validity check once that endpoint exists.

import 'package:flutter/material.dart';
import 'core/token_storage.dart';
import 'screens/sign_up_screen.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const EmergencyAuthApp());
}

class EmergencyAuthApp extends StatelessWidget {
  const EmergencyAuthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Soteria – Emergency Response',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      home: FutureBuilder<bool>(
        future: TokenStorage().isLoggedIn,
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



  // ── Simulate whether user is already authenticated ──────────────────────
  // Replace this with your real auth-check logic (e.g. SharedPreferences /
  // SecureStorage / backend token validation).
  //static const bool _isLoggedIn = false;
  //Future<String?> _loggedInUserName = TokenStorage().readName(); // pull from storage

  //@override
  //Widget build(BuildContext context) {
  ////  return MaterialApp(
  //    title: 'Soteria – Emergency Response',
  //    debugShowCheckedModeBanner: false,
  //    theme: appTheme,
  //    // If user is already signed in → land on HomeScreen directly.
  //    // Otherwise → start from SignUpScreen as before.
  //    home: _isLoggedIn
  //        ? const HomeScreen(userName: _loggedInUserName)
  //        : const SignUpScreen(),
  //  );
  //}
//}