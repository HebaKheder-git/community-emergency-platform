import 'package:equatable/equatable.dart';
import '../../models/profile.dart';

enum ProfileStatus { initial, loading, loaded, saving, saved, failure }

class ProfileState extends Equatable {
  final ProfileStatus status;
  final ProfileModel? profile;
  final String? errorMessage;
  final Map<String, List<String>> fieldErrors;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.profile,
    this.errorMessage,
    this.fieldErrors = const {},
  });

  ProfileState copyWith({
    ProfileStatus? status,
    ProfileModel? profile,
    String? errorMessage,
    Map<String, List<String>>? fieldErrors,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      errorMessage: errorMessage,
      fieldErrors: fieldErrors ?? const {},
    );
  }

  @override
  List<Object?> get props => [status, profile, errorMessage, fieldErrors];
}