import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_nav_bar.dart';
import 'report_emergency_screen.dart';
import 'notifications_screen.dart';

// ════════════════════════════════════════════════════════════════════════════
// HomeScreen — Emergency Request (SOS) Screen
//
// Entry point after:
//  • "Go to Home" is tapped in VerificationPendingScreen, OR
//  • The user opens the app and is already signed-in / logged-in.
//
// Features:
//  • User avatar + name in header
//  • Notification bell with badge
//  • Large SOS button with pulse-ring animation on press/hold
//  • "Available for emergency alert" toggle
//  • Bottom navigation bar (Home | Chat | Marketplaces | Service Providers | Settings)
// ════════════════════════════════════════════════════════════════════════════

class HomeScreen extends StatefulWidget {
  /// Pass the logged-in user's display name; falls back to 'User'.
  final String userName;

  const HomeScreen({super.key, this.userName = 'Heba Kheder'});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  // ── State ──────────────────────────────────────────────────────────────────
  int _selectedNavIndex = 0; // 0 = Home (active)
  bool _availableForAlert = true; // toggle default ON
  bool _isSosPressing = false; // tracks long-press / tap-down

  // Pulse animation
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  // ── Lifecycle ──────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..addStatusListener((status) {
        // If SOS is still being held, keep looping; otherwise stop.
        if (status == AnimationStatus.completed) {
          if (_isSosPressing) {
            _pulseController.forward(from: 0);
          } else {
            _pulseController.reset();
          }
        }
      });

    _pulseAnim = Tween<double>(begin: 1.0, end: 1.45).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  void _onSosPressed() {
    setState(() => _isSosPressing = false);
    _pulseController.stop();
    _pulseController.reset();

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ReportEmergencyScreen()),
    );
}

  void _startPulse() {
    setState(() => _isSosPressing = true);
    _pulseController.forward(from: 0);
  }

  void _stopPulse() {
    setState(() => _isSosPressing = false);
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header ───────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.borderGrey,
                        width: 1.5,
                      ),
                    ),
                    child: const CircleAvatar(
                      backgroundColor: Color(0xFFEDEDED),
                      child: Icon(
                        Icons.person_outline,
                        color: AppColors.textDark,
                        size: 28,
                      ),
                    ),
                  ),
                  const Spacer(),

                  // Notification bell with red dot
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                      );
                    },
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Icon(
                          Icons.notifications_none_rounded,
                          size: 30,
                          color: AppColors.textDark,
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            width: 10,
                            height: 10,
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
            ),

            // ── User name ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: Text(
                widget.userName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
            ),

            // ── Instruction text ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
              child: RichText(
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textGrey,
                    height: 1.6,
                  ),
                  children: [
                    TextSpan(text: 'Help is just a click away!\nClick '),
                    TextSpan(
                      text: 'SOS button',
                      style: TextStyle(
                        color: AppColors.primaryRed,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextSpan(text: ' to call the help.'),
                  ],
                ),
              ),
            ),

            // ── SOS Button (center, with pulse) ──────────────────────────────
            Expanded(
              child: Center(
                child: GestureDetector(
                  onTapDown: (_) => _startPulse(),
                  onTapUp: (_) {
                    _stopPulse();
                    _onSosPressed();
                  },
                  onTapCancel: _stopPulse,
                  child: AnimatedBuilder(
                    animation: _pulseAnim,
                    builder: (context, child) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer pulse ring 3
                          if (_isSosPressing)
                            _PulseRing(
                              scale: _pulseAnim.value * 1.15,
                              opacity: (1 - _pulseController.value) * 0.12,
                              size: 230,
                            ),
                          // Outer pulse ring 2
                          if (_isSosPressing)
                            _PulseRing(
                              scale: _pulseAnim.value * 1.08,
                              opacity: (1 - _pulseController.value) * 0.18,
                              size: 230,
                            ),
                          // Inner pulse ring 1
                          if (_isSosPressing)
                            _PulseRing(
                              scale: _pulseAnim.value,
                              opacity: (1 - _pulseController.value) * 0.28,
                              size: 230,
                            ),

                          // SOS circle button
                          Container(
                            width: 230,
                            height: 230,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primaryRed,
                              boxShadow: _isSosPressing
                                  ? [
                                      BoxShadow(
                                        color: AppColors.primaryRed
                                            .withOpacity(0.35),
                                        blurRadius: 24,
                                        spreadRadius: 8,
                                      )
                                    ]
                                  : [],
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              'SOS',
                              style: TextStyle(
                                fontSize: 44,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 4,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),

            // ── Available for emergency alert toggle ─────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Available for emergency alert',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    Transform.scale(
                      scale: 1.1,
                      child: Switch(
                        value: _availableForAlert,
                        onChanged: (val) =>
                            setState(() => _availableForAlert = val),
                        activeColor: Colors.white,
                        activeTrackColor: AppColors.primaryRed,
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor: AppColors.borderGrey,
                        thumbColor: WidgetStateProperty.all(Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // ── Bottom Navigation Bar ─────────────────────────────────────────────
      bottomNavigationBar: SoteriaBottomNav(
        selectedIndex: _selectedNavIndex,
        onTap: (index) => setState(() => _selectedNavIndex = index),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Pulse Ring widget
// ════════════════════════════════════════════════════════════════════════════

class _PulseRing extends StatelessWidget {
  final double scale;
  final double opacity;
  final double size;

  const _PulseRing({
    required this.scale,
    required this.opacity,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primaryRed.withOpacity(opacity.clamp(0.0, 1.0)),
        ),
      ),
    );
  }
}