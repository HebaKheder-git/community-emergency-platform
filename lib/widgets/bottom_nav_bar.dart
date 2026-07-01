// lib/widgets/bottom_nav_bar.dart
// UPDATED — added [chatHasUnread] parameter so the red dot above "Chat"
// only appears when there are new messages from others (not always on).

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Soteria bottom navigation bar.
/// Extracted from HomeScreen so it can be reused across screens.
///
/// [chatHasUnread] — set to `true` from the parent when there are unread
/// messages from other participants; set to `false` when the user is
/// actively viewing the chat (or has no unread messages).
class SoteriaBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  /// Controls whether the red dot badge appears above the Chat icon.
  /// Pass `false` when the user is on the chat screen itself.
  final bool chatHasUnread;

  const SoteriaBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onTap,
    this.chatHasUnread = false,
  });

  @override
  Widget build(BuildContext context) {
    const items = [
      _NavItem(icon: Icons.home_rounded, label: 'Home'),
      _NavItem(icon: Icons.chat_bubble_outline_rounded, label: 'Chat'),
      _NavItem(icon: Icons.storefront_outlined, label: 'Marketplaces'),
      _NavItem(
          icon: Icons.health_and_safety_outlined,
          label: 'Service providers'),
      _NavItem(icon: Icons.settings_outlined, label: 'Settings'),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final isSelected = i == selectedIndex;
              final item = items[i];

              // Show the badge dot only on the Chat tab (index 1)
              // AND only when chatHasUnread is true.
              final showBadge = i == 1 && chatHasUnread;

              return GestureDetector(
                onTap: () => onTap(i),
                behavior: HitTestBehavior.opaque,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(
                          item.icon,
                          size: 26,
                          color: isSelected
                              ? AppColors.primaryRed
                              : AppColors.textGrey,
                        ),
                        if (showBadge)
                          Positioned(
                            top: 0,
                            right: -2,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.primaryRed,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: isSelected
                            ? AppColors.primaryRed
                            : AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}