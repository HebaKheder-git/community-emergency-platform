// lib/widgets/home_unverified_content.dart

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'unverified_access_notice.dart';

/// Body shown on [HomeScreen] when the current user hasn't verified their
/// account yet. Unlike the other locked screens, Home keeps its own
/// header (avatar + notification bell + name) above the shared
/// [UnverifiedAccessNotice] block, matching the Figma "Home" variant.
class HomeUnverifiedContent extends StatelessWidget {
  final String userName;
  final bool hasUnreadNotifications;
  final VoidCallback onBellTap;

  const HomeUnverifiedContent({
    super.key,
    required this.userName,
    required this.onBellTap,
    this.hasUnreadNotifications = true,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Placeholder avatar — swap for the user's real
                      // photo the same way EditProfileScreen does.
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.borderGrey,
                            width: 1.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.person_outline,
                          color: AppColors.textGrey,
                          size: 34,
                        ),
                      ),
                      GestureDetector(
                        onTap: onBellTap,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            const Icon(
                              Icons.notifications_none_rounded,
                              size: 30,
                              color: AppColors.textDark,
                            ),
                            if (hasUnreadNotifications)
                              Positioned(
                                right: -1,
                                top: -1,
                                child: Container(
                                  width: 11,
                                  height: 11,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primaryRed,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    userName,
                    style: AppTextStyles.heading.copyWith(
                      fontSize: 26,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const UnverifiedAccessNotice(),
          ],
        ),
      ),
    );
  }
}