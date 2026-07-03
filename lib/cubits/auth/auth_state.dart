import 'package:equatable/equatable.dart';

enum AuthStatus {
  idle,
  loading,
  registerAwaitingOtp, // temp_token issued, OTP screen should show
  registerVerified, // OTP confirmed, token saved, user is logged in
  otpResent,
  loggedIn,
  loggedOut,
  failure,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final String? tempToken;
  final String? errorMessage;
  final Map<String, List<String>> fieldErrors;

  const AuthState({
    this.status = AuthStatus.idle,
    this.tempToken,
    this.errorMessage,
    this.fieldErrors = const {},
  });

  AuthState copyWith({
    AuthStatus? status,
    String? tempToken,
    String? errorMessage,
    Map<String, List<String>>? fieldErrors,
  }) {
    return AuthState(
      status: status ?? this.status,
      tempToken: tempToken ?? this.tempToken,
      errorMessage: errorMessage,
      fieldErrors: fieldErrors ?? const {},
    );
  }

  @override
  List<Object?> get props => [status, tempToken, errorMessage, fieldErrors];
}
