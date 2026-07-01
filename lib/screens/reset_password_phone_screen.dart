// lib/screens/reset_password_phone_screen.dart
//
// Shown during the Reset Password flow when the user signed up with phone.
// User enters their phone number → taps "Send Code" → navigates to the
// OTP verification screen (ResetPasswordPhoneOtpScreen).

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/primary_button.dart';
import 'reset_password_phone_otp_screen.dart';

class ResetPasswordPhoneScreen extends StatefulWidget {
  const ResetPasswordPhoneScreen({super.key});

  @override
  State<ResetPasswordPhoneScreen> createState() =>
      _ResetPasswordPhoneScreenState();
}

class _ResetPasswordPhoneScreenState extends State<ResetPasswordPhoneScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your phone number';
    }
    final phoneRegex = RegExp(r'^\+?[0-9]{8,15}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  void _onSendCodePressed() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // TODO: call backend to send OTP to phone number.
    await Future.delayed(const Duration(milliseconds: 800));

    setState(() => _isLoading = false);
    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResetPasswordPhoneOtpScreen(
          phoneNumber: _phoneController.text.trim(),
        ),
      ),
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
                  'Enter Your Phone\nNumber',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                    height: 1.25,
                  ),
                ),

                const SizedBox(height: 10),

                // ── Subtitle ───────────────────────────────────────────────
                const Text(
                  "Enter your phone number and we'll send you a code to reset your password.",
                  style: AppTextStyles.subtitle,
                ),

                const SizedBox(height: 36),

                // ── Phone Number label + field ─────────────────────────────
                const Text('Phone Number', style: AppTextStyles.fieldLabel),
                const SizedBox(height: AppSpacing.smallGap),
                AuthTextField(
                  controller: _phoneController,
                  hintText: '+963999999999',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: _validatePhone,
                ),

                const SizedBox(height: 40),

                // ── Send Code button ───────────────────────────────────────
                PrimaryButton(
                  label: 'Send Code',
                  isLoading: _isLoading,
                  onPressed: _onSendCodePressed,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}