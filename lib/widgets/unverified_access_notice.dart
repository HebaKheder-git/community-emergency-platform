// lib/widgets/unverified_access_notice.dart

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'primary_button.dart';
import '../screens/account_verification_intro_screen.dart';

/// The "you have to verify your account..." block shown in place of a
/// section's real content when the current user hasn't verified their
/// account yet (Figma: locked state for Home, Notifications, Community
/// Chat, and Service Providers).
///
/// Self-contained and self-padded so it can be dropped straight into a
/// Scaffold body:
///
///   body: const SafeArea(child: UnverifiedAccessNotice()),
///
/// Marketplaces is intentionally NOT gated by this widget — unverified
/// users can still browse marketplaces per the product spec.
class UnverifiedAccessNotice extends StatelessWidget {
  const UnverifiedAccessNotice({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 24),

          // ── Info banner ──────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(
                  Icons.info_outline,
                  color: AppColors.textGrey,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'You have to verify your account and join a '
                  'group to get access to this',
                  style: AppTextStyles.subtitle.copyWith(
                    fontSize: 17,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // ── Verification prompt ─────────────────────────────────────
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
      ),
    );
  }
}