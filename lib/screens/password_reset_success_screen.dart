// lib/screens/password_reset_success_screen.dart
//
// Final screen of the Reset Password flow.
// Shows green checkmark, success title in red, subtitle, and a
// "Continue" button that navigates back to LoginScreen (or HomeScreen
// if the user was already logged in — swap the destination as needed).

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/primary_button.dart';
import 'login_screen.dart';

class PasswordResetSuccessScreen extends StatelessWidget {
  const PasswordResetSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
          ),
          child: Column(
            children: [
              // ── Spacer pushes content to vertical center ─────────────────
              const Spacer(),

              // ── Green checkmark circle ────────────────────────────────────
              Container(
                width: 90,
                height: 90,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 50,
                ),
              ),

              const SizedBox(height: 28),

              // ── Title ─────────────────────────────────────────────────────
              const Text(
                'Password successfully reset',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryRed,
                ),
              ),

              const SizedBox(height: 12),

              // ── Subtitle ──────────────────────────────────────────────────
              const Text(
                'You can now log in with your new password.',
                textAlign: TextAlign.center,
                style: AppTextStyles.subtitle,
              ),

              // ── Spacer above button ────────────────────────────────────────
              const Spacer(),

              // ── Continue button (pinned near the bottom) ──────────────────
              PrimaryButton(
                label: 'Continue',
                onPressed: () {
                  // Navigate back to login, clearing the whole stack.
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (_) => false,
                  );
                },
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}