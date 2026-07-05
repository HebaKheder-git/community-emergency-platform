import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/api_exception.dart';
import '../../repositories/profile_repository.dart';
import 'profile_state.dart';

/// Drives EditProfileScreen.
class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({ProfileRepository? repository})
      : _repository = repository ?? ProfileRepository(),
        super(const ProfileState());

  final ProfileRepository _repository;

  /// GET /profile. Falls back to creating one if it somehow doesn't exist
  /// yet (e.g. the automatic creation right after sign-up failed because
  /// the user was offline at that moment).
  Future<void> loadProfile() async {
    emit(state.copyWith(status: ProfileStatus.loading));
    try {
      final profile = await _repository.getProfile() ?? await _repository.createProfile();
      emit(state.copyWith(status: ProfileStatus.loaded, profile: profile));
    } on ApiException catch (e) {
      emit(state.copyWith(status: ProfileStatus.failure, errorMessage: e.message));
    }
  }

  /// PATCH /profile.
  Future<void> saveProfile({
    String? phone,
    String? gender,
    String? bio,
    DateTime? birthDate,
    bool? isLocationPublic,
    File? avatar,
  }) async {
    emit(state.copyWith(status: ProfileStatus.saving));
    try {
      final updated = await _repository.updateProfile(
        phone: phone,
        gender: gender,
        bio: bio,
        birthDate: birthDate,
        isLocationPublic: isLocationPublic,
        avatar: avatar,
      );
      emit(state.copyWith(status: ProfileStatus.saved, profile: updated));
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: ProfileStatus.failure,
        errorMessage: e.message,
        fieldErrors: e.fieldErrors,
      ));
    }
  }
}