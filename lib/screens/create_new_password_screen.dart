// EDITED — wired to POST /auth/password/reset.
//
// Now takes the PasswordResetCubit handed off by
// ResetPasswordEmailOtpScreen (it already holds the verified temp_token —
// no need to pass tokens through constructors a second time). This screen
// owns closing that cubit once it's done with it.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/password_reset/password_reset_cubit.dart';
import '../cubits/password_reset/password_reset_state.dart';
import '../theme/app_theme.dart';
import '../widgets/primary_button.dart';
import 'password_reset_success_screen.dart';

class CreateNewPasswordScreen extends StatefulWidget {
  final PasswordResetCubit passwordResetCubit;

  const CreateNewPasswordScreen({super.key, required this.passwordResetCubit});

  @override
  State<CreateNewPasswordScreen> createState() =>
      _CreateNewPasswordScreenState();
}

class _CreateNewPasswordScreenState extends State<CreateNewPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    widget.passwordResetCubit.close();
    super.dispose();
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter a new password';
    if (value.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value != _passwordController.text) return 'Passwords do not match';
    return null;
  }

  void _onResetPressed(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    widget.passwordResetCubit.resetPassword(
      password: _passwordController.text,
      passwordConfirmation: _confirmPasswordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.passwordResetCubit,
      child: BlocConsumer<PasswordResetCubit, PasswordResetState>(
        listener: (context, state) {
          if (state.status == PasswordResetStatus.completed) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const PasswordResetSuccessScreen()),
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
                        'Create New Password',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Enter your new password below.',
                        style: AppTextStyles.subtitle,
                      ),
                      const SizedBox(height: 36),
                      const Text('New Password', style: AppTextStyles.fieldLabel),
                      const SizedBox(height: AppSpacing.smallGap),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: AppTextStyles.inputText,
                        validator: _validatePassword,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          hintStyle: AppTextStyles.hint,
                          prefixIcon: const Padding(
                            padding: EdgeInsets.only(left: 16, right: 12),
                            child: Icon(
                              Icons.lock_outline,
                              color: AppColors.hintGrey,
                              size: 22,
                            ),
                          ),
                          prefixIconConstraints:
                              const BoxConstraints(minWidth: 0, minHeight: 0),
                          suffixIcon: Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _obscurePassword = !_obscurePassword),
                              child: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: AppColors.hintGrey,
                                size: 22,
                              ),
                            ),
                          ),
                          suffixIconConstraints:
                              const BoxConstraints(minWidth: 0, minHeight: 0),
                          filled: true,
                          fillColor: AppColors.background,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                            borderSide: const BorderSide(color: AppColors.borderGrey),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                            borderSide: const BorderSide(color: AppColors.borderGrey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                            borderSide:
                                const BorderSide(color: AppColors.primaryRed, width: 1.5),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                            borderSide: const BorderSide(color: Colors.red),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                            borderSide: const BorderSide(color: Colors.red, width: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.fieldGap),
                      const Text('Confirm Password', style: AppTextStyles.fieldLabel),
                      const SizedBox(height: AppSpacing.smallGap),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscurePassword,
                        style: AppTextStyles.inputText,
                        validator: _validateConfirmPassword,
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          hintStyle: AppTextStyles.hint,
                          prefixIcon: const Padding(
                            padding: EdgeInsets.only(left: 16, right: 12),
                            child: Icon(
                              Icons.lock_outline,
                              color: AppColors.hintGrey,
                              size: 22,
                            ),
                          ),
                          prefixIconConstraints:
                              const BoxConstraints(minWidth: 0, minHeight: 0),
                          filled: true,
                          fillColor: AppColors.background,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                            borderSide: const BorderSide(color: AppColors.borderGrey),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                            borderSide: const BorderSide(color: AppColors.borderGrey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                            borderSide:
                                const BorderSide(color: AppColors.primaryRed, width: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Padding(
                        padding: EdgeInsets.only(left: 4),
                        child: Text(
                          'At least 8 characters',
                          style: TextStyle(fontSize: 13, color: AppColors.hintGrey),
                        ),
                      ),
                      const SizedBox(height: 40),
                      PrimaryButton(
                        label: 'Reset Password',
                        isLoading: isLoading,
                        onPressed: () => _onResetPressed(context),
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
