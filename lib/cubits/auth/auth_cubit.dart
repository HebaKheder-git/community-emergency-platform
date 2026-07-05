import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/api_exception.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/profile_repository.dart';
import 'auth_state.dart';

/// Drives SignUpScreen, OtpVerificationScreen (register flow), LoginScreen
/// and the "Log out" action in SettingsScreen.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit({AuthRepository? repository, ProfileRepository? profileRepository})
      : _repository = repository ?? AuthRepository(),
        _profileRepository = profileRepository ?? ProfileRepository(),
        super(const AuthState());

  final AuthRepository _repository;
  final ProfileRepository _profileRepository;

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final tempToken = await _repository.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      emit(state.copyWith(
        status: AuthStatus.registerAwaitingOtp,
        tempToken: tempToken,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: e.message,
        fieldErrors: e.fieldErrors,
      ));
    }
  }

  /// [tempToken] is passed in explicitly (from OtpVerificationScreen, which
  /// received it from SignUpScreen) rather than read off `state`, so this
  /// works even if OtpVerificationScreen owns a fresh AuthCubit instance.
  Future<void> verifyRegistrationOtp({
    required String code,
    required String tempToken,
  }) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      await _repository.verifyRegistrationCode(
        verificationCode: code,
        tempToken: tempToken,
      );

      // There is no "create profile" screen in this app, and a profile can
      // never be fully deleted — so every account gets an (empty) profile
      // the instant it's created here. Failure is non-fatal: ProfileCubit
      // .loadProfile() creates one on-demand later if this silently failed
      // (e.g. the user lost connection at exactly this moment).
      try {
        await _profileRepository.createProfile();
      } catch (_) {}

      emit(state.copyWith(status: AuthStatus.registerVerified));
    } on ApiException catch (e) {
      emit(state.copyWith(status: AuthStatus.failure, errorMessage: e.message));
    }
  }

  Future<void> resendOtp(String tempToken) async {
    try {
      await _repository.resendOtp(tempToken: tempToken);
      emit(state.copyWith(status: AuthStatus.otpResent));
    } on ApiException catch (e) {
      emit(state.copyWith(status: AuthStatus.failure, errorMessage: e.message));
    }
  }

  Future<void> login({required String email, required String password}) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      await _repository.login(email: email, password: password);
      emit(state.copyWith(status: AuthStatus.loggedIn));
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: e.message,
        fieldErrors: e.fieldErrors,
      ));
    }
  }

  Future<void> logout() async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      await _repository.logout();
    } on ApiException {
      // Local session is cleared regardless — see AuthRepository.logout.
    } finally {
      emit(const AuthState(status: AuthStatus.loggedOut));
    }
  }

  Future<void> fetchMe() async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final me = await _repository.getMe();
      emit(state.copyWith(
        status: AuthStatus.profileLoaded,
        roles: me.roles,
        permissions: me.permissions,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(status: AuthStatus.failure, errorMessage: e.message));
    }
  }
}