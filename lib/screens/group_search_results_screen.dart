import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../theme/app_theme.dart';
import '../widgets/primary_button.dart';
import '../models/emergency_group.dart';
import '../cubits/emergency_group/emergency_group_cubit.dart';
import '../cubits/emergency_group/emergency_group_state.dart';
import 'home_screen.dart';

// ════════════════════════════════════════════════════════════════════════════
// Group Search Results — the new "search for a group" UI, pushed right
// after the user picks a location in SelectHomeLocationScreen.
//
// Reflects the scenario rules from the Postman collection:
//   official_available → show official_groups, join via confirmOfficialJoin
//   pending_only        → show pending_groups, join via confirmPendingJoin
//   none                 → offer to start a brand-new pending group
//
// On any successful join (joined / already_member / pending-awaiting-
// approval) the user is sent back to HomeScreen, per your note: "if he
// applied for a group to join he goes back to home screen (sos)."
//
// Expects an EmergencyGroupCubit to already be provided above it in the
// tree (SelectHomeLocationScreen creates one, kicks off searchGroups(),
// and wraps this screen in BlocProvider.value).
// ════════════════════════════════════════════════════════════════════════════

class GroupSearchResultsScreen extends StatelessWidget {
  const GroupSearchResultsScreen({super.key});

  void _backToHome(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      body: SafeArea(
        child: BlocConsumer<EmergencyGroupCubit, EmergencyGroupState>(
          listener: (context, state) {
            if (state.status == EmergencyGroupStatus.joined) {
              final pending = state.joinResult?.isPendingApproval ?? false;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    pending
                        ? "Request sent — you'll be added once an admin approves."
                        : 'You joined the group!',
                  ),
                ),
              );
              _backToHome(context);
            }
          },
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Back arrow → Home ──────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back,
                            color: AppColors.textDark),
                        onPressed: () => _backToHome(context),
                      ),
                    ],
                  ),
                ),
                Expanded(child: _buildBody(context, state)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, EmergencyGroupState state) {
    if (state.status == EmergencyGroupStatus.idle ||
        state.status == EmergencyGroupStatus.searching ||
        state.status == EmergencyGroupStatus.joined) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == EmergencyGroupStatus.failure) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline,
                  size: 48, color: AppColors.primaryRed),
              const SizedBox(height: 12),
              Text(
                state.errorMessage ?? 'Something went wrong.',
                textAlign: TextAlign.center,
                style: AppTextStyles.subtitle,
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                label: 'Back',
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      );
    }

    // status is searched or joining — searchResult should be populated.
    final result = state.searchResult;
    if (result == null) return const SizedBox.shrink();
    final isJoining = state.status == EmergencyGroupStatus.joining;

    if (result.scenario == GroupSearchScenario.officialAvailable) {
      return _GroupList<OfficialGroupSummary>(
        title: 'Emergency groups near you',
        subtitle: 'Join the official group covering your area.',
        groups: result.officialGroups,
        buttonLabel: 'Join',
        isJoining: isJoining,
        onJoin: (id) =>
            context.read<EmergencyGroupCubit>().joinOfficialGroup(id),
      );
    }

    if (result.scenario == GroupSearchScenario.pendingOnly) {
      return _GroupList<PendingGroupSummary>(
        title: 'Pending groups near you',
        subtitle:
            'These groups are awaiting official approval. You can request to join now.',
        groups: result.pendingGroups,
        buttonLabel: 'Request to join',
        isJoining: isJoining,
        onJoin: (id) =>
            context.read<EmergencyGroupCubit>().joinPendingGroup(id),
      );
    }

    // scenario == none
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.groups_outlined,
                size: 48, color: AppColors.textGrey),
            const SizedBox(height: 12),
            const Text(
              'No group exists near this location yet.',
              textAlign: TextAlign.center,
              style: AppTextStyles.subtitle,
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: isJoining ? 'Starting…' : 'Start a new group here',
              onPressed: () {
                if (isJoining) return;
                context.read<EmergencyGroupCubit>().createNewPendingGroup();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupList<T extends GroupSummaryBase> extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<T> groups;
  final String buttonLabel;
  final bool isJoining;
  final void Function(int id) onJoin;

  const _GroupList({
    required this.title,
    required this.subtitle,
    required this.groups,
    required this.buttonLabel,
    required this.isJoining,
    required this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    if (groups.isEmpty) {
      return Center(
        child: Text('No groups found.', style: AppTextStyles.subtitle),
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 6),
        Text(subtitle, style: AppTextStyles.subtitle),
        const SizedBox(height: 16),
        for (final g in groups)
          _GroupCard(
            group: g,
            buttonLabel: buttonLabel,
            isJoining: isJoining,
            onJoin: onJoin,
          ),
      ],
    );
  }
}

class _GroupCard<T extends GroupSummaryBase> extends StatelessWidget {
  final T group;
  final String buttonLabel;
  final bool isJoining;
  final void Function(int id) onJoin;

  const _GroupCard({
    required this.group,
    required this.buttonLabel,
    required this.isJoining,
    required this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group.displayName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                if (group.subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(group.subtitle!, style: AppTextStyles.subtitle),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: isJoining ? null : () => onJoin(group.id),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryRed,
              foregroundColor: Colors.white,
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: Text(buttonLabel),
          ),
        ],
      ),
    );
  }
}