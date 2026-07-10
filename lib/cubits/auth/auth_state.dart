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
  static const String trustedRole = 'trusted'; // NEW

  const AuthState({
    this.status = AuthStatus.idle,
    this.tempToken,
    this.errorMessage,
    this.fieldErrors = const {},
    this.roles = const [],
    this.permissions = const [],
  });

  /// True once the backend has assigned this user the `trusted` role —
  /// this is the single source of truth for "is this user verified"
  /// across the app (covers both normally-approved users and any account
  /// fast-tracked directly on the backend, since both end up with the
  /// same role). NEW.
  bool get isTrusted => roles.contains(trustedRole);

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