import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/api_exception.dart';
import '../../models/trust_verification.dart';
import '../../repositories/trust_verification_repository.dart';
import 'trust_verification_state.dart';

/// Drives [VerificationPromptCard] (status display) and the submission /
/// edit / resubmit step of the verification flow (Step1 → Step2 →
/// submit()/resubmit() here → VerificationPendingScreen).
class TrustVerificationCubit extends Cubit<TrustVerificationState> {
  TrustVerificationCubit({TrustVerificationRepository? repository})
      : _repository = repository ?? TrustVerificationRepository(),
        super(const TrustVerificationState());

  final TrustVerificationRepository _repository;

  /// GET /trust-verification/me — call on mount wherever the current
  /// status needs to be shown (e.g. VerificationPromptCard).
  Future<void> loadMine() async {
    emit(state.copyWith(status: TrustVerificationCubitStatus.loading));
    try {
      final data = await _repository.getMine();
      emit(state.copyWith(
        status: TrustVerificationCubitStatus.loaded,
        data: data,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: TrustVerificationCubitStatus.failure,
        errorMessage: e.message,
      ));
    }
  }

  /// First-time submission (POST /trust-verification).
  Future<void> submit({
    required String nationalId,
    required DateTime birthDate,
    required String idCardFrontPath,
    required String idCardBackPath,
    required String facePhotoPath,
  }) async {
    emit(state.copyWith(status: TrustVerificationCubitStatus.submitting));
    try {
      final data = await _repository.submit(
        nationalId: nationalId,
        birthDate: birthDate,
        idCardFrontPath: idCardFrontPath,
        idCardBackPath: idCardBackPath,
        facePhotoPath: facePhotoPath,
      );
      emit(state.copyWith(
        status: TrustVerificationCubitStatus.submitted,
        data: data,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: TrustVerificationCubitStatus.failure,
        errorMessage: e.message,
        fieldErrors: e.fieldErrors,
      ));
    }
  }

  /// Used both to edit a `pending` request and to resubmit after
  /// `rejected` (PUT-spoofed /trust-verification/me).
  Future<void> resubmit({
    required String nationalId,
    required DateTime birthDate,
    required String idCardFrontPath,
    required String idCardBackPath,
    required String facePhotoPath,
  }) async {
    emit(state.copyWith(status: TrustVerificationCubitStatus.submitting));
    try {
      final data = await _repository.resubmit(
        nationalId: nationalId,
        birthDate: birthDate,
        idCardFrontPath: idCardFrontPath,
        idCardBackPath: idCardBackPath,
        facePhotoPath: facePhotoPath,
      );
      emit(state.copyWith(
        status: TrustVerificationCubitStatus.submitted,
        data: data,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: TrustVerificationCubitStatus.failure,
        errorMessage: e.message,
        fieldErrors: e.fieldErrors,
      ));
    }
  }

  /// DELETE /trust-verification/me — only valid while `pending`.
  Future<void> deleteMine() async {
    emit(state.copyWith(status: TrustVerificationCubitStatus.deleting));
    try {
      await _repository.deleteMine();
      emit(state.copyWith(
        status: TrustVerificationCubitStatus.deleted,
        data: const TrustVerificationModel.none(),
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: TrustVerificationCubitStatus.failure,
        errorMessage: e.message,
      ));
    }
  }
}