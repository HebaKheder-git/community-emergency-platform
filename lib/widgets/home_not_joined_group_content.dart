// lib/widgets/home_not_joined_group_content.dart

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Body shown on [HomeScreen] when the current user IS verified/trusted but
/// has NOT joined an emergency group yet.
///
/// Mirrors [HomeUnverifiedContent]'s layout (same header: avatar +
/// notification bell + name) but swaps the verification notice for a
/// "join a group to continue" prompt with a "Search for Emergency Group"
/// button — since the SOS button (and chat) both require the user to
/// belong to a home group first.
class HomeNotJoinedGroupContent extends StatelessWidget {
  final String userName;
  final bool hasUnreadNotifications;
  final VoidCallback onBellTap;
  final VoidCallback onSearchForGroupPressed;

  const HomeNotJoinedGroupContent({
    super.key,
    required this.userName,
    required this.onBellTap,
    required this.onSearchForGroupPressed,
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
            // ── Header (avatar + bell + name) — same as HomeUnverifiedContent ──
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

            const SizedBox(height: 24),

            // ── "Join a group" notice + Search button ───────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 28,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.groups_outlined,
                      color: AppColors.primaryRed,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Join Your Emergency Group',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'The SOS button and community chat unlock once you '
                      'join the emergency group for your area. Search for '
                      'one nearby to get started.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textGrey,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: GestureDetector(
                        onTap: onSearchForGroupPressed,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: AppColors.primaryRed,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_rounded, color: Colors.white),
                              SizedBox(width: 10),
                              Text(
                                'Search for Emergency Group',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}