// lib/repositories/emergency_group_repository.dart
//
// One method per request in the Postman collection's
// "Emergency — Membership (Trusted)" folder.
import '../core/api_client.dart';
import '../core/api_exception.dart';
import '../models/emergency_group.dart';

class EmergencyGroupRepository {
  EmergencyGroupRepository({ApiClient? apiClient})
      : _api = apiClient ?? ApiClient();

  final ApiClient _api;

  /// POST /emergency/groups/join — search only, does not join.
  /// [saveAsHome]=true also updates the profile's home location as part of
  /// this same call (per the Postman description: "Optional: save_as_home:
  /// true updates profile home location"). The new "enter home location →
  /// search for a group" flow always wants this, since the point the user
  /// is picking IS meant to become their home location.
  Future<GroupSearchResult> searchGroups({
    required double latitude,
    required double longitude,
    bool saveAsHome = false,
  }) async {
    final res = await _api.post('/emergency/groups/join', body: {
      'latitude': latitude,
      'longitude': longitude,
      if (saveAsHome) 'save_as_home': true,
    });
    return GroupSearchResult.fromJson(res);
  }

  /// POST /emergency/groups/{group_id}/join/confirm
  /// Only call after a search returned scenario == officialAvailable.
  Future<JoinConfirmationResult> confirmOfficialJoin({
    required int groupId,
    required double latitude,
    required double longitude,
  }) async {
    final res = await _api.post(
      '/emergency/groups/$groupId/join/confirm',
      body: {'latitude': latitude, 'longitude': longitude},
    );
    return JoinConfirmationResult.fromJson(res);
  }

  /// POST /emergency/pending-groups/{pending_group_id}/join/confirm
  /// Only call after a search returned scenario == pendingOnly.
  /// Note per the collection: returns 422 (official_groups_available) if
  /// an official group now exists at these coordinates.
  Future<JoinConfirmationResult> confirmPendingJoin({
    required int pendingGroupId,
    required double latitude,
    required double longitude,
  }) async {
    final res = await _api.post(
      '/emergency/pending-groups/$pendingGroupId/join/confirm',
      body: {'latitude': latitude, 'longitude': longitude},
    );
    return JoinConfirmationResult.fromJson(res);
  }

  /// POST /emergency/pending-groups/join/confirm — first member of a brand
  /// new pending group. Only call after a search returned scenario == none.
  Future<JoinConfirmationResult> confirmCreateNewPending({
    required double latitude,
    required double longitude,
  }) async {
    final res = await _api.post(
      '/emergency/pending-groups/join/confirm',
      body: {'latitude': latitude, 'longitude': longitude},
    );
    return JoinConfirmationResult.fromJson(res);
  }

  /// POST /emergency/profile/home-location — saves the home location only,
  /// without searching/joining any group. Not wired to any button in this
  /// flow (searchGroups(saveAsHome: true) already covers it), but exposed
  /// here in case you want a standalone "update home address" action later
  /// (e.g. from Settings, to change home location without re-searching).
  Future<void> saveHomeLocationOnly({
    required double latitude,
    required double longitude,
  }) async {
    await _api.post('/emergency/profile/home-location', body: {
      'home_lat': latitude,
      'home_lng': longitude,
    });
  }

  // REMOVE the existing getMyGroupRaw() method and REPLACE with:

  /// GET /emergency/my-group — used to (re)discover the caller's chat_id,
  /// e.g. right after joining, or on app start for a returning trusted
  /// user who already belongs to a home group.
  /// Returns null on 403/404 (not an active member yet) so the Cubit can
  /// show "join a group" instead of an error.
  Future<HomeGroupInfo?> getMyGroup() async {
    try {
      final res = await _api.get('/emergency/my-group');
      return HomeGroupInfo.fromJson(res);
    } on ApiException catch (e) {
      if (e.statusCode == 403 || e.statusCode == 404) return null;
      rethrow;
    }
  }
}