// lib/screens/edit_profile_screen.dart
//
// Edit Profile screen — shown when "Edit profile" is tapped in SettingsScreen.
//
// LINKED TO:
//   - GET / POST / PATCH /profile               via ProfileCubit + ProfileRepository
//   - GET / PUT / PATCH /profile/location        via LocationCubit + LocationRepository   (NEW)
//   - PATCH /profile/location/visibility         via LocationCubit                          (NEW)
//
// Shared fields (identical for verified & unverified users, per spec):
//   • Avatar              — upload via image picker, sent as multipart.
//   • First Name/Last Name — READ-ONLY. There is no backend endpoint to
//     update the account's name (only /auth/register sets it once), so
//     these are display-only until such an endpoint exists. Flagged for
//     Yosef — see the linking notes sent alongside this file.
//   • Date of Birth       → profile.birth_date
//   • Phone               → profile.phone (created empty at sign-up,
//                            filled in here per the scenario Q&A)
//   • Gender              → profile.gender             (NEW, per Q&A)
//   • Bio                 → profile.bio                (NEW, per Q&A)
//
// VERIFIED users additionally see:
//   • My Location          — Country, State/Governorate, City, and a
//     read-only Latitude/Longitude caption filled in either by tapping
//     "Use map" (LocationMapPicker) or by typing the text fields directly.
//     Saved via LocationCubit.saveLocation, which calls PUT the first time
//     (no previous coordinates) or PATCH afterwards.                (NEW)
//   • Show my location to other users — moved here from the shared
//     section, since it's only meaningful once a verified user actually
//     has a location saved. Applied immediately via
//     LocationCubit.setVisibility (PATCH /profile/location/visibility),
//     not batched into "Save changes".                                (MOVED)
//   • My Roles, Rescue Counter, My Certificates, My Ratings (read-only) —
//     certificates/ratings are still mocked, there's no backend data for
//     those in this collection yet.
// UNVERIFIED users see the shared VerificationPromptCard instead, and do
// NOT see the location section or the show/hide toggle at all.
//
// "Save changes" now saves the shared profile fields (via ProfileCubit)
// and — only for verified users, only if a location has been picked —
// the location fields (via LocationCubit) in the same tap.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import '../theme/app_theme.dart';
import '../widgets/primary_button.dart';
import '../widgets/verification_prompt_card.dart';
import '../widgets/location_map_picker.dart';
import '../services/verification_status.dart';
import '../cubits/profile/profile_cubit.dart';
import '../cubits/profile/profile_state.dart';
import '../cubits/location/location_cubit.dart';
import '../cubits/location/location_state.dart';
import '../models/profile.dart';
import '../models/location.dart';

// Certificates & ratings have no backend endpoint yet — still mocked.
const String _mockCertificates = 'None';
const double _mockRating = 3.5; // out of 5
const int _mockRatingCount = 19;

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final ProfileCubit _profileCubit;
  late final LocationCubit _locationCubit;
  bool _hydrated = false; // guards against overwriting user edits on rebuild
  bool _locationHydrated = false; // same guard, for the location section

  File? _avatarFile;
  String? _existingAvatarUrl;

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();

  // ── Location (verified users only) ────────────────────────────────────
  final _countryController = TextEditingController();
  final _governorateController = TextEditingController(); // "State/Governorate"
  final _cityController = TextEditingController();
  double? _latitude;
  double? _longitude;
  bool _isLocationPublic = false;

  DateTime _dob = DateTime(2000, 1, 1);
  String? _gender;

  List<String> _roles = [];
  int _rescueCount = 0;

  @override
  void initState() {
    super.initState();
    _profileCubit = ProfileCubit()..loadProfile();
    _locationCubit = LocationCubit()..loadLocation();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _countryController.dispose();
    _governorateController.dispose();
    _cityController.dispose();
    _profileCubit.close();
    _locationCubit.close();
    super.dispose();
  }

  // Populates local editable state from the fetched profile — only once
  // on initial load, so it doesn't stomp on edits the user is mid-typing.
  // Re-runs after a successful save to reflect the server's saved truth.
  void _hydrateFrom(ProfileModel profile) {
    final parts = profile.name?.trim().split(RegExp(r'\s+')) ?? [];
    _firstNameController.text = parts.isNotEmpty ? parts.first : '';
    _lastNameController.text = parts.length > 1 ? parts.sublist(1).join(' ') : '';
    _phoneController.text = profile.phone ?? '';
    _bioController.text = profile.bio ?? '';
    _gender = profile.gender;
    _dob = profile.birthDate ?? _dob;
    _existingAvatarUrl = profile.avatarUrl;
    _roles = profile.roles;
    _rescueCount = profile.rescueCount ?? 0;
  }

  // Populates the location section from GET /profile/location. Only once
  // on initial load; re-runs after a successful save/visibility change.
  void _hydrateLocationFrom(LocationModel location) {
    _countryController.text = location.country ?? '';
    _governorateController.text = location.governorate ?? '';
    _cityController.text = location.city ?? '';
    _latitude = location.latitude;
    _longitude = location.longitude;
    _isLocationPublic = location.isLocationPublic;
  }

  IconData _iconForRole(String role) {
    switch (role) {
      case 'rescuer':
        return Icons.medical_services_outlined;
      case 'trusted':
        return Icons.verified_user_outlined;
      default:
        return Icons.badge_outlined;
    }
  }

  String _labelForRole(String role) {
    switch (role) {
      case 'rescuer':
        return 'Rescuer';
      case 'trusted':
        return 'Trusted member';
      default:
        return role.isEmpty ? role : role[0].toUpperCase() + role.substring(1);
    }
  }

  // ── Image picker ──────────────────────────────────────────────────────────
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderGrey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Change profile photo',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: AppColors.primaryRed),
              title: const Text('Choose from gallery'),
              onTap: () async {
                Navigator.pop(ctx);
                final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
                if (picked != null) setState(() => _avatarFile = File(picked.path));
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined, color: AppColors.primaryRed),
              title: const Text('Take a photo'),
              onTap: () async {
                Navigator.pop(ctx);
                final picked = await picker.pickImage(source: ImageSource.camera, imageQuality: 85);
                if (picked != null) setState(() => _avatarFile = File(picked.path));
              },
            ),
            if (_avatarFile != null)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: AppColors.primaryRed),
                title: const Text('Remove photo', style: TextStyle(color: AppColors.primaryRed)),
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() => _avatarFile = null);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ── Date picker ────────────────────────────────────────────────────────────
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob,
      firstDate: DateTime(1920),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 10)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primaryRed,
            onPrimary: Colors.white,
            onSurface: AppColors.textDark,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _dob = picked);
  }

  // ── Location: map picker sheet ──────────────────────────────────────────
  // Opens LocationMapPicker in a bottom sheet. Whatever point the user
  // taps/searches/GPS-tracks fills the Country/State/City fields below and
  // the read-only Latitude/Longitude caption. Nothing is sent to the
  // backend yet — that happens on "Save changes".
  Future<void> _openLocationPicker() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderGrey,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Pick your location',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textDark),
              ),
              const SizedBox(height: 12),
              LocationMapPicker(
                height: 260,
                initialPosition: (_latitude != null && _longitude != null)
                    ? LatLng(_latitude!, _longitude!)
                    : null,
                onLocationPicked: (loc) {
                  setState(() {
                    _latitude = loc.latitude;
                    _longitude = loc.longitude;
                    _countryController.text = loc.country;
                    _governorateController.text = loc.state;
                    _cityController.text = loc.city;
                  });
                },
              ),
              const SizedBox(height: 16),
              PrimaryButton(label: 'Done', onPressed: () => Navigator.pop(ctx)),
            ],
          ),
        ),
      ),
    );
  }

  // ── Location: show/hide toggle ──────────────────────────────────────────
  // Applied immediately (PATCH /profile/location/visibility) rather than
  // waiting for "Save changes" — it's a standalone setting, not a profile
  // field. Reverts optimistically on failure.
  Future<void> _onVisibilityChanged(bool value) async {
    final previous = _isLocationPublic;
    setState(() => _isLocationPublic = value);
    await _locationCubit.setVisibility(value);
    if (!mounted) return;
    if (_locationCubit.state.status == LocationStatus.failure) {
      setState(() => _isLocationPublic = previous);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_locationCubit.state.errorMessage ?? 'Could not update visibility.')),
      );
    }
  }

  // ── Save (everyone — see header note) ─────────────────────────────────────
  void _save() {
    _profileCubit.saveProfile(
      phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      gender: _gender,
      bio: _bioController.text.trim(),
      birthDate: _dob,
      avatar: _avatarFile,
    );

    // Location is verified-only and only worth sending once a point has
    // actually been picked (lat/lng required by PUT/PATCH /profile/location).
    final isVerified = VerificationStatus.instance.isVerified.value;
    if (isVerified && _latitude != null && _longitude != null) {
      _locationCubit.saveLocation(
        latitude: _latitude!,
        longitude: _longitude!,
        country: _countryController.text.trim(),
        governorate: _governorateController.text.trim(),
        city: _cityController.text.trim(),
      );
    }
  }

  String get _formattedDob =>
      '${_dob.day.toString().padLeft(2, '0')}/${_dob.month.toString().padLeft(2, '0')}/${_dob.year}';

  String get _formattedCoordinates => (_latitude != null && _longitude != null)
      ? '${_latitude!.toStringAsFixed(5)}, ${_longitude!.toStringAsFixed(5)}'
      : 'Not set';

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _profileCubit),
        BlocProvider.value(value: _locationCubit),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<ProfileCubit, ProfileState>(
            listener: (context, state) {
              if (state.status == ProfileStatus.loaded && state.profile != null && !_hydrated) {
                _hydrated = true;
                setState(() => _hydrateFrom(state.profile!));
              } else if (state.status == ProfileStatus.saved && state.profile != null) {
                setState(() {
                  _hydrateFrom(state.profile!);
                  _avatarFile = null;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Profile updated successfully'),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
                Navigator.pop(context);
              } else if (state.status == ProfileStatus.failure && state.errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.errorMessage!)),
                );
              }
            },
          ),
          BlocListener<LocationCubit, LocationState>(
            listener: (context, state) {
              if (state.status == LocationStatus.loaded && state.location != null && !_locationHydrated) {
                _locationHydrated = true;
                setState(() => _hydrateLocationFrom(state.location!));
              } else if (state.status == LocationStatus.saved && state.location != null) {
                setState(() => _hydrateLocationFrom(state.location!));
              } else if (state.status == LocationStatus.failure && state.errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.errorMessage!)),
                );
              }
            },
          ),
        ],
        child: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            final isLoadingProfile =
                (state.status == ProfileStatus.initial || state.status == ProfileStatus.loading) &&
                    state.profile == null;

            return BlocBuilder<LocationCubit, LocationState>(
              builder: (context, locState) {
                final isSaving =
                    state.status == ProfileStatus.saving || locState.status == LocationStatus.saving;

                return Scaffold(
                  backgroundColor: const Color(0xFFF2F2F2),
                  body: SafeArea(
                    child: Column(
                      children: [
                        // ── App bar ──────────────────────────────────────────────
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: IconButton(
                                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                                      color: AppColors.textDark, size: 22),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ),
                              const Text(
                                'Edit Profile',
                                style: TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textDark),
                              ),
                            ],
                          ),
                        ),

                        if (isLoadingProfile)
                          const Expanded(child: Center(child: CircularProgressIndicator()))
                        else
                          Expanded(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // ── Avatar ──────────────────────────── SHARED
                                  Center(
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        Container(
                                          width: 110,
                                          height: 110,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(color: const Color(0xFF3D3B8E), width: 2.5),
                                            color: const Color(0xFFE8E8E8),
                                          ),
                                          child: ClipOval(
                                            child: _avatarFile != null
                                                ? Image.file(_avatarFile!,
                                                    fit: BoxFit.cover, width: 110, height: 110)
                                                : (_existingAvatarUrl != null
                                                    ? Image.network(
                                                        _existingAvatarUrl!,
                                                        fit: BoxFit.cover,
                                                        width: 110,
                                                        height: 110,
                                                        errorBuilder: (_, __, ___) => const Icon(
                                                          Icons.person_rounded,
                                                          size: 64,
                                                          color: AppColors.textGrey,
                                                        ),
                                                      )
                                                    : const Icon(Icons.person_rounded,
                                                        size: 64, color: AppColors.textGrey)),
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 2,
                                          right: 2,
                                          child: GestureDetector(
                                            onTap: _pickImage,
                                            child: Container(
                                              width: 34,
                                              height: 34,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF3D3B8E),
                                                shape: BoxShape.circle,
                                                border: Border.all(color: Colors.white, width: 2),
                                              ),
                                              child: const Icon(Icons.camera_alt_rounded,
                                                  color: Colors.white, size: 18),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 28),

                                  // ── First / Last Name ─────── SHARED, READ-ONLY
                                  _FieldLabel('First Name'),
                                  const SizedBox(height: 8),
                                  _ReadOnlyField(
                                    child: Text(_firstNameController.text.isEmpty
                                        ? '—'
                                        : _firstNameController.text),
                                  ),

                                  const SizedBox(height: 20),

                                  _FieldLabel('Last Name'),
                                  const SizedBox(height: 8),
                                  _ReadOnlyField(
                                    child: Text(
                                        _lastNameController.text.isEmpty ? '—' : _lastNameController.text),
                                  ),

                                  const SizedBox(height: 20),

                                  // ── Date of Birth ─────────────────────── SHARED
                                  _FieldLabel('Date of Birth'),
                                  const SizedBox(height: 8),
                                  GestureDetector(
                                    onTap: _pickDate,
                                    child: _ReadOnlyField(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(_formattedDob,
                                              style: const TextStyle(fontSize: 16, color: AppColors.textDark)),
                                          const Icon(Icons.keyboard_arrow_down_rounded,
                                              color: AppColors.textDark, size: 24),
                                        ],
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 20),

                                  // ── Phone ────────────────────────── SHARED (NEW)
                                  _FieldLabel('Phone Number'),
                                  const SizedBox(height: 8),
                                  _EditableField(
                                    controller: _phoneController,
                                    hint: 'Add a phone number',
                                    keyboardType: TextInputType.phone,
                                  ),

                                  const SizedBox(height: 20),

                                  // ── Gender ───────────────────────── SHARED (NEW)
                                  _FieldLabel('Gender'),
                                  const SizedBox(height: 8),
                                  _GenderSelector(
                                    value: _gender,
                                    onChanged: (g) => setState(() => _gender = g),
                                  ),

                                  const SizedBox(height: 20),

                                  // ── Bio ──────────────────────────── SHARED (NEW)
                                  _FieldLabel('Bio'),
                                  const SizedBox(height: 8),
                                  _EditableField(
                                    controller: _bioController,
                                    hint: 'Tell others about yourself',
                                    maxLines: 4,
                                  ),

                                  const SizedBox(height: 20),

                                  // ── Below this point content diverges by
                                  //    verification status. Location + visibility
                                  //    now live ONLY inside the verified branch.
                                  ValueListenableBuilder<bool>(
                                    valueListenable: VerificationStatus.instance.isVerified,
                                    builder: (context, isVerified, _) {
                                      if (!isVerified) {
                                        return const Padding(
                                          padding: EdgeInsets.only(top: 12),
                                          child: VerificationPromptCard(),
                                        );
                                      }

                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // ── My Location ─────── VERIFIED ONLY (NEW)
                                          _FieldLabel('My Location'),
                                          const SizedBox(height: 8),
                                          _ReadOnlyField(
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    _formattedCoordinates,
                                                    style: const TextStyle(
                                                        fontSize: 14, color: AppColors.textGrey),
                                                  ),
                                                ),
                                                TextButton.icon(
                                                  onPressed: _openLocationPicker,
                                                  icon: const Icon(Icons.map_outlined,
                                                      size: 18, color: AppColors.primaryRed),
                                                  label: const Text('Use map',
                                                      style: TextStyle(color: AppColors.primaryRed)),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          _EditableField(
                                            controller: _countryController,
                                            hint: 'Country',
                                          ),
                                          const SizedBox(height: 10),
                                          _EditableField(
                                            controller: _governorateController,
                                            hint: 'State / Governorate',
                                          ),
                                          const SizedBox(height: 10),
                                          _EditableField(
                                            controller: _cityController,
                                            hint: 'City',
                                          ),

                                          const SizedBox(height: 16),

                                          // ── Show/hide location ─── VERIFIED ONLY (MOVED)
                                          _ReadOnlyField(
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                const Expanded(
                                                  child: Text(
                                                    'Show my location to other users',
                                                    style: TextStyle(fontSize: 15, color: AppColors.textDark),
                                                  ),
                                                ),
                                                Switch(
                                                  value: _isLocationPublic,
                                                  activeColor: AppColors.primaryRed,
                                                  onChanged: _onVisibilityChanged,
                                                ),
                                              ],
                                            ),
                                          ),

                                          const SizedBox(height: 20),

                                          _FieldLabel('My Roles'),
                                          const SizedBox(height: 8),
                                          _ReadOnlyField(
                                            child: _roles.isEmpty
                                                ? const Text('No roles yet',
                                                    style: TextStyle(color: AppColors.hintGrey))
                                                : Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: _roles
                                                        .map(
                                                          (role) => Padding(
                                                            padding:
                                                                const EdgeInsets.symmetric(vertical: 4),
                                                            child: Row(
                                                              children: [
                                                                Icon(_iconForRole(role),
                                                                    size: 20, color: AppColors.textDark),
                                                                const SizedBox(width: 10),
                                                                Text(_labelForRole(role),
                                                                    style: const TextStyle(
                                                                        fontSize: 15,
                                                                        color: AppColors.textDark)),
                                                              ],
                                                            ),
                                                          ),
                                                        )
                                                        .toList(),
                                                  ),
                                          ),
                                          const SizedBox(height: 20),
                                          _FieldLabel('Rescue Counter'),
                                          const SizedBox(height: 8),
                                          _ReadOnlyField(
                                            child: Text('$_rescueCount',
                                                style: const TextStyle(fontSize: 16, color: AppColors.textDark)),
                                          ),
                                          const SizedBox(height: 20),
                                          _FieldLabel('My certificates'),
                                          const SizedBox(height: 8),
                                          _ReadOnlyField(
                                            child: Text(_mockCertificates,
                                                style: const TextStyle(fontSize: 16, color: AppColors.hintGrey)),
                                          ),
                                          const SizedBox(height: 20),
                                          _FieldLabel('My ratings'),
                                          const SizedBox(height: 8),
                                          _ReadOnlyField(
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                const _StarRow(rating: _mockRating),
                                                Text('$_mockRatingCount ratings',
                                                    style: const TextStyle(
                                                        fontSize: 14, color: AppColors.textGrey)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),

                                  const SizedBox(height: 36),

                                  // ── Save changes ──────────────────── SHARED
                                  PrimaryButton(
                                    label: 'Save changes',
                                    onPressed: _save,
                                    isLoading: isSaving,
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private helper widgets
// ─────────────────────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark),
    );
  }
}

class _EditableField extends StatelessWidget {
  final TextEditingController controller;
  final String? hint;
  final TextInputType? keyboardType;
  final int maxLines;

  const _EditableField({
    required this.controller,
    this.hint,
    this.keyboardType,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(fontSize: 16, color: AppColors.textDark),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.hintGrey),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  final Widget child;
  const _ReadOnlyField({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: child,
    );
  }
}

/// Simple pill selector for gender. Postman's example body only shows
/// "male" — please confirm the full set of accepted values with Yosef;
/// adjust the `options` map below if "other" isn't accepted server-side.
class _GenderSelector extends StatelessWidget {
  final String? value;
  final ValueChanged<String> onChanged;
  const _GenderSelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const options = {'male': 'Male', 'female': 'Female', 'other': 'Other'};
    return Wrap(
      spacing: 10,
      children: options.entries.map((entry) {
        final selected = value == entry.key;
        return ChoiceChip(
          label: Text(entry.value),
          selected: selected,
          onSelected: (_) => onChanged(entry.key),
          selectedColor: AppColors.primaryRed,
          labelStyle: TextStyle(
            color: selected ? Colors.white : AppColors.textDark,
            fontWeight: FontWeight.w600,
          ),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.borderGrey),
          ),
        );
      }).toList(),
    );
  }
}

class _StarRow extends StatelessWidget {
  final double rating;
  final double size;
  const _StarRow({required this.rating, this.size = 26});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = rating >= i + 1;
        final half = !filled && rating >= i + 0.5;
        return Icon(
          filled ? Icons.star_rounded : (half ? Icons.star_half_rounded : Icons.star_outline_rounded),
          color: const Color(0xFFFFBD00),
          size: size,
        );
      }),
    );
  }
}