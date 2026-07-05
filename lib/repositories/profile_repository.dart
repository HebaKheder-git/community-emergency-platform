import 'dart:io';
import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../core/api_exception.dart';
import '../models/profile.dart';

/// One method per request in the Postman collection's "Profile" folder.
///
/// Context specific to this app:
///  - There is no "create profile" screen. A profile is created once,
///    automatically, right after sign-up is verified (see
///    AuthCubit.verifyRegistrationOtp) and — as a safety net — the first
///    time [getProfile] comes back 404 (e.g. if that first call silently
///    failed because the user was offline at that moment).
///  - Full profile deletion is intentionally NOT exposed in the app, so
///    DELETE /profile is not wired here.
///  - `phone` is created empty (sign-up has no phone step yet) and is
///    meant to be filled in later from Edit Profile.
class ProfileRepository {
  ProfileRepository({ApiClient? apiClient}) : _api = apiClient ?? ApiClient();

  final ApiClient _api;

  /// GET /profile. Returns null on 404 (no profile yet) instead of
  /// throwing, so callers can decide to create one.
  Future<ProfileModel?> getProfile() async {
    try {
      final res = await _api.get('/profile');
      return ProfileModel.fromJson(res);
    } on ApiException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }

  /// POST /profile. Called with no arguments right after registration —
  /// every field is optional, so this creates a bare profile that the
  /// user fills in later from Edit Profile.
  Future<ProfileModel> createProfile({
    String? phone,
    String? gender,
    String? bio,
    DateTime? birthDate,
    bool isLocationPublic = false,
    bool isPhonePublic = false,
    String locale = 'en',
  }) async {
    final res = await _api.post('/profile', body: {
      if (phone != null && phone.isNotEmpty) 'phone': phone,
      if (gender != null) 'gender': gender,
      if (bio != null) 'bio': bio,
      if (birthDate != null) 'birth_date': _formatDate(birthDate),
      'is_location_public': isLocationPublic,
      'is_phone_public': isPhonePublic,
      'locale': locale,
    });
    return ProfileModel.fromJson(res);
  }

  /// PATCH /profile — used by Edit Profile's "Save changes". Only the
  /// fields the app currently edits (phone, gender, bio, birth_date,
  /// is_location_public) plus an optional new avatar are sent.
  Future<ProfileModel> updateProfile({
    String? phone,
    String? gender,
    String? bio,
    DateTime? birthDate,
    bool? isLocationPublic,
    File? avatar,
  }) async {
    final fields = <String, dynamic>{
      if (phone != null) 'phone': phone,
      if (gender != null) 'gender': gender,
      if (bio != null) 'bio': bio,
      if (birthDate != null) 'birth_date': _formatDate(birthDate),
      if (isLocationPublic != null) 'is_location_public': isLocationPublic,
    };

    if (avatar == null) {
      final res = await _api.patch('/profile', body: fields);
      return ProfileModel.fromJson(res);
    }

    final formData = FormData.fromMap({
      ...fields.map((key, value) => MapEntry(key, _toFormValue(value))),
      'avatar': await MultipartFile.fromFile(avatar.path),
    });
    final res = await _api.patchMultipart('/profile', formData);
    return ProfileModel.fromJson(res);
  }

  // multipart/form-data has no native boolean type — everything becomes a
  // string. Laravel's `boolean` validation rule only accepts
  // true/false/1/0/"1"/"0", NOT the literal strings "true"/"false" (which
  // is what plain `.toString()` on a bool produces, and exactly what was
  // causing "The is location public field must be true or false").
  String _toFormValue(dynamic value) {
    if (value is bool) return value ? '1' : '0';
    return value.toString();
  }

  String _formatDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}