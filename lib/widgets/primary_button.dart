import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// The full-width pill button used for Sign up / Login / Verify.
/// Automatically dims to the light-pink disabled color seen in the OTP
/// screens when [enabled] is false, and shows a spinner when [isLoading].
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool enabled;
  final bool isLoading;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.enabled = true,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool active = enabled && !isLoading;
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: active ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryRed,
          disabledBackgroundColor: AppColors.disabledRed,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(label, style: AppTextStyles.buttonText),
      ),
    );
  }
}