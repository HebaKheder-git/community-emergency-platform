// lib/models/trust_verification.dart
//
// Mirrors the resource returned by GET/POST/PUT /trust-verification...
//
// ASSUMPTION: like ProfileModel, the Postman collection doesn't include a
// real "response" sample for this folder — only test scripts that read
// `json.data.id`. The field names below (status, national_id,
// verification_birth_date, rejection_reason) are inferred from the
// collection's Arabic description and standard Laravel resource
// conventions. If the real response body (or the TrustVerificationResource
// class) uses different keys, send it over and this parser is a one-file
// fix.

enum TrustVerificationStatus { none, pending, rejected, approved }

TrustVerificationStatus _statusFromString(String? raw) {
  switch (raw) {
    case 'pending':
      return TrustVerificationStatus.pending;
    case 'rejected':
      return TrustVerificationStatus.rejected;
    case 'approved':
      return TrustVerificationStatus.approved;
    default:
      return TrustVerificationStatus.none;
  }
}

class TrustVerificationModel {
  final int? id;
  final TrustVerificationStatus status;
  final String? nationalId;
  final DateTime? birthDate;
  final String? rejectionReason;

  const TrustVerificationModel({
    this.id,
    this.status = TrustVerificationStatus.none,
    this.nationalId,
    this.birthDate,
    this.rejectionReason,
  });

  /// No request submitted yet (GET /trust-verification/me returned 404,
  /// per the collection's own description: "404 إذا لا يوجد طلب").
  const TrustVerificationModel.none()
      : id = null,
        status = TrustVerificationStatus.none,
        nationalId = null,
        birthDate = null,
        rejectionReason = null;

  /// pending → can be edited or deleted; rejected → can be edited +
  /// resubmitted. Both reuse the same PUT-spoofed /trust-verification/me
  /// endpoint from the Flutter side.
  bool get canEdit =>
      status == TrustVerificationStatus.pending ||
      status == TrustVerificationStatus.rejected;

  bool get isApproved => status == TrustVerificationStatus.approved;

  factory TrustVerificationModel.fromJson(Map<String, dynamic> json) {
    final root = (json['data'] is Map<String, dynamic>)
        ? json['data'] as Map<String, dynamic>
        : json;

    return TrustVerificationModel(
      id: root['id'] is int
          ? root['id'] as int
          : int.tryParse('${root['id']}'),
      status: _statusFromString(root['status'] as String?),
      nationalId: root['national_id'] as String?,
      birthDate: root['verification_birth_date'] != null
          ? DateTime.tryParse(root['verification_birth_date'].toString())
          : null,
      rejectionReason: root['rejection_reason'] as String?,
    );
  }
}