// lib/screens/settings_screen.dart
//
// Settings screen — shown when "Settings" is tapped in the bottom nav.
// Four sections: Account, Support & About, App settings, Actions.
// Fully scrollable, matching the Figma design exactly.
//
// EDITED — see notes near _onLogoutPressed / the "Reset password" tile
// below for what's wired to the backend and why.
//
// Verification-dependent content (driven by VerificationStatus.instance):
//  • Account header  — verified: red star badge · unverified: "!NOT Verified"
//  • Account tiles   — verified: Edit profile, Reset password, Change
//                       permanent residence, Anonymous member, Allow account
//                       rating · unverified: Edit profile, Reset password,
//                       Verify your account
//  • Actions tiles   — verified: Report a problem, Apply for a role, Delete
//                       account, Log out · unverified: Delete account, Log out
//  Support & About and App settings, plus Delete account / Log out inside
//  Actions, are written once and shared byte-for-byte between both states.
//
// NOTE: VerificationStatus is still purely local — the Postman collection
// has no identity-verification endpoints yet, so "verified" here doesn't
// reflect anything the backend knows. Wire it up once those endpoints exist.
//
// Dialogs:
//  • _AnonymousMemberDialog — toggle with warning copy (from Figma)
//  • _AllowRatingDialog     — toggle with explanation copy (designed to match)

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_nav_bar.dart';
import '../services/verification_status.dart';
import '../core/token_storage.dart';
import '../cubits/auth/auth_cubit.dart';
import '../cubits/password_reset/password_reset_cubit.dart';
import '../cubits/password_reset/password_reset_state.dart';
import 'edit_profile_screen.dart';
import 'reset_password_email_otp_screen.dart';
import 'reset_password_phone_screen.dart';
import 'account_verification_intro_screen.dart';
import 'login_screen.dart';
import '../repositories/auth_repository.dart';

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

  // EDITED — there is still no GET /me endpoint, so we can't fetch the real
  // signed-up-with value from the backend. We read back whatever email was
  // cached locally at sign up / login time (see TokenStorage). Since
  // /auth/register is email-only right now, this is effectively always
  // true — kept as a field so it's a one-line change once phone accounts
  // exist on the backend.
  final bool _userSignedUpWithEmail = true;
  String _userEmail = '';
  final _tokenStorage = TokenStorage();

  // ── App settings ───────────────────────────────────────────────────────────
  bool _isDarkTheme = false;
  String _selectedLanguage = 'English';
  final AuthRepository _authRepository = AuthRepository();
  List<String> _roles = [];
  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    // Fast local fallback so the UI isn't blank while the request is in flight.
    final cachedEmail = await _tokenStorage.readEmail();
    if (mounted && cachedEmail != null) {
      setState(() => _userEmail = cachedEmail);
    }

    try {
      final me = await _authRepository.getMe();
      if (!mounted) return;
      setState(() {
        _userEmail = me.email;
        _roles = me.roles;
      });
    } catch (_) {
      // Offline or token issue — keep showing the cached value.
    }
  }

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

  // EDITED — POST /auth/password/forgot needs to run *before* we can show
  // ResetPasswordEmailOtpScreen (it now requires a temp_token). Uses a
  // throwaway PasswordResetCubit just to make that one call.
  Future<void> _onResetPasswordTap() async {
    if (!_userSignedUpWithEmail) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ResetPasswordPhoneScreen()),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final cubit = PasswordResetCubit();
    try {
      await cubit.requestOtp(_userEmail);
      if (!mounted) return;
      Navigator.pop(context); // close the loading dialog

      if (cubit.state.status == PasswordResetStatus.otpSent) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ResetPasswordEmailOtpScreen(
              email: _userEmail,
              tempToken: cubit.state.tempToken!,
            ),
          ),
        );
      } else if (cubit.state.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(cubit.state.errorMessage!)),
        );
      }
    } finally {
      cubit.close();
    }
  }

  // EDITED — wired to POST /auth/logout.
  Future<void> _onLogoutPressed(BuildContext context) async {
    final confirmed = await _showConfirmDialog(
      title: 'Log out',
      message: 'Are you sure you want to log out?',
      confirmLabel: 'Log out',
    );
    if (!confirmed || !mounted) return;

    final authCubit = AuthCubit();
    await authCubit.logout();
    authCubit.close();
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  /// Small red/grey "ON" / "OFF" pill shown next to a toggle-backed tile.
  Widget _pillBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
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
              child: ValueListenableBuilder<bool>(
                valueListenable: VerificationStatus.instance.isVerified,
                builder: (context, isVerified, _) {
                  // ── Account tiles ───────────────────────────────────────
                  // "Edit profile" and "Reset password" are shared — written
                  // once — for both verification states.
                  final accountTiles = <Widget>[
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
                      onTap: _onResetPasswordTap,
                    ),
                    if (isVerified) ...[
                      _SettingsTile(
                        icon: Icons.notifications_none_rounded,
                        label: 'Change permanent residence place',
                        onTap: () {
                          // TODO: navigate to ResidencePickerScreen
                        },
                      ),
                      _SettingsTile(
                        icon: Icons.lock_outline_rounded,
                        label: 'Anonymous member',
                        trailing: _isAnonymous
                            ? _pillBadge('ON', AppColors.primaryRed)
                            : null,
                        onTap: _showAnonymousDialog,
                      ),
                      _SettingsTile(
                        icon: Icons.star_border_rounded,
                        label: 'Allow account rating',
                        trailing: !_allowRating
                            ? _pillBadge('OFF', AppColors.textGrey)
                            : null,
                        onTap: _showRatingDialog,
                        showDivider: false,
                      ),
                    ] else
                      _SettingsTile(
                        icon: Icons.star_border_rounded,
                        label: 'Verify your account',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const AccountVerificationIntroScreen(),
                            ),
                          );
                        },
                        showDivider: false,
                      ),
                  ];

                  // ── Action tiles ────────────────────────────────────────
                  // "Delete account" and "Log out" are shared — written
                  // once — for both verification states.
                  final actionTiles = <Widget>[
                    if (isVerified) ...[
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
                    ],
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
                          // TODO: call delete account API — no such endpoint
                          // in the Postman collection yet.
                        }
                      },
                    ),
                    _SettingsTile(
                      icon: Icons.logout_rounded,
                      label: 'Log out',
                      labelColor: AppColors.primaryRed,
                      onTap: () => _onLogoutPressed(context),
                      showDivider: false,
                    ),
                  ];

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    children: [
                      // ── ACCOUNT ───────────────────────────────────────────
                      _SectionHeader(
                        label: 'Account',
                        badge: isVerified
                            ? Container(
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
                              )
                            : const Text(
                                '!NOT Verified',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primaryRed,
                                ),
                              ),
                      ),
                      const SizedBox(height: 8),
                      _SettingsCard(items: accountTiles),

                      const SizedBox(height: 24),

                      // ── SUPPORT & ABOUT ─────────────────────────────────
                      // SHARED — identical for verified & unverified users.
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

                      // ── APP SETTINGS ────────────────────────────────────
                      // SHARED — identical for verified & unverified users.
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
                              thumbColor:
                                  WidgetStateProperty.all(Colors.white),
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

                      // ── ACTIONS ─────────────────────────────────────────
                      const _SectionHeader(label: 'Actions'),
                      const SizedBox(height: 8),
                      _SettingsCard(items: actionTiles),
                    ],
                  );
                },
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
  final List<Widget> items;

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
