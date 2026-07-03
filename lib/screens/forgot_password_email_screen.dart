// NEW SCREEN — needed because none of the existing screens let an
// unauthenticated user type their email to *start* a password reset;
// ResetPasswordEmailOtpScreen assumes the email is already known (it's
// only reached today from Settings, where the user is already logged in).
// Modeled after reset_password_phone_screen.dart for visual consistency.
//
// Calls POST /auth/password/forgot, then pushes ResetPasswordEmailOtpScreen
// with the temp_token it returns.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/password_reset/password_reset_cubit.dart';
import '../cubits/password_reset/password_reset_state.dart';
import '../theme/app_theme.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/primary_button.dart';
import 'reset_password_email_otp_screen.dart';

class ForgotPasswordEmailScreen extends StatefulWidget {
  const ForgotPasswordEmailScreen({super.key});

  @override
  State<ForgotPasswordEmailScreen> createState() =>
      _ForgotPasswordEmailScreenState();
}

class _ForgotPasswordEmailScreenState extends State<ForgotPasswordEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter your email';
    final emailRegex = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');
    if (!emailRegex.hasMatch(value.trim())) return 'Enter a valid email address';
    return null;
  }

  void _onSendCodePressed(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    context.read<PasswordResetCubit>().requestOtp(_emailController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PasswordResetCubit(),
      child: BlocConsumer<PasswordResetCubit, PasswordResetState>(
        listener: (context, state) {
          if (state.status == PasswordResetStatus.otpSent) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ResetPasswordEmailOtpScreen(
                  email: _emailController.text.trim(),
                  tempToken: state.tempToken!,
                ),
              ),
            );
          } else if (state.status == PasswordResetStatus.failure &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state.status == PasswordResetStatus.loading;
          return Scaffold(
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding,
                ),
                child: Form(
                  key: _formKey,
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
                        'Forgot Password',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Enter your email and we'll send you a code to reset your password.",
                        style: AppTextStyles.subtitle,
                      ),
                      const SizedBox(height: 36),
                      const Text('Email', style: AppTextStyles.fieldLabel),
                      const SizedBox(height: AppSpacing.smallGap),
                      AuthTextField(
                        controller: _emailController,
                        hintText: 'Your email',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: _validateEmail,
                      ),
                      const SizedBox(height: 40),
                      PrimaryButton(
                        label: 'Send Code',
                        isLoading: isLoading,
                        onPressed: () => _onSendCodePressed(context),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}