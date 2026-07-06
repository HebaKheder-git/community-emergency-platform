/// Mirrors the response of GET /profile/location (ProfileLocationController).
///
/// ASSUMPTION: like ProfileModel, the Postman collection only documents an
/// empty "response": [] example for this endpoint — the exact JSON shape is
/// inferred from the collection's prose ("Returns saved coordinates, address
/// labels, visibility flag, and `has_coordinates`"). This parser accepts both
/// a `{"data": {...}}` wrapper and a flat object, same convention as
/// ProfileModel. Please send a real response body (or the Laravel
/// LocationResource class) if any field name here is off.
///
/// NOTE: "state" below is the UI's "State/Governorate" field — kept as
/// `governorate` in Dart to avoid shadowing Cubit's own `state` getter, but
/// still serialized as the JSON key `state` the backend expects.
class LocationModel {
  final double? latitude;
  final double? longitude;
  final String? country;
  final String? governorate; // JSON key: "state"
  final String? city;
  final bool isLocationPublic;
  final bool hasCoordinates;

  const LocationModel({
    this.latitude,
    this.longitude,
    this.country,
    this.governorate,
    this.city,
    this.isLocationPublic = false,
    this.hasCoordinates = false,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    final root = (json['data'] is Map<String, dynamic>)
        ? json['data'] as Map<String, dynamic>
        : json;

    double? toDouble(dynamic v) =>
        v == null ? null : double.tryParse(v.toString());

    final lat = toDouble(root['latitude']);
    final lng = toDouble(root['longitude']);

    return LocationModel(
      latitude: lat,
      longitude: lng,
      country: root['country'] as String?,
      governorate: root['state'] as String?,
      city: root['city'] as String?,
      isLocationPublic: root['is_location_public'] == true,
      // Fall back to inferring from lat/lng in case the backend response
      // for this particular build doesn't include `has_coordinates` yet.
      hasCoordinates: root['has_coordinates'] == true || (lat != null && lng != null),
    );
  }

  LocationModel copyWith({
    double? latitude,
    double? longitude,
    String? country,
    String? governorate,
    String? city,
    bool? isLocationPublic,
    bool? hasCoordinates,
  }) {
    return LocationModel(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      country: country ?? this.country,
      governorate: governorate ?? this.governorate,
      city: city ?? this.city,
      isLocationPublic: isLocationPublic ?? this.isLocationPublic,
      hasCoordinates: hasCoordinates ?? this.hasCoordinates,
    );
  }
}