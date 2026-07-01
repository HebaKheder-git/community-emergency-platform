// lib/screens/settings_screen.dart
//
// Settings screen — shown when "Settings" is tapped in the bottom nav.
// Four sections: Account, Support & About, App settings, Actions.
// Fully scrollable, matching the Figma design exactly.
//
// Dialogs:
//  • _AnonymousMemberDialog — toggle with warning copy (from Figma)
//  • _AllowRatingDialog     — toggle with explanation copy (designed to match)

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_nav_bar.dart';
import 'edit_profile_screen.dart';
import 'reset_password_email_otp_screen.dart';
import 'reset_password_phone_screen.dart';

class SettingsScreen extends StatefulWidget {
  final int selectedNavIndex;
  final ValueChanged<int> onNavTap;

  const SettingsScreen({
    super.key,
    required this.selectedNavIndex,
    required this.onNavTap,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // ── Account toggles ────────────────────────────────────────────────────────
  bool _isAnonymous = false;
  bool _allowRating = true;

  //    to sign up (wire this to your Qubit user model when ready):
  // TODO: replace with actual value from user model / Qubit state.
  // true  → user signed up with email   → send OTP to email
  // false → user signed up with phone   → collect phone then send OTP
  bool _userSignedUpWithEmail = true;
  String _userEmail = 'sample23@gmail.com';
  // ── App settings ───────────────────────────────────────────────────────────
  bool _isDarkTheme = false;
  String _selectedLanguage = 'English';

  // ── Dialogs ────────────────────────────────────────────────────────────────

  /// Shows the Anonymous Member dialog (matches Figma exactly).
  /// The toggle lives inside the dialog so changes are reflected immediately.
  void _showAnonymousDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (ctx) => _AnonymousMemberDialog(
        initialValue: _isAnonymous,
        onChanged: (val) => setState(() => _isAnonymous = val),
      ),
    );
  }

  /// Shows the Allow Account Rating dialog — same visual style as Anonymous.
  void _showRatingDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (ctx) => _AllowRatingDialog(
        initialValue: _allowRating,
        onChanged: (val) => setState(() => _allowRating = val),
      ),
    );
  }

  /// Simple confirmation dialog for destructive actions (Log out, Delete).
  Future<bool> _showConfirmDialog({
    required String title,
    required String message,
    required String confirmLabel,
    Color confirmColor = AppColors.primaryRed,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(color: AppColors.textGrey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textGrey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              confirmLabel,
              style: TextStyle(
                color: confirmColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Language picker bottom sheet.
  void _showLanguagePicker() {
    const languages = ['English', 'Arabic', 'French', 'Turkish', 'German'];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderGrey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'App language',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            ...languages.map(
              (lang) => ListTile(
                title: Text(lang),
                trailing: _selectedLanguage == lang
                    ? const Icon(Icons.check, color: AppColors.primaryRed)
                    : null,
                onTap: () {
                  setState(() => _selectedLanguage = lang);
                  Navigator.pop(ctx);
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      body: SafeArea(
        child: Column(
          children: [
            // ── Title ───────────────────────────────────────────────────────
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 20, 24, 16),
              child: Center(
                child: Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
              ),
            ),

            // ── Scrollable body ─────────────────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                children: [

                  // ── ACCOUNT ───────────────────────────────────────────────
                  _SectionHeader(
                    label: 'Account',
                    badge: Container(
                      width: 22,
                      height: 22,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryRed,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.star,
                        color: Colors.white,
                        size: 13,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _SettingsCard(
                    items: [
                      _SettingsTile(
                        icon: Icons.person_outline_rounded,
                        label: 'Edit profile',
                        onTap: () {
                         Navigator.push(
                           context,
                           MaterialPageRoute(
                             builder: (_) => const EditProfileScreen(),
                           ),
                         );
                       },
                      ),
                      _SettingsTile(
                        icon: Icons.security_outlined,
                        label: 'Reset password',
                        onTap: () {
                          if (_userSignedUpWithEmail) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ResetPasswordEmailOtpScreen(
                                  email: ResetPasswordEmailOtpScreen.maskEmail(_userEmail),
                                ),
                              ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ResetPasswordPhoneScreen(),
                              ),
                            );
                          }
                        },
                      ),
                      _SettingsTile(
                        icon: Icons.notifications_none_rounded,
                        label: 'Change permanent residence place',
                        onTap: () { 
                          // TODO: navigate to ResidencePickerScreen
                        },
                      ),
                      // Anonymous member — shows toggle dialog
                      _SettingsTile(
                        icon: Icons.lock_outline_rounded,
                        label: 'Anonymous member',
                        trailing: _isAnonymous
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryRed.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'ON',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryRed,
                                  ),
                                ),
                              )
                            : null,
                        onTap: _showAnonymousDialog,
                      ),
                      // Allow account rating — shows toggle dialog
                      _SettingsTile(
                        icon: Icons.star_border_rounded,
                        label: 'Allow account rating',
                        trailing: !_allowRating
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.textGrey.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'OFF',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textGrey,
                                  ),
                                ),
                              )
                            : null,
                        onTap: _showRatingDialog,
                        showDivider: false,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ── SUPPORT & ABOUT ───────────────────────────────────────
                  const _SectionHeader(label: 'Support & About'),
                  const SizedBox(height: 8),
                  _SettingsCard(
                    items: [
                      _SettingsTile(
                        icon: Icons.help_outline_rounded,
                        label: 'Help & Support',
                        onTap: () {
                          // TODO: navigate to HelpScreen
                        },
                      ),
                      _SettingsTile(
                        icon: Icons.info_outline_rounded,
                        label: 'Terms and Policies',
                        onTap: () {
                          // TODO: navigate to TermsScreen
                        },
                      ),
                      _SettingsTile(
                        icon: Icons.language_rounded,
                        label: 'Visit our Website',
                        onTap: () {
                          // TODO: launch URL
                        },
                        showDivider: false,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ── APP SETTINGS ──────────────────────────────────────────
                  const _SectionHeader(label: 'App settings'),
                  const SizedBox(height: 8),
                  _SettingsCard(
                    items: [
                      _SettingsTile(
                        icon: Icons.dark_mode_outlined,
                        label: 'Light theme/ Dark theme',
                        trailing: Switch(
                          value: _isDarkTheme,
                          onChanged: (val) =>
                              setState(() => _isDarkTheme = val),
                          activeColor: Colors.white,
                          activeTrackColor: AppColors.primaryRed,
                          inactiveThumbColor: Colors.white,
                          inactiveTrackColor: AppColors.borderGrey,
                          thumbColor: WidgetStateProperty.all(Colors.white),
                        ),
                        onTap: () =>
                            setState(() => _isDarkTheme = !_isDarkTheme),
                      ),
                      _SettingsTile(
                        icon: Icons.translate_rounded,
                        label: 'App language',
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _selectedLanguage,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textGrey,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: AppColors.textGrey,
                              size: 20,
                            ),
                          ],
                        ),
                        onTap: _showLanguagePicker,
                        showDivider: false,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ── ACTIONS ───────────────────────────────────────────────
                  const _SectionHeader(label: 'Actions'),
                  const SizedBox(height: 8),
                  _SettingsCard(
                    items: [
                      _SettingsTile(
                        icon: Icons.flag_outlined,
                        label: 'Report a problem',
                        onTap: () {
                          // TODO: navigate to ReportProblemScreen
                        },
                      ),
                      _SettingsTile(
                        icon: Icons.theater_comedy_outlined,
                        label: 'Apply for a role',
                        onTap: () {
                          // TODO: navigate to ApplyRoleScreen
                        },
                      ),
                      _SettingsTile(
                        icon: Icons.group_remove_outlined,
                        label: 'Delete account',
                        labelColor: AppColors.primaryRed,
                        onTap: () async {
                          final confirmed = await _showConfirmDialog(
                            title: 'Delete account',
                            message:
                                'This action is permanent and cannot be undone. '
                                'All your data will be removed.',
                            confirmLabel: 'Delete',
                          );
                          if (confirmed) {
                            // TODO: call delete account API
                          }
                        },
                      ),
                      _SettingsTile(
                        icon: Icons.logout_rounded,
                        label: 'Log out',
                        labelColor: AppColors.primaryRed,
                        onTap: () async {
                          final confirmed = await _showConfirmDialog(
                            title: 'Log out',
                            message: 'Are you sure you want to log out?',
                            confirmLabel: 'Log out',
                          );
                          if (confirmed) {
                            // TODO: clear session and navigate to LoginScreen
                          }
                        },
                        showDivider: false,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: SoteriaBottomNav(
        selectedIndex: widget.selectedNavIndex,
        onTap: widget.onNavTap,
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Anonymous Member Dialog  (matches Figma)
// ════════════════════════════════════════════════════════════════════════════

class _AnonymousMemberDialog extends StatefulWidget {
  final bool initialValue;
  final ValueChanged<bool> onChanged;

  const _AnonymousMemberDialog({
    required this.initialValue,
    required this.onChanged,
  });

  @override
  State<_AnonymousMemberDialog> createState() =>
      _AnonymousMemberDialogState();
}

class _AnonymousMemberDialogState extends State<_AnonymousMemberDialog> {
  late bool _enabled;

  @override
  void initState() {
    super.initState();
    _enabled = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Headline ────────────────────────────────────────────────────
            const Text(
              'Enabling the Anonymous Member\noption allows you to hide your name\nand date of birth',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 28),

            // ── Toggle row ──────────────────────────────────────────────────
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Enable Anonymous Member',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  Switch(
                    value: _enabled,
                    onChanged: (val) {
                      setState(() => _enabled = val);
                      widget.onChanged(val);
                    },
                    activeColor: Colors.white,
                    activeTrackColor: AppColors.primaryRed,
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: AppColors.borderGrey,
                    thumbColor: WidgetStateProperty.all(Colors.white),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Warning footnote ────────────────────────────────────────────
            const Text(
              'Turning this on may lower user credibility. Reported '
              'emergencies will not be treated with the same '
              'seriousness or urgency as a named user',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textGrey,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Allow Account Rating Dialog  (designed to match Anonymous dialog style)
// ════════════════════════════════════════════════════════════════════════════

class _AllowRatingDialog extends StatefulWidget {
  final bool initialValue;
  final ValueChanged<bool> onChanged;

  const _AllowRatingDialog({
    required this.initialValue,
    required this.onChanged,
  });

  @override
  State<_AllowRatingDialog> createState() => _AllowRatingDialogState();
}

class _AllowRatingDialogState extends State<_AllowRatingDialog> {
  late bool _enabled;

  @override
  void initState() {
    super.initState();
    _enabled = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Headline ────────────────────────────────────────────────────
            const Text(
              'Allow other community members\nto rate your account based on\nyour activity and helpfulness',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 28),

            // ── Toggle row ──────────────────────────────────────────────────
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Allow account rating',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  Switch(
                    value: _enabled,
                    onChanged: (val) {
                      setState(() => _enabled = val);
                      widget.onChanged(val);
                    },
                    activeColor: Colors.white,
                    activeTrackColor: AppColors.primaryRed,
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: AppColors.borderGrey,
                    thumbColor: WidgetStateProperty.all(Colors.white),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Info footnote ───────────────────────────────────────────────
            const Text(
              'Your rating is visible to other users and reflects '
              'how the community perceives your contributions '
              'during emergency situations',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textGrey,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Shared private helpers
// ════════════════════════════════════════════════════════════════════════════

class _SectionHeader extends StatelessWidget {
  final String label;
  final Widget? badge;

  const _SectionHeader({required this.label, this.badge});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        if (badge != null) ...[
          const SizedBox(width: 6),
          badge!,
        ],
      ],
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<_SettingsTile> items;

  const _SettingsCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE8E8E8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: items),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? labelColor;
  final VoidCallback onTap;
  final Widget? trailing;
  final bool showDivider;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.labelColor,
    this.trailing,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Icon(icon, size: 24, color: AppColors.textDark),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: labelColor ?? AppColors.textDark,
                    ),
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Divider(
              height: 1,
              thickness: 1,
              color: AppColors.borderGrey.withOpacity(0.6),
            ),
          ),
      ],
    );
  }
}