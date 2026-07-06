// lib/repositories/location_repository.dart
//
// One method per request in the Postman collection's "Profile — Location"
// folder (ProfileLocationController). Requires a profile to already exist
// (POST /profile) — see ProfileRepository, which the app already calls
// right after sign-up.
//
// IMPORTANT: this is NOT the same as POST /emergency/profile/home-location
// — the collection explicitly calls that out as a separate endpoint ("the
// trusted emergency home save"). That other endpoint appears to be what
// backs VerificationStep3LocationScreen's "permanent location, changeable
// once a year" flow. This repository only talks to the dedicated
// /profile/location sub-resource used by EditProfileScreen. See the note
// left on verification_step3_location_screen.dart.
import '../core/api_client.dart';
import '../core/api_exception.dart';
import '../models/location.dart';

class LocationRepository {
  LocationRepository({ApiClient? apiClient}) : _api = apiClient ?? ApiClient();

  final ApiClient _api;

  /// GET /profile/location. Returns null on 404 (nothing saved yet) so
  /// callers can treat it the same as "no location saved" instead of
  /// throwing.
  Future<LocationModel?> getLocation() async {
    try {
      final res = await _api.get('/profile/location');
      return LocationModel.fromJson(res);
    } on ApiException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }

  /// PUT /profile/location — first-time save (no previously saved
  /// coordinates).
  Future<LocationModel> addLocation({
    required double latitude,
    required double longitude,
    String? country,
    String? governorate,
    String? city,
  }) async {
    final res = await _api.put('/profile/location', body: {
      'latitude': latitude,
      'longitude': longitude,
      if (country != null && country.isNotEmpty) 'country': country,
      if (governorate != null && governorate.isNotEmpty) 'state': governorate,
      if (city != null && city.isNotEmpty) 'city': city,
    });
    return LocationModel.fromJson(res);
  }

  /// PATCH /profile/location — replace an existing saved location.
  Future<LocationModel> updateLocation({
    required double latitude,
    required double longitude,
    String? country,
    String? governorate,
    String? city,
  }) async {
    final res = await _api.patch('/profile/location', body: {
      'latitude': latitude,
      'longitude': longitude,
      if (country != null && country.isNotEmpty) 'country': country,
      if (governorate != null && governorate.isNotEmpty) 'state': governorate,
      if (city != null && city.isNotEmpty) 'city': city,
    });
    return LocationModel.fromJson(res);
  }

  /// DELETE /profile/location — clears lat/lng only; country/state/city
  /// text fields are kept server-side per the collection description.
  /// Not currently wired to any button in EditProfileScreen — exposed here
  /// in case you want a "Remove my location" action later.
  Future<LocationModel> deleteLocation() async {
    final res = await _api.delete('/profile/location');
    return LocationModel.fromJson(res);
  }

  /// PATCH /profile/location/visibility — powers the show/hide switch.
  Future<LocationModel> setLocationVisibility(bool isPublic) async {
    final res = await _api.patch('/profile/location/visibility', body: {
      'is_location_public': isPublic,
    });
    return LocationModel.fromJson(res);
  }
}