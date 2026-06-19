import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// The "----- Or -----" divider followed by Google / Facebook circular
/// buttons, reused on both the sign up and login screens.
class SocialLoginRow extends StatelessWidget {
  final VoidCallback onGooglePressed;
  final VoidCallback onFacebookPressed;

  const SocialLoginRow({
    super.key,
    required this.onGooglePressed,
    required this.onFacebookPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(child: Divider(color: AppColors.borderGrey)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text('Or', style: AppTextStyles.subtitle),
            ),
            const Expanded(child: Divider(color: AppColors.borderGrey)),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _SocialCircle(
              onTap: onGooglePressed,
              backgroundColor: const Color(0xFFF2F2F2),
              child: Image.network(
                'https://www.google.com/favicon.ico',
                width: 22,
                height: 22,
                errorBuilder: (_, __, ___) => const Text(
                  'G',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                ),
              ),
            ),
            const SizedBox(width: 16),
            _SocialCircle(
              onTap: onFacebookPressed,
              backgroundColor: const Color(0xFF1877F2),
              child: const Icon(Icons.facebook, color: Colors.white, size: 24),
            ),
          ],
        ),
      ],
    );
  }
}

class _SocialCircle extends StatelessWidget {
  final VoidCallback onTap;
  final Color backgroundColor;
  final Widget child;

  const _SocialCircle({
    required this.onTap,
    required this.backgroundColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}
