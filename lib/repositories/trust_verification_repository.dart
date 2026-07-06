// lib/repositories/trust_verification_repository.dart
//
// One method per request in the Postman collection's "App (Member)" folder
// for /trust-verification.
//
// NOTE on PUT vs PATCH: the Postman requests for "update pending" and
// "resubmit rejected" both spoof `_method: PUT` (not PATCH). ApiClient
// .patchMultipart hardcodes `_method: 'PATCH'` (which /profile wants), so
// rather than touch that shared helper, this repository builds its own
// FormData and calls ApiClient.postMultipart directly with `_method: 'PUT'`
// appended — matching exactly what's been tested in Postman.
//
// NOTE on required files: the Flutter step 1/2 screens always ask the user
// to (re)capture all four images/photo, so submit() and resubmit() below
// treat national_id, verification_birth_date, id_card_front, id_card_back
// and the face photo as always required. The backend's "update pending"
// request technically allows leaving images untouched (they're `disabled`
// fields in that one Postman request), but there's no local file path to
// reuse for an existing server-side image, so this simplified flow always
// re-sends fresh captures on edit too.

import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../core/api_exception.dart';
import '../models/trust_verification.dart';

class TrustVerificationRepository {
  TrustVerificationRepository({ApiClient? apiClient})
      : _api = apiClient ?? ApiClient();

  final ApiClient _api;

  /// GET /trust-verification/me
  /// Returns `TrustVerificationModel.none()` when the user hasn't submitted
  /// a request yet.
  Future<TrustVerificationModel> getMine() async {
    try {
      final res = await _api.get('/trust-verification/me');
      return TrustVerificationModel.fromJson(res);
    } on ApiException catch (e) {
      if (e.statusCode == 404) return const TrustVerificationModel.none();
      rethrow;
    }
  }

  String _formatDob(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<FormData> _buildFormData({
    required String nationalId,
    required DateTime birthDate,
    required String idCardFrontPath,
    required String idCardBackPath,
    required String facePhotoPath,
  }) async {
    return FormData.fromMap({
      'national_id': nationalId,
      'verification_birth_date': _formatDob(birthDate),
      'id_card_front': await MultipartFile.fromFile(idCardFrontPath),
      'id_card_back': await MultipartFile.fromFile(idCardBackPath),
      // Same captured selfie sent under both keys — there is no separate
      // "holding ID photo" step or field shown to the user in Flutter.
      'verification_photo': await MultipartFile.fromFile(facePhotoPath),
      'holding_id_photo': await MultipartFile.fromFile(facePhotoPath),
    });
  }

  /// POST /trust-verification — first-time submission.
  /// 422 if a pending or approved request already exists — surfaced to the
  /// UI as ApiException.message like any other validation error.
  Future<TrustVerificationModel> submit({
    required String nationalId,
    required DateTime birthDate,
    required String idCardFrontPath,
    required String idCardBackPath,
    required String facePhotoPath,
  }) async {
    final formData = await _buildFormData(
      nationalId: nationalId,
      birthDate: birthDate,
      idCardFrontPath: idCardFrontPath,
      idCardBackPath: idCardBackPath,
      facePhotoPath: facePhotoPath,
    );
    final res = await _api.postMultipart('/trust-verification', formData);
    return TrustVerificationModel.fromJson(res);
  }

  /// PUT (spoofed) /trust-verification/me — used both to edit a `pending`
  /// request and to resubmit after `rejected` (the backend decides which
  /// based on the current status; the request shape is identical either
  /// way).
  Future<TrustVerificationModel> resubmit({
    required String nationalId,
    required DateTime birthDate,
    required String idCardFrontPath,
    required String idCardBackPath,
    required String facePhotoPath,
  }) async {
    final formData = await _buildFormData(
      nationalId: nationalId,
      birthDate: birthDate,
      idCardFrontPath: idCardFrontPath,
      idCardBackPath: idCardBackPath,
      facePhotoPath: facePhotoPath,
    );
    formData.fields.add(const MapEntry('_method', 'PUT'));
    final res = await _api.postMultipart('/trust-verification/me', formData);
    return TrustVerificationModel.fromJson(res);
  }

  /// DELETE /trust-verification/me — only allowed while `pending`.
  Future<void> deleteMine() => _api.delete('/trust-verification/me');
}