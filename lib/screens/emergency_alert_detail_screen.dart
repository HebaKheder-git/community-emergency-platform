import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/emergency_alert.dart';

/// "Road Accident" detail screen — opened by tapping "View" on a card in
/// [NotificationsScreen]. Shows the location, a (mocked) map preview,
/// description, severity/volunteer count, and the Yes/No volunteer
/// decision, each of which opens its own confirmation dialog
/// ([_VolunteerConfirmDialog] / [_DeclineConfirmDialog]).
class EmergencyAlertDetailScreen extends StatefulWidget {
  final EmergencyAlert alert;

  const EmergencyAlertDetailScreen({super.key, required this.alert});

  @override
  State<EmergencyAlertDetailScreen> createState() =>
      _EmergencyAlertDetailScreenState();
}

class _EmergencyAlertDetailScreenState
    extends State<EmergencyAlertDetailScreen> {
  Future<void> _showVolunteerConfirm() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.45),
      builder: (_) => const _ConfirmDialog(
        icon: Icons.question_mark_rounded,
        title: 'Are you SURE you want to\nvolunteer?',
        message:
            'This means you are going to the emrgency location immediately .',
        primaryLabel: 'I volunteer to help',
        primaryIsRed: true,
        secondaryLabel: 'Go back',
        secondaryIsRed: false,
      ),
    );

    if (confirmed == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thank you — help is on the way!')),
      );
      // TODO: call backend / Qubit to register volunteer commitment.
    }
  }

  Future<void> _showDeclineConfirm() async {
    final confirmedDecline = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.45),
      builder: (_) => const _ConfirmDialog(
        icon: Icons.question_mark_rounded,
        title: 'Are you SURE you do NOT\nwant to help?',
        message: null,
        primaryLabel: "I'm Sorry, I can't help",
        primaryIsRed: false,
        secondaryLabel: 'Go back',
        secondaryIsRed: true,
      ),
    );

    if (confirmedDecline == true && mounted) {
      Navigator.of(context).maybePop();
      // TODO: call backend / Qubit to register decline.
    }
  }

  @override
  Widget build(BuildContext context) {
    final alert = widget.alert;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark, size: 26),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          alert.title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Alert icon
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: AppColors.primaryRed,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(height: 14),

              // Location row
              Row(
                children: [
                  const Icon(Icons.location_on_outlined,
                      size: 18, color: AppColors.textDark),
                  const SizedBox(width: 6),
                  Text(
                    alert.locationLabel,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Map preview (mocked — swap for google_maps_flutter later)
              _MapPreview(onTrackLocation: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tracking your location…')),
                );
                // TODO: hook into real geolocation once available.
              }),
              const SizedBox(height: 24),

              // Description
              const Text(
                'Description',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                alert.description,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textDark,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 14),

              // Severity | Volunteered
              Row(
                children: [
                  Text(
                    alert.severity,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFE08A2A),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(width: 1.4, height: 16, color: AppColors.textDark),
                  const SizedBox(width: 10),
                  Text(
                    '${alert.volunteerFraction} Volunteered',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFE08A2A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Volunteer prompt
              const Text(
                'Would you volunteer to help imeediately ?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryRed,
                ),
              ),
              const SizedBox(height: 18),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _showVolunteerConfirm,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                            color: AppColors.primaryRed, width: 1.6),
                        backgroundColor: const Color(0xFFFCE9E7),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: const Text(
                        'Yes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryRed,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _showDeclineConfirm,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                            color: AppColors.borderGrey, width: 1.6),
                        backgroundColor: const Color(0xFFE3E3E3),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: const Text(
                        'No',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Map preview
// ════════════════════════════════════════════════════════════════════════════

class _MapPreview extends StatelessWidget {
  final VoidCallback onTrackLocation;

  const _MapPreview({required this.onTrackLocation});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        height: 200,
        width: double.infinity,
        child: Stack(
          children: [
            // Static mock "map" background. Replace with a real
            // GoogleMap widget (google_maps_flutter) once API keys
            // and Qubit-backed geolocation are wired up.
            Container(color: const Color(0xFFE5E5E0)),
            CustomPaint(
              size: Size.infinite,
              painter: _MockMapPainter(),
            ),
            const Positioned(
              top: 14,
              right: 60,
              child: Icon(Icons.restaurant, color: Color(0xFFE08A2A), size: 26),
            ),
            Positioned(
              top: 70,
              left: 0,
              right: 0,
              child: Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'You are here',
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                    const Icon(Icons.location_on,
                        color: Colors.black, size: 26),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 14,
              right: 14,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: onTrackLocation,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.gps_fixed,
                            size: 16, color: AppColors.primaryRed),
                        SizedBox(width: 6),
                        Text(
                          'Track my location',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryRed,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Cheap hand-drawn "roads" so the map preview doesn't look like a flat
/// grey rectangle while there's no real maps SDK wired in yet.
class _MockMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = const Color(0xFFF2D98A)
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(size.width * 0.15, 0),
      Offset(size.width * 0.55, size.height),
      roadPaint,
    );

    final waterPaint = Paint()..color = const Color(0xFFB9D6E0);
    canvas.drawCircle(Offset(0, size.height * 0.2), 60, waterPaint);
    canvas.drawCircle(
        Offset(size.width * 0.05, size.height * 0.85), 40, waterPaint);

    final greenPaint = Paint()..color = const Color(0xFFCBE3C2);
    canvas.drawCircle(
        Offset(size.width * 0.62, size.height * 0.45), 50, greenPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ════════════════════════════════════════════════════════════════════════════
// Shared confirm dialog (Images 3 & 4)
// ════════════════════════════════════════════════════════════════════════════

class _ConfirmDialog extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final String primaryLabel;
  final bool primaryIsRed;
  final String secondaryLabel;
  final bool secondaryIsRed;

  const _ConfirmDialog({
    required this.icon,
    required this.title,
    required this.message,
    required this.primaryLabel,
    required this.primaryIsRed,
    required this.secondaryLabel,
    required this.secondaryIsRed,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.background,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: const BoxDecoration(
                color: Color(0xFFF6C2BC),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 40, color: AppColors.primaryRed),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
                height: 1.3,
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: 12),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textDark,
                  height: 1.45,
                ),
              ),
            ],
            const SizedBox(height: 24),

            // Primary action — returns true
            _DialogButton(
              label: primaryLabel,
              isRed: primaryIsRed,
              onTap: () => Navigator.of(context).pop(true),
            ),
            const SizedBox(height: 12),

            // Secondary action ("Go back") — returns false
            _DialogButton(
              label: secondaryLabel,
              isRed: secondaryIsRed,
              onTap: () => Navigator.of(context).pop(false),
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogButton extends StatelessWidget {
  final String label;
  final bool isRed;
  final VoidCallback onTap;

  const _DialogButton({
    required this.label,
    required this.isRed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isRed ? AppColors.primaryRed : const Color(0xFFD9D9D9),
          foregroundColor: isRed ? Colors.white : AppColors.textDark,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}