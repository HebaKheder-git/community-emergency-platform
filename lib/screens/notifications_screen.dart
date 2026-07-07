import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/emergency_alert.dart';
import 'emergency_alert_detail_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/trust_verification/trust_verification_cubit.dart';
import '../cubits/trust_verification/trust_verification_state.dart';
import '../widgets/unverified_access_notice.dart';

/// "Notifications" screen — opened by tapping the notification bell on
/// [HomeScreen]. Shows a scrollable list of emergency alerts the user has
/// been notified about, each either still "open" (tap View → detail screen)
/// or already "Finished".
class NotificationsScreen extends StatefulWidget {
  /// Pass real data once the backend/Qubit is wired up. Leave null (or
  /// omit) to fall back to [mockEmergencyAlerts] for now.
  final List<EmergencyAlert>? alerts;

  const NotificationsScreen({super.key, this.alerts});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late final List<EmergencyAlert> _alerts =
      widget.alerts ?? mockEmergencyAlerts;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark, size: 26),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        centerTitle: false,
      ),
      body: BlocBuilder<TrustVerificationCubit, TrustVerificationState>(
        builder: (context, state) {
          final verified = state.data.isApproved;
          if (!verified){
            return UnverifiedAccessNotice();}
          return _alerts.isEmpty
          ? const _EmptyNotifications()
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              itemCount: _alerts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final alert = _alerts[index];
                return _NotificationCard(
                  alert: alert,
                  onView: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EmergencyAlertDetailScreen(alert: alert),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final EmergencyAlert alert;
  final VoidCallback onView;

  const _NotificationCard({required this.alert, required this.onView});

  @override
  Widget build(BuildContext context) {
    final isFinished = alert.status == AlertStatus.finished;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            alert.formattedDate,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.hintGrey,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Alert type icon
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: AppColors.primaryRed,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),

              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alert.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      alert.summary,
                      style: const TextStyle(
                        fontSize: 14.5,
                        color: AppColors.textDark,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // "Reported by X, Y/Z volunteered" with highlighted chips
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 14.5,
                          color: AppColors.textDark,
                          height: 1.6,
                        ),
                        children: [
                          const TextSpan(text: 'Reported by '),
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: _HighlightChip(
                              text: alert.reportedBy,
                              background: const Color(0xFFF2A79A),
                            ),
                          ),
                          const TextSpan(text: ', '),
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: _HighlightChip(
                              text: '${alert.volunteerFraction} volunteered',
                              background: const Color(0xFFE8D9A0),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (!isFinished)
                      const Text(
                        'Would you volunteer to help?',
                        style: TextStyle(
                          fontSize: 14.5,
                          color: AppColors.textDark,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Action: View pill or Finished pill, right-aligned
          Align(
            alignment: Alignment.centerRight,
            child: isFinished
                ? const _FinishedPill()
                : _ViewButton(onTap: onView),
          ),
        ],
      ),
    );
  }
}

class _HighlightChip extends StatelessWidget {
  final String text;
  final Color background;

  const _HighlightChip({required this.text, required this.background});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.textDark,
        ),
      ),
    );
  }
}

class _ViewButton extends StatelessWidget {
  final VoidCallback onTap;

  const _ViewButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 9),
          decoration: BoxDecoration(
            color: const Color(0xFFFCE9E7),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primaryRed, width: 1.4),
          ),
          child: const Text(
            'View',
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryRed,
            ),
          ),
        ),
      ),
    );
  }
}

class _FinishedPill extends StatelessWidget {
  const _FinishedPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.textDark, width: 1.4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, size: 13, color: Colors.white),
          ),
          const SizedBox(width: 8),
          const Text(
            'Finished',
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.notifications_none_rounded,
              size: 64,
              color: AppColors.hintGrey,
            ),
            const SizedBox(height: 16),
            const Text(
              'No notifications yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}