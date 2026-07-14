//lib/cubits/emergency_group/emergency_group_state.dart


import 'package:equatable/equatable.dart';
import '../../models/emergency_group.dart';

enum EmergencyGroupStatus {
  idle,
  searching,
  searched,
  joining,
  joined,
  failure,
}

// NEW — tracks the *separate* "does this user already belong to a home
// group?" background check (EmergencyGroupCubit.loadHomeGroup()), used by
// HomeScreen to decide between the SOS content, the "search for a group"
// prompt, and a loading spinner. Kept apart from [EmergencyGroupStatus]
// above (which drives the search/join flow) so none of the search/join
// screens have to change.
enum HomeGroupCheckStatus {
  unknown, // loadHomeGroup() hasn't been called / hasn't resolved yet
  checking, // GET /emergency/my-group in flight
  hasGroup, // 200 — the user already belongs to a group
  noGroup, // 403/404 — not a member of any group yet
}

class EmergencyGroupState extends Equatable {
  final EmergencyGroupStatus status;
  final GroupSearchResult? searchResult;
  final JoinConfirmationResult? joinResult;
  final int? chatId; // NEW
  final String? errorMessage;

  // NEW — home-group background check (see HomeGroupCheckStatus above).
  final HomeGroupCheckStatus homeGroupCheckStatus;
  final HomeGroupInfo? homeGroupInfo;

  const EmergencyGroupState({
    this.status = EmergencyGroupStatus.idle,
    this.searchResult,
    this.joinResult,
    this.chatId, // NEW
    this.errorMessage,
    this.homeGroupCheckStatus = HomeGroupCheckStatus.unknown, // NEW
    this.homeGroupInfo, // NEW
  });

  /// True once we know the user has an active home group with chat access —
  /// either just joined an official group, or discovered via loadHomeGroup().
  bool get hasHomeChatAccess => chatId != null; // NEW

  /// NEW — true once loadHomeGroup() has confirmed the user already belongs
  /// to a home group (official or pending). This is what HomeScreen uses to
  /// decide whether to hide the "Search for Emergency Group" button.
  bool get hasHomeGroup =>
      homeGroupCheckStatus == HomeGroupCheckStatus.hasGroup;

  EmergencyGroupState copyWith({
    EmergencyGroupStatus? status,
    GroupSearchResult? searchResult,
    JoinConfirmationResult? joinResult,
    int? chatId, // NEW
    String? errorMessage,
    HomeGroupCheckStatus? homeGroupCheckStatus, // NEW
    HomeGroupInfo? homeGroupInfo, // NEW
  }) {
    return EmergencyGroupState(
      status: status ?? this.status,
      searchResult: searchResult ?? this.searchResult,
      joinResult: joinResult ?? this.joinResult,
      chatId: chatId ?? this.chatId, // NEW
      errorMessage: errorMessage,
      homeGroupCheckStatus:
          homeGroupCheckStatus ?? this.homeGroupCheckStatus, // NEW
      homeGroupInfo: homeGroupInfo ?? this.homeGroupInfo, // NEW
    );
  }

  @override
  List<Object?> get props => [
        status,
        searchResult,
        joinResult,
        chatId,
        errorMessage,
        homeGroupCheckStatus, // NEW
        homeGroupInfo, // NEW
      ];
}