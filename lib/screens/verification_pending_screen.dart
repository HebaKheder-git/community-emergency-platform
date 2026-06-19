import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

/// Shown after the user submits all verification data.
/// Communicates that the submission is under review, styled
/// consistently with [VerificationSuccessScreen].
class VerificationPendingScreen extends StatefulWidget {
  const VerificationPendingScreen({super.key});

  @override
  State<VerificationPendingScreen> createState() =>
      _VerificationPendingScreenState();
}

class _VerificationPendingScreenState extends State<VerificationPendingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Animated pending icon
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.primaryRed.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primaryRed,
                      width: 3,
                    ),
                  ),
                  child: const Icon(
                    Icons.hourglass_top_rounded,
                    color: AppColors.primaryRed,
                    size: 48,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Heading
              const Text(
                'Verification Pending',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryRed,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 14),

              // Body copy
              const Text(
                'Your documents have been submitted\nand are currently under review.\n\nWe\'ll notify you once your account\nhas been verified.',
                textAlign: TextAlign.center,
                style: AppTextStyles.subtitle,
              ),
              const SizedBox(height: 48),

              // Go to home button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const HomeScreen(
                          // TODO: Pass the real logged-in user's name from your auth state.
                          userName: 'Heba Kheder',
                        ),
                      ),
                      (route) => false, // removes all previous routes
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryRed,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Go to Home',
                    style: AppTextStyles.buttonText,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}