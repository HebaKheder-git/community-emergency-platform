import 'package:equatable/equatable.dart';
import '../../models/trust_verification.dart';

enum TrustVerificationCubitStatus {
  idle,
  loading,
  loaded,
  submitting,
  submitted,
  deleting,
  deleted,
  failure,
}

class TrustVerificationState extends Equatable {
  final TrustVerificationCubitStatus status;
  final TrustVerificationModel data;
  final String? errorMessage;
  final Map<String, List<String>> fieldErrors;

  const TrustVerificationState({
    this.status = TrustVerificationCubitStatus.idle,
    this.data = const TrustVerificationModel.none(),
    this.errorMessage,
    this.fieldErrors = const {},
  });

  TrustVerificationState copyWith({
    TrustVerificationCubitStatus? status,
    TrustVerificationModel? data,
    String? errorMessage,
    Map<String, List<String>>? fieldErrors,
  }) {
    return TrustVerificationState(
      status: status ?? this.status,
      data: data ?? this.data,
      errorMessage: errorMessage,
      fieldErrors: fieldErrors ?? const {},
    );
  }

  @override
  List<Object?> get props => [status, data, errorMessage, fieldErrors];
}