import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/api_exception.dart';
import '../../repositories/auth_repository.dart';
import 'password_reset_state.dart';

/// Drives ForgotPasswordEmailScreen, ResetPasswordEmailOtpScreen and
/// CreateNewPasswordScreen.
///
/// NOTE: only the email flow is backed by a real endpoint right now
/// (/auth/password/forgot only takes `email`). ResetPasswordPhoneScreen /
/// ResetPasswordPhoneOtpScreen have nothing to call yet — see the linking
/// notes doc.
class PasswordResetCubit extends Cubit<PasswordResetState> {
  /// [initialTempToken] lets a screen that already called forgotPassword()
  /// (e.g. ForgotPasswordEmailScreen, or SettingsScreen's "Reset password"
  /// tile) hand the resulting temp_token straight to the next screen's
  /// cubit instance.
  PasswordResetCubit({AuthRepository? repository, String? initialTempToken})
      : _repository = repository ?? AuthRepository(),
        super(PasswordResetState(tempToken: initialTempToken));

  final AuthRepository _repository;

  Future<void> requestOtp(String email) async {
    emit(state.copyWith(status: PasswordResetStatus.loading));
    try {
      final tempToken = await _repository.forgotPassword(email: email);
      emit(state.copyWith(
        status: PasswordResetStatus.otpSent,
        tempToken: tempToken,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: PasswordResetStatus.failure,
        errorMessage: e.message,
        fieldErrors: e.fieldErrors,
      ));
    }
  }

  Future<void> verifyOtp(String code) async {
    final tempToken = state.tempToken;
    if (tempToken == null) {
      emit(state.copyWith(
        status: PasswordResetStatus.failure,
        errorMessage: 'Session expired, please request a new code.',
      ));
      return;
    }
    emit(state.copyWith(status: PasswordResetStatus.loading));
    try {
      final refreshedTempToken = await _repository.verifyPasswordResetOtp(
        otpCode: code,
        tempToken: tempToken,
      );
      emit(state.copyWith(
        status: PasswordResetStatus.otpVerified,
        tempToken: refreshedTempToken,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(status: PasswordResetStatus.failure, errorMessage: e.message));
    }
  }

  Future<void> resendOtp() async {
    final tempToken = state.tempToken;
    if (tempToken == null) return;
    try {
      await _repository.resendOtp(tempToken: tempToken);
      emit(state.copyWith(status: PasswordResetStatus.otpResent));
    } on ApiException catch (e) {
      emit(state.copyWith(status: PasswordResetStatus.failure, errorMessage: e.message));
    }
  }

  Future<void> resetPassword({
    required String password,
    required String passwordConfirmation,
  }) async {
    final tempToken = state.tempToken;
    if (tempToken == null) {
      emit(state.copyWith(
        status: PasswordResetStatus.failure,
        errorMessage: 'Session expired, please request a new code.',
      ));
      return;
    }
    emit(state.copyWith(status: PasswordResetStatus.loading));
    try {
      await _repository.resetPassword(
        password: password,
        passwordConfirmation: passwordConfirmation,
        tempToken: tempToken,
      );
      emit(state.copyWith(status: PasswordResetStatus.completed));
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: PasswordResetStatus.failure,
        errorMessage: e.message,
        fieldErrors: e.fieldErrors,
      ));
    }
  }
}
