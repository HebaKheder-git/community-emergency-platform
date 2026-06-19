import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/primary_button.dart';

/// "Help is on the way" success dialog shown after a report is submitted.
/// Matches the green checkmark + re-report cooldown copy from the Figma.
class EmergencySubmittedDialog extends StatelessWidget {
  final VoidCallback onGoHome;

  const EmergencySubmittedDialog({super.key, required this.onGoHome});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 38),
            ),
            const SizedBox(height: 22),
            const Text(
              'Help is on the way.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'You can re-report this emergency after 5 minutes.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textDark,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(Icons.info_outline,
                      size: 16, color: AppColors.textGrey),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'You can re-report the same emergency up to 2 times.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textGrey,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 26),
            PrimaryButton(
              label: 'Go Home',
              onPressed: onGoHome,
            ),
          ],
        ),
      ),
    );
  }
}