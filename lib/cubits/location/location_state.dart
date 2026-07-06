import 'package:equatable/equatable.dart';
import '../../models/location.dart';

enum LocationStatus { initial, loading, loaded, saving, saved, failure }

class LocationState extends Equatable {
  final LocationStatus status;
  final LocationModel? location;
  final String? errorMessage;

  const LocationState({
    this.status = LocationStatus.initial,
    this.location,
    this.errorMessage,
  });

  /// Drives whether LocationCubit.saveLocation calls PUT (add) or PATCH
  /// (update) — true once the backend has previously saved coordinates.
  bool get hasCoordinates => location?.hasCoordinates == true;

  LocationState copyWith({
    LocationStatus? status,
    LocationModel? location,
    String? errorMessage,
  }) {
    return LocationState(
      status: status ?? this.status,
      location: location ?? this.location,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, location, errorMessage];
}