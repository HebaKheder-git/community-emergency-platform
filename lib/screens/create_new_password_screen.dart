// lib/screens/create_new_password_screen.dart
//
// Step 2 of the Reset Password flow — shown after OTP is verified.
// User enters a new password (min 8 chars, with toggle visibility).
// "Reset Password" navigates to PasswordResetSuccessScreen.

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/primary_button.dart';
import 'password_reset_success_screen.dart';

class CreateNewPasswordScreen extends StatefulWidget {
  const CreateNewPasswordScreen({super.key});

  @override
  State<CreateNewPasswordScreen> createState() =>
      _CreateNewPasswordScreenState();
}

class _CreateNewPasswordScreenState extends State<CreateNewPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter a new password';
    if (value.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  void _onResetPressed() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // TODO: call backend to update password.
    await Future.delayed(const Duration(milliseconds: 800));

    setState(() => _isLoading = false);
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const PasswordResetSuccessScreen()),
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
          child: Form(
            key: _formKey,
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
                  'Create New Password',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),

                const SizedBox(height: 10),

                // ── Subtitle ───────────────────────────────────────────────
                const Text(
                  'Enter your new password below.',
                  style: AppTextStyles.subtitle,
                ),

                const SizedBox(height: 36),

                // ── New Password label ─────────────────────────────────────
                const Text('New Password', style: AppTextStyles.fieldLabel),
                const SizedBox(height: AppSpacing.smallGap),

                // ── Password field (custom, with visibility toggle) ─────────
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
                      borderSide:
                          const BorderSide(color: AppColors.borderGrey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                      borderSide:
                          const BorderSide(color: AppColors.borderGrey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                      borderSide: const BorderSide(
                          color: AppColors.primaryRed, width: 1.5),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                      borderSide: const BorderSide(color: Colors.red),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                      borderSide:
                          const BorderSide(color: Colors.red, width: 1.5),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // ── Helper text ────────────────────────────────────────────
                const Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Text(
                    'At least 8 characters',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.hintGrey,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // ── Reset Password button ──────────────────────────────────
                PrimaryButton(
                  label: 'Reset Password',
                  isLoading: _isLoading,
                  onPressed: _onResetPressed,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}