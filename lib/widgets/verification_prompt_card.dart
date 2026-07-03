// lib/widgets/verification_prompt_card.dart

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'primary_button.dart';
import '../screens/account_verification_intro_screen.dart';

/// The "Let's get your account verified!" prompt block.
///
/// Extracted into its own widget so it's pixel- and behavior-identical
/// everywhere it's used — currently inside [UnverifiedAccessNotice]
/// (the locked state for Home / Notifications / Chat / Service Providers)
/// and inside the unverified variant of [EditProfileScreen]. If the copy
/// or the button's destination ever changes, it only needs to change here.
class VerificationPromptCard extends StatelessWidget {
  const VerificationPromptCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 26,
              height: 26,
              margin: const EdgeInsets.only(top: 2),
              decoration: const BoxDecoration(
                color: AppColors.primaryRed,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.star, color: Colors.white, size: 15),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Let's get your account verified!",
                    style: AppTextStyles.linkRed.copyWith(fontSize: 17),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'verified accounts get full access to\n'
                    'all platform features.',
                    style: AppTextStyles.subtitle,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: 200,
          child: PrimaryButton(
            label: 'Start Verification',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AccountVerificationIntroScreen(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}