// lib/widgets/verification_prompt_card.dart
//
// EDITED — now self-contained: creates its own [TrustVerificationCubit],
// loads GET /trust-verification/me on mount, and swaps its copy/button
// based on the real status instead of always showing the "start" variant.
// The `none` case is pixel-identical to the original card, which is why
// this is a drop-in replacement — nothing needs to change in whatever
// screens render this widget (UnverifiedAccessNotice, EditProfileScreen's
// unverified variant, etc.); they keep doing `const VerificationPromptCard()`
// exactly as before.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../theme/app_theme.dart';
import '../cubits/trust_verification/trust_verification_cubit.dart';
import '../cubits/trust_verification/trust_verification_state.dart';
import '../models/trust_verification.dart';
import 'primary_button.dart';
import '../screens/account_verification_intro_screen.dart';
import '../screens/verification_step1_personal_info_screen.dart';

class VerificationPromptCard extends StatelessWidget {
  const VerificationPromptCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TrustVerificationCubit, TrustVerificationState>(
        builder: (context, state) {
          // Fully verified — nothing left to nudge the user about.
          if (state.data.isApproved) return const SizedBox.shrink();

          switch (state.data.status) {
            case TrustVerificationStatus.pending:
              return _buildCard(
                context,
                title: 'Your verification is under review',
                subtitle: 'You can still edit your submitted details\n'
                    'while this is pending.',
                buttonLabel: 'Edit Verification',
                isEditing: true,
              );
            case TrustVerificationStatus.rejected:
              return _buildCard(
                context,
                title: 'Your verification was rejected',
                subtitle: state.data.rejectionReason != null
                    ? 'Reason: ${state.data.rejectionReason}\n'
                        'You can edit your details and resubmit.'
                    : 'You can edit your details and resubmit.',
                buttonLabel: 'Resubmit Verification',
                isEditing: true,
              );
            case TrustVerificationStatus.none:
            case TrustVerificationStatus.approved:
              return _buildCard(
                context,
                title: "Let's get your account verified!",
                subtitle: 'verified accounts get full access to\n'
                    'all platform features.',
                buttonLabel: 'Start Verification',
                isEditing: false,
              );
          }
        },
      );
  }

  Widget _buildCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String buttonLabel,
    required bool isEditing,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 26,
              height: 26,
              margin: const EdgeInsets.only(top: 2),
              decoration: const BoxDecoration(
                color: AppColors.primaryRed,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.star, color: Colors.white, size: 15),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.linkRed.copyWith(fontSize: 17),
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: AppTextStyles.subtitle),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: 200,
          child: PrimaryButton(
            label: buttonLabel,
            onPressed: () {
              if (isEditing) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const VerificationStep1PersonalInfoScreen(
                      isEditing: true,
                    ),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AccountVerificationIntroScreen(),
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }
}