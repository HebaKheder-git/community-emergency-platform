// EDITED — wired to POST /auth/verify-code and POST /auth/resend.
//
// This screen is reached only from the sign-up flow now (the backend has
// no phone registration yet, so verificationType is effectively always
// .email until that endpoint exists — the enum/UI is left in place for
// when it does).
//
// It now requires the `tempToken` issued by /auth/register and passes it
// explicitly into every cubit call, so this screen can own its own fresh
// AuthCubit instance rather than needing one threaded through from
// SignUpScreen.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/auth/auth_cubit.dart';
import '../cubits/auth/auth_state.dart';
import '../theme/app_theme.dart';
import '../widgets/otp_input_boxes.dart';
import '../widgets/primary_button.dart';
import 'verification_success_screen.dart';
import '../main.dart';

enum OtpVerificationType { phone, email }

class OtpVerificationScreen extends StatefulWidget {
  final OtpVerificationType verificationType;
  final String destination;
  final String tempToken;

  const OtpVerificationScreen({
    super.key,
    required this.verificationType,
    required this.destination,
    required this.tempToken,
  });

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
  late final AuthCubit _cubit;

  String _code = '';
  Timer? _timer;
  int _secondsRemaining = 25;

  bool get _canResend => _secondsRemaining == 0;
  bool get _isPhone => widget.verificationType == OtpVerificationType.phone;

  @override
  void initState() {
    super.initState();
    _cubit = AuthCubit();
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
    _cubit.close();
    super.dispose();
  }

  void _onResend() {
    if (!_canResend) return;
    _otpKey.currentState?.clear();
    setState(() => _code = '');
    _cubit.resendOtp(widget.tempToken);
    _startTimer();
  }

  void _onVerifyPressed() {
    if (_code.length != 6) return;
    _cubit.verifyRegistrationOtp(code: _code, tempToken: widget.tempToken);
  }

  @override
  Widget build(BuildContext context) {
    final title = _isPhone ? 'Verify Your Phone Number' : 'Verify Your Email';
    final viaLabel = _isPhone ? 'SMS' : 'Email';

    return BlocProvider.value(
      value: _cubit,
      child: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.registerVerified) {
            EmergencyAuthApp.trustVerificationCubit.loadMine();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => VerificationSuccessScreen(
                  verificationType: widget.verificationType,
                ),
              ),
            );
          } else if (state.status == AuthStatus.otpResent) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Code resent.')),
            );
          } else if (state.status == AuthStatus.failure &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
        },
        builder: (context, state) {
          final isVerifying = state.status == AuthStatus.loading;
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
                      isLoading: isVerifying,
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
        },
      ),
    );
  }
}
