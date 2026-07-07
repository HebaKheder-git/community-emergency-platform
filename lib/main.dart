import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/token_storage.dart';
import 'repositories/auth_repository.dart';
import 'cubits/trust_verification/trust_verification_cubit.dart';
import 'screens/sign_up_screen.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const EmergencyAuthApp());
}

class EmergencyAuthApp extends StatelessWidget {
  const EmergencyAuthApp({super.key});

  // Single shared instance for the whole app lifetime. Every screen that
  // reads TrustVerificationCubit (Settings, Edit Profile, Home,
  // Notifications, Service Providers, VerificationPromptCard) now sees the
  // SAME state instead of each one independently fetching (or, as before,
  // silently reading a dead ValueNotifier that never updated).
  static final TrustVerificationCubit trustVerificationCubit =
      TrustVerificationCubit();

  Future<bool> _hasValidSession() async {
    final hasLocalToken = await TokenStorage().isLoggedIn;
    if (!hasLocalToken) return false;

    try {
      // Confirms the stored token is still accepted by the backend.
      await AuthRepository().getMe();
      // Only worth hitting /trust-verification/me once we know we're
      // actually authenticated — kick off the real fetch here.
      trustVerificationCubit.loadMine();
      return true;
    } catch (_) {
      // Token expired/revoked server-side — clear it and send to sign up.
      await TokenStorage().clearAll();
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TrustVerificationCubit>.value(
      value: trustVerificationCubit,
      child: MaterialApp(
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
      ),
    );
  }
}