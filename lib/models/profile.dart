/// Mirrors the ProfileResource shape returned by GET/POST/PATCH /profile.
///
/// ASSUMPTION: the Postman collection only shows empty "response": []
/// examples, so the exact JSON shape (whether it's wrapped in a top-level
/// "data" key, and exact key names) is inferred from the collection's
/// prose description, not a real sample. This parser accepts both a
/// `{"data": {...}}` wrapper and a flat object. Please send a real
/// response body (or the Laravel ProfileResource class) so this can be
/// corrected if any field name is off.
class ProfileModel {
  final int? id;
  final String? name;
  final int? rescueCount;
  final List<String> roles;

  final String? phone;
  final String? avatarUrl;
  final DateTime? birthDate;
  final String? gender;
  final String? country;
  final String? state;
  final String? city;
  final String? address;
  final String? postalCode;
  final String? bio;
  final double? latitude;
  final double? longitude;
  final String? locale;
  final String? timezone;
  final bool isLocationPublic;
  final bool isPhonePublic;

  const ProfileModel({
    this.id,
    this.name,
    this.rescueCount,
    this.roles = const [],
    this.phone,
    this.avatarUrl,
    this.birthDate,
    this.gender,
    this.country,
    this.state,
    this.city,
    this.address,
    this.postalCode,
    this.bio,
    this.latitude,
    this.longitude,
    this.locale,
    this.timezone,
    this.isLocationPublic = false,
    this.isPhonePublic = false,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    final root = (json['data'] is Map<String, dynamic>)
        ? json['data'] as Map<String, dynamic>
        : json;
    final user = root['user'] as Map<String, dynamic>?;

    double? toDouble(dynamic v) => v == null ? null : double.tryParse(v.toString());

    return ProfileModel(
      id: root['id'] is int ? root['id'] as int : int.tryParse('${root['id']}'),
      name: user?['name'] as String?,
      rescueCount: user?['rescue_count'] as int?,
      roles: (user?['roles'] as List? ?? []).map((e) => e.toString()).toList(),
      phone: root['phone'] as String?,
      avatarUrl: root['avatar'] as String?,
      birthDate: root['birth_date'] != null
          ? DateTime.tryParse(root['birth_date'].toString())
          : null,
      gender: root['gender'] as String?,
      country: root['country'] as String?,
      state: root['state'] as String?,
      city: root['city'] as String?,
      address: root['address'] as String?,
      postalCode: root['postal_code'] as String?,
      bio: root['bio'] as String?,
      latitude: toDouble(root['latitude']),
      longitude: toDouble(root['longitude']),
      locale: root['locale'] as String?,
      timezone: root['timezone'] as String?,
      isLocationPublic: root['is_location_public'] == true,
      isPhonePublic: root['is_phone_public'] == true,
    );
  }
}