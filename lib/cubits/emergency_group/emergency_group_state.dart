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
  final String? errorMessage;

  const EmergencyGroupState({
    this.status = EmergencyGroupStatus.idle,
    this.searchResult,
    this.joinResult,
    this.errorMessage,
  });

  EmergencyGroupState copyWith({
    EmergencyGroupStatus? status,
    GroupSearchResult? searchResult,
    JoinConfirmationResult? joinResult,
    String? errorMessage,
  }) {
    return EmergencyGroupState(
      status: status ?? this.status,
      searchResult: searchResult ?? this.searchResult,
      joinResult: joinResult ?? this.joinResult,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, searchResult, joinResult, errorMessage];
}