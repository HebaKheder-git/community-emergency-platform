import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/api_exception.dart';
import '../../repositories/location_repository.dart';
import 'location_state.dart';

/// Drives the "My Location" section of EditProfileScreen (verified users
/// only). Wraps GET/PUT/PATCH/DELETE /profile/location and
/// PATCH /profile/location/visibility.
class LocationCubit extends Cubit<LocationState> {
  LocationCubit({LocationRepository? repository})
      : _repository = repository ?? LocationRepository(),
        super(const LocationState());

  final LocationRepository _repository;

  /// GET /profile/location.
  Future<void> loadLocation() async {
    emit(state.copyWith(status: LocationStatus.loading));
    try {
      final location = await _repository.getLocation();
      emit(state.copyWith(status: LocationStatus.loaded, location: location));
    } on ApiException catch (e) {
      emit(state.copyWith(status: LocationStatus.failure, errorMessage: e.message));
    }
  }

  /// Called from the map picker / manual fields on "Save changes". Uses
  /// PUT if there is no previously saved location (has_coordinates ==
  /// false), PATCH if there is one already — per the "add vs update" rule.
  Future<void> saveLocation({
    required double latitude,
    required double longitude,
    String? country,
    String? governorate,
    String? city,
  }) async {
    final hadCoordinates = state.hasCoordinates;
    emit(state.copyWith(status: LocationStatus.saving));
    try {
      final updated = hadCoordinates
          ? await _repository.updateLocation(
              latitude: latitude,
              longitude: longitude,
              country: country,
              governorate: governorate,
              city: city,
            )
          : await _repository.addLocation(
              latitude: latitude,
              longitude: longitude,
              country: country,
              governorate: governorate,
              city: city,
            );
      emit(state.copyWith(status: LocationStatus.saved, location: updated));
    } on ApiException catch (e) {
      emit(state.copyWith(status: LocationStatus.failure, errorMessage: e.message));
    }
  }

  /// DELETE /profile/location. Not wired to a button yet — call this if you
  /// add a "Remove my location" action later.
  Future<void> clearLocation() async {
    emit(state.copyWith(status: LocationStatus.saving));
    try {
      final updated = await _repository.deleteLocation();
      emit(state.copyWith(status: LocationStatus.saved, location: updated));
    } on ApiException catch (e) {
      emit(state.copyWith(status: LocationStatus.failure, errorMessage: e.message));
    }
  }

  /// PATCH /profile/location/visibility — wired to the show/hide switch,
  /// applied immediately rather than waiting for "Save changes".
  Future<void> setVisibility(bool isPublic) async {
    try {
      final updated = await _repository.setLocationVisibility(isPublic);
      emit(state.copyWith(status: LocationStatus.saved, location: updated));
    } on ApiException catch (e) {
      emit(state.copyWith(status: LocationStatus.failure, errorMessage: e.message));
    }
  }
}