import 'package:equatable/equatable.dart';

enum AuthStatus {
  idle,
  loading,
  registerAwaitingOtp,
  registerVerified,
  otpResent,
  loggedIn,
  loggedOut,
  profileLoaded, // NEW — result of fetchMe()
  failure,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final String? tempToken;
  final String? errorMessage;
  final Map<String, List<String>> fieldErrors;
  final List<String> roles;          // NEW
  final List<String> permissions;    // NEW

  const AuthState({
    this.status = AuthStatus.idle,
    this.tempToken,
    this.errorMessage,
    this.fieldErrors = const {},
    this.roles = const [],
    this.permissions = const [],
  });

  AuthState copyWith({
    AuthStatus? status,
    String? tempToken,
    String? errorMessage,
    Map<String, List<String>>? fieldErrors,
    List<String>? roles,
    List<String>? permissions,
  }) {
    return AuthState(
      status: status ?? this.status,
      tempToken: tempToken ?? this.tempToken,
      errorMessage: errorMessage,
      fieldErrors: fieldErrors ?? const {},
      roles: roles ?? this.roles,
      permissions: permissions ?? this.permissions,
    );
  }

  @override
  List<Object?> get props =>
      [status, tempToken, errorMessage, fieldErrors, roles, permissions];
}