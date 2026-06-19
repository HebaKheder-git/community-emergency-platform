import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'otp_verification_screen.dart';
import 'account_verification_intro_screen.dart';

class VerificationSuccessScreen extends StatefulWidget {
  final OtpVerificationType verificationType;
  final VoidCallback? onContinue;

  const VerificationSuccessScreen({
    super.key,
    required this.verificationType,
    this.onContinue,
  });

  @override
  State<VerificationSuccessScreen> createState() =>
      _VerificationSuccessScreenState();
}

class _VerificationSuccessScreenState extends State<VerificationSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _scaleAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _controller.forward();

    // ✅ Use Future.delayed with mounted check INSIDE this screen's own state
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return; // ← this now correctly checks THIS screen's state
      if (widget.onContinue != null) {
        widget.onContinue!();
      } else {
        // Default: go to account verification intro
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const AccountVerificationIntroScreen(),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final message = widget.verificationType == OtpVerificationType.phone
        ? 'Your phone number has been verified!'
        : 'Your Email Address has been verified!';

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 48),
                ),
              ),
              const SizedBox(height: 28),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryRed,
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