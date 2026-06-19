import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/otp_input_boxes.dart';
import '../widgets/primary_button.dart';
import 'verification_success_screen.dart';

enum OtpVerificationType { phone, email }

class OtpVerificationScreen extends StatefulWidget {
  final OtpVerificationType verificationType;

  /// Phone number or email address the code was sent to. Pass it already
  /// masked if you want to mask emails like the Figma design does
  /// (e.g. "sa***********23@gmail.com"), or pass the raw value and use
  /// [maskEmail] below.
  final String destination;

  const OtpVerificationScreen({
    super.key,
    required this.verificationType,
    required this.destination,
  });

  /// Utility to mask an email the way the design shows it, in case you
  /// want to pass the raw email in and mask it here instead of upstream.
  static String maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2 || parts[0].length < 3) return email;
    final visibleStart = parts[0].substring(0, 2);
    final visibleEnd = parts[0].substring(parts[0].length - 2);
    final stars = '*' * (parts[0].length - 4).clamp(0, 20);
    return '$visibleStart$stars$visibleEnd@${parts[1]}';
  }

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _otpKey = GlobalKey<OtpInputBoxesState>();

  String _code = '';
  bool _isVerifying = false;
  Timer? _timer;
  int _secondsRemaining = 25;

  bool get _canResend => _secondsRemaining == 0;
  bool get _isPhone => widget.verificationType == OtpVerificationType.phone;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _secondsRemaining = 25;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        timer.cancel();
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
    // TODO: call backend to resend the code.
    _otpKey.currentState?.clear();
    setState(() => _code = '');
    _startTimer();
  }

  void _onVerifyPressed() async {
    if (_code.length != 6) return;

    setState(() => _isVerifying = true);

    // TODO: replace with your backend verification call.
    await Future.delayed(const Duration(milliseconds: 800));

    setState(() => _isVerifying = false);
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => VerificationSuccessScreen(
          verificationType: widget.verificationType,
          // ← no onContinue needed, the screen handles it itself
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = _isPhone ? 'Verify Your Phone Number' : 'Verify Your Email';
    final viaLabel = _isPhone ? 'SMS' : 'Email';

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
              IconButton(
                padding: EdgeInsets.zero,
                alignment: Alignment.centerLeft,
                icon: const Icon(Icons.chevron_left, size: 30, color: AppColors.textDark),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "We've sent a 6-digit code to ${widget.destination}",
                style: AppTextStyles.subtitle,
              ),
              const SizedBox(height: 40),
              OtpInputBoxes(
                key: _otpKey,
                onChanged: (value) => setState(() => _code = value),
                onCompleted: (value) => setState(() => _code = value),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Enter the code you received via $viaLabel',
                  style: AppTextStyles.subtitle,
                ),
              ),
              const SizedBox(height: 36),
              PrimaryButton(
                label: 'Verify',
                enabled: _code.length == 6,
                isLoading: _isVerifying,
                onPressed: _onVerifyPressed,
              ),
              const SizedBox(height: 20),
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