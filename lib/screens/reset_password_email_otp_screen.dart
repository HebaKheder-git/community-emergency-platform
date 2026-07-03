// EDITED — wired to POST /auth/password/verify (and /auth/resend).
//
// Now requires `tempToken` (issued by /auth/password/forgot), passed in by
// either ForgotPasswordEmailScreen (unauthenticated flow) or SettingsScreen
// (logged-in "Reset password" tile, which calls forgotPassword itself
// first — see settings_screen.dart notes).
//
// On successful verify, the PasswordResetCubit's temp_token is refreshed
// by the backend response — we forward the *same cubit instance* to
// CreateNewPasswordScreen so it can call resetPassword() with that fresh
// token, instead of re-plumbing tokens through constructors.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/password_reset/password_reset_cubit.dart';
import '../cubits/password_reset/password_reset_state.dart';
import '../theme/app_theme.dart';
import '../widgets/otp_input_boxes.dart';
import '../widgets/primary_button.dart';
import 'create_new_password_screen.dart';

class ResetPasswordEmailOtpScreen extends StatefulWidget {
  final String email;
  final String tempToken;

  const ResetPasswordEmailOtpScreen({
    super.key,
    required this.email,
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
  State<ResetPasswordEmailOtpScreen> createState() =>
      _ResetPasswordEmailOtpScreenState();
}

class _ResetPasswordEmailOtpScreenState
    extends State<ResetPasswordEmailOtpScreen> {
  final _otpKey = GlobalKey<OtpInputBoxesState>();
  late final PasswordResetCubit _cubit;

  String _code = '';
  Timer? _timer;
  int _secondsRemaining = 25;

  bool get _canResend => _secondsRemaining == 0;

  @override
  void initState() {
    super.initState();
    _cubit = PasswordResetCubit(initialTempToken: widget.tempToken);
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
    // NOT closed here — ownership passes to CreateNewPasswordScreen on
    // successful verify (see listener below). If the user backs out
    // without verifying, close it instead:
    if (!_handedOff) _cubit.close();
    super.dispose();
  }

  bool _handedOff = false;

  void _onResend() {
    if (!_canResend) return;
    _otpKey.currentState?.clear();
    setState(() => _code = '');
    _cubit.resendOtp();
    _startTimer();
  }

  void _onVerifyPressed() {
    if (_code.length != 6) return;
    _cubit.verifyOtp(_code);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocConsumer<PasswordResetCubit, PasswordResetState>(
        listener: (context, state) {
          if (state.status == PasswordResetStatus.otpVerified) {
            _handedOff = true;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => CreateNewPasswordScreen(passwordResetCubit: _cubit),
              ),
            );
          } else if (state.status == PasswordResetStatus.otpResent) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Code resent.')),
            );
          } else if (state.status == PasswordResetStatus.failure &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
        },
        builder: (context, state) {
          final isVerifying = state.status == PasswordResetStatus.loading;
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
                      icon: const Icon(
                        Icons.chevron_left,
                        size: 30,
                        color: AppColors.textDark,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Verify Your Email',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "We've sent a 6-digit code to ${widget.email}",
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
                        'Enter the code you received via Email',
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
