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

class EmergencyGroupState extends Equatable {
  final EmergencyGroupStatus status;
  final GroupSearchResult? searchResult;
  final JoinConfirmationResult? joinResult;
  final int? chatId; // NEW
  final String? errorMessage;

  const EmergencyGroupState({
    this.status = EmergencyGroupStatus.idle,
    this.searchResult,
    this.joinResult,
    this.chatId, // NEW
    this.errorMessage,
  });

  /// True once we know the user has an active home group with chat access —
  /// either just joined an official group, or discovered via loadHomeGroup().
  bool get hasHomeChatAccess => chatId != null; // NEW

  EmergencyGroupState copyWith({
    EmergencyGroupStatus? status,
    GroupSearchResult? searchResult,
    JoinConfirmationResult? joinResult,
    int? chatId, // NEW
    String? errorMessage,
  }) {
    return EmergencyGroupState(
      status: status ?? this.status,
      searchResult: searchResult ?? this.searchResult,
      joinResult: joinResult ?? this.joinResult,
      chatId: chatId ?? this.chatId, // NEW
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, searchResult, joinResult, chatId, errorMessage]; // chatId added
}
