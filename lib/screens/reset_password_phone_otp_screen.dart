// lib/screens/reset_password_phone_otp_screen.dart
//
// Shown after the user submits their phone number on ResetPasswordPhoneScreen.
// Identical OTP UX to the email variant but says "via SMS".
// On successful verify → navigates to CreateNewPasswordScreen.

import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/otp_input_boxes.dart';
import '../widgets/primary_button.dart';
// import 'create_new_password_screen.dart';

class ResetPasswordPhoneOtpScreen extends StatefulWidget {
  /// The phone number the code was sent to (displayed in the subtitle).
  final String phoneNumber;

  const ResetPasswordPhoneOtpScreen({
    super.key,
    required this.phoneNumber,
  });

  @override
  State<ResetPasswordPhoneOtpScreen> createState() =>
      _ResetPasswordPhoneOtpScreenState();
}

class _ResetPasswordPhoneOtpScreenState
    extends State<ResetPasswordPhoneOtpScreen> {
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
    // TODO: call backend to resend reset code to phone.
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

    //Navigator.pushReplacement(
    //  context,
    //  MaterialPageRoute(builder: (_) => const CreateNewPasswordScreen()),
    //);
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

              // ── Back button ────────────────────────────────────────────
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

              // ── Title ──────────────────────────────────────────────────
              const Text(
                'Verify Your Phone Number',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),

              const SizedBox(height: 10),

              // ── Subtitle ───────────────────────────────────────────────
              Text(
                "We've sent a 6-digit code to ${widget.phoneNumber}",
                style: AppTextStyles.subtitle,
              ),

              const SizedBox(height: 40),

              // ── OTP boxes ──────────────────────────────────────────────
              OtpInputBoxes(
                key: _otpKey,
                onChanged: (value) => setState(() => _code = value),
                onCompleted: (value) => setState(() => _code = value),
              ),

              const SizedBox(height: 16),

              Center(
                child: Text(
                  'Enter the code you received via SMS',
                  style: AppTextStyles.subtitle,
                ),
              ),

              const SizedBox(height: 36),

              // ── Verify button ──────────────────────────────────────────
              PrimaryButton(
                label: 'Verify',
                enabled: _code.length == 6,
                isLoading: _isVerifying,
                onPressed: _onVerifyPressed,
              ),

              const SizedBox(height: 20),

              // ── Resend row ─────────────────────────────────────────────
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