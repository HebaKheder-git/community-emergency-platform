// lib/screens/reset_password_email_otp_screen.dart
//
// Shown during the Reset Password flow when the user signed up with email.
// Displays a masked email, 6-digit OTP boxes, countdown timer, and resend.
// On successful verify → navigates to CreateNewPasswordScreen.

import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/otp_input_boxes.dart';
import '../widgets/primary_button.dart';
import 'create_new_password_screen.dart';

class ResetPasswordEmailOtpScreen extends StatefulWidget {
  /// The email address the code was sent to.
  /// Pass it already masked, or pass raw and use [OtpVerificationScreen.maskEmail].
  final String email;

  const ResetPasswordEmailOtpScreen({
    super.key,
    required this.email,
  });

  /// Masks an email the Figma way: "sa***********23@gmail.com"
  static String maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2 || parts[0].length < 3) return email;
    final visibleStart = parts[0].substring(0, 2);
    final visibleEnd = parts[0].substring(parts[0].length - 2);
    final stars = '*' * (parts[0].length - 4).clamp(0, 20);
    return '$visibleStart$stars$visibleEnd@${parts[1]}';
  }

  @override
  State<ResetPasswordEmailOtpScreen> createState() =>
      _ResetPasswordEmailOtpScreenState();
}

class _ResetPasswordEmailOtpScreenState
    extends State<ResetPasswordEmailOtpScreen> {
  final _otpKey = GlobalKey<OtpInputBoxesState>();

  String _code = '';
  bool _isVerifying = false;
  Timer? _timer;
  int _secondsRemaining = 25;

  bool get _canResend => _secondsRemaining == 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _secondsRemaining = 25;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsRemaining == 0) {
        t.cancel();
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _onResend() {
    if (!_canResend) return;
    // TODO: call backend to resend reset code to email.
    _otpKey.currentState?.clear();
    setState(() => _code = '');
    _startTimer();
  }

  void _onVerifyPressed() async {
    if (_code.length != 6) return;
    setState(() => _isVerifying = true);

    // TODO: replace with backend OTP verification call.
    await Future.delayed(const Duration(milliseconds: 800));

    setState(() => _isVerifying = false);
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const CreateNewPasswordScreen()),
    );
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // ── Back button ──────────────────────────────────────────────
              IconButton(
                padding: EdgeInsets.zero,
                alignment: Alignment.centerLeft,
                icon: const Icon(
                  Icons.chevron_left,
                  size: 30,
                  color: AppColors.textDark,
                ),
                onPressed: () => Navigator.pop(context),
              ),

              const SizedBox(height: 12),

              // ── Title ────────────────────────────────────────────────────
              const Text(
                'Verify Your Email',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),

              const SizedBox(height: 10),

              // ── Subtitle ─────────────────────────────────────────────────
              Text(
                "We've sent a 6-digit code to ${widget.email}",
                style: AppTextStyles.subtitle,
              ),

              const SizedBox(height: 40),

              // ── OTP boxes ────────────────────────────────────────────────
              OtpInputBoxes(
                key: _otpKey,
                onChanged: (value) => setState(() => _code = value),
                onCompleted: (value) => setState(() => _code = value),
              ),

              const SizedBox(height: 16),

              Center(
                child: Text(
                  'Enter the code you received via Email',
                  style: AppTextStyles.subtitle,
                ),
              ),

              const SizedBox(height: 36),

              // ── Verify button ─────────────────────────────────────────────
              PrimaryButton(
                label: 'Verify',
                enabled: _code.length == 6,
                isLoading: _isVerifying,
                onPressed: _onVerifyPressed,
              ),

              const SizedBox(height: 20),

              // ── Resend row ────────────────────────────────────────────────
              Center(
                child: _canResend
                    ? GestureDetector(
                        onTap: _onResend,
                        child: const Text.rich(
                          TextSpan(
                            style: AppTextStyles.subtitle,
                            children: [
                              TextSpan(text: "Didn't receive the code? "),
                              TextSpan(
                                text: 'RESEND',
                                style: TextStyle(
                                  color: AppColors.primaryRed,
                                  fontWeight: FontWeight.w700,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Text(
                        "Didn't receive the code? Resend in ${_secondsRemaining}s",
                        style: AppTextStyles.subtitle,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}