import 'package:equatable/equatable.dart';

enum PasswordResetStatus {
  idle,
  loading,
  otpSent, // forgotPassword succeeded, temp_token issued
  otpVerified, // verify succeeded, (refreshed) temp_token held
  otpResent,
  completed, // password changed, token saved (user is logged in)
  failure,
}

class PasswordResetState extends Equatable {
  final PasswordResetStatus status;
  final String? tempToken;
  final String? errorMessage;
  final Map<String, List<String>> fieldErrors;

  const PasswordResetState({
    this.status = PasswordResetStatus.idle,
    this.tempToken,
    this.errorMessage,
    this.fieldErrors = const {},
  });

  PasswordResetState copyWith({
    PasswordResetStatus? status,
    String? tempToken,
    String? errorMessage,
    Map<String, List<String>>? fieldErrors,
  }) {
    return PasswordResetState(
      status: status ?? this.status,
      tempToken: tempToken ?? this.tempToken,
      errorMessage: errorMessage,
      fieldErrors: fieldErrors ?? const {},
    );
  }

  @override
  List<Object?> get props => [status, tempToken, errorMessage, fieldErrors];
}
