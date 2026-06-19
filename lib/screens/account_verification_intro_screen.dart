import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/primary_button.dart';
import 'verification_step1_personal_info_screen.dart';

/// Screen shown right after VerificationSuccessScreen.
/// Gives the user a clear entry point into the 3-step account verification
/// flow, or lets them skip it for later.
class AccountVerificationIntroScreen extends StatelessWidget {
  const AccountVerificationIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Push content roughly to the vertical center
              const Spacer(flex: 3),

              // Icon + heading row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Red star circle badge
                  Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryRed,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.star,
                      color: Colors.white,
                      size: 38,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Heading
                  Expanded(
                    child: Text(
                      "Let's get your\naccount verified!",
                      style: AppTextStyles.heading.copyWith(
                        fontSize: 28,
                        height: 1.25,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Subtitle
              const Text(
                'verified accounts get full access to\nall platform features.',
                style: AppTextStyles.subtitle,
              ),

              const Spacer(flex: 4),

              // CTA button
              PrimaryButton(
                label: 'Start Verification',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const VerificationStep1PersonalInfoScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Skip link
              Center(
                child: GestureDetector(
                  onTap: () {
                    // TODO: navigate to main home screen
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  child: const Text(
                    'Skip for now',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}