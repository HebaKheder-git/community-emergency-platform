import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/token_storage.dart';
import 'cubits/auth/auth_cubit.dart';
import 'cubits/auth/auth_state.dart';
import 'cubits/trust_verification/trust_verification_cubit.dart';
import 'screens/sign_up_screen.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const EmergencyAuthApp());
}

class EmergencyAuthApp extends StatelessWidget {
  const EmergencyAuthApp({super.key});

  // Single shared instances for the whole app lifetime. Every screen that
  // reads AuthCubit or TrustVerificationCubit (Settings, Edit Profile, Home,
  // Notifications, Service Providers, VerificationPromptCard) now sees the
  // SAME state instead of each independently fetching, or reading a
  // never-provided cubit and crashing.
  static final TrustVerificationCubit trustVerificationCubit =
      TrustVerificationCubit();
  static final AuthCubit authCubit = AuthCubit(); // NEW

  Future<bool> _hasValidSession() async {
    final hasLocalToken = await TokenStorage().isLoggedIn;
    if (!hasLocalToken) return false;

    // NEW — authCubit.fetchMe() both confirms the token is still accepted
    // by the backend AND populates authCubit.state.roles (needed for
    // isTrusted), replacing the old throwaway AuthRepository().getMe()
    // call so we don't hit /me twice for the same purpose.
    await authCubit.fetchMe();
    if (authCubit.state.status == AuthStatus.failure) {
      // Token expired/revoked server-side — clear it and send to sign up.
      await TokenStorage().clearAll();
      return false;
    }

    // Only worth hitting /trust-verification/me once we know we're
    // actually authenticated.
    trustVerificationCubit.loadMine();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<TrustVerificationCubit>.value(value: trustVerificationCubit),
        BlocProvider<AuthCubit>.value(value: authCubit), // NEW
      ],
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