import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/api_exception.dart';
import '../../repositories/emergency_group_repository.dart';
import 'emergency_group_state.dart';

/// Drives the "enter home location → search for a group → join" flow that
/// now runs right after VerificationSuccessScreen (see
/// home_location_gate_screen.dart / select_home_location_screen.dart,
/// which replace the old step-3-of-verification location screens).
class EmergencyGroupCubit extends Cubit<EmergencyGroupState> {
  EmergencyGroupCubit({EmergencyGroupRepository? repository})
      : _repository = repository ?? EmergencyGroupRepository(),
        super(const EmergencyGroupState());

  final EmergencyGroupRepository _repository;

  // Kept so the confirm calls can resend the exact same coordinates the
  // search used — the collection notes "Server re-validates point inside
  // circle."
  double? _lastLat;
  double? _lastLng;

  /// POST /emergency/groups/join. Always passes save_as_home: true, since
  /// in this flow the point the user enters IS meant to become their home
  /// location.
  Future<void> searchGroups({
    required double latitude,
    required double longitude,
  }) async {
    _lastLat = latitude;
    _lastLng = longitude;
    emit(state.copyWith(status: EmergencyGroupStatus.searching));
    try {
      final result = await _repository.searchGroups(
        latitude: latitude,
        longitude: longitude,
        saveAsHome: true,
      );
      emit(state.copyWith(
        status: EmergencyGroupStatus.searched,
        searchResult: result,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: EmergencyGroupStatus.failure,
        errorMessage: e.message,
      ));
    }
  }

  Future<void> joinOfficialGroup(int groupId) async {
    if (_lastLat == null || _lastLng == null) return;
    emit(state.copyWith(status: EmergencyGroupStatus.joining));
    try {
      final result = await _repository.confirmOfficialJoin(
        groupId: groupId,
        latitude: _lastLat!,
        longitude: _lastLng!,
      );
      emit(state.copyWith(
        status: EmergencyGroupStatus.joined,
        joinResult: result,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: EmergencyGroupStatus.failure,
        errorMessage: e.message,
      ));
    }
  }

  Future<void> joinPendingGroup(int pendingGroupId) async {
    if (_lastLat == null || _lastLng == null) return;
    emit(state.copyWith(status: EmergencyGroupStatus.joining));
    try {
      final result = await _repository.confirmPendingJoin(
        pendingGroupId: pendingGroupId,
        latitude: _lastLat!,
        longitude: _lastLng!,
      );
      emit(state.copyWith(
        status: EmergencyGroupStatus.joined,
        joinResult: result,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: EmergencyGroupStatus.failure,
        errorMessage: e.message,
      ));
    }
  }

  Future<void> createNewPendingGroup() async {
    if (_lastLat == null || _lastLng == null) return;
    emit(state.copyWith(status: EmergencyGroupStatus.joining));
    try {
      final result = await _repository.confirmCreateNewPending(
        latitude: _lastLat!,
        longitude: _lastLng!,
      );
      emit(state.copyWith(
        status: EmergencyGroupStatus.joined,
        joinResult: result,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: EmergencyGroupStatus.failure,
        errorMessage: e.message,
      ));
    }
  }
}