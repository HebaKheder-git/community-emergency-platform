// lib/screens/edit_profile_screen.dart
//
// Edit Profile screen — shown when "Edit profile" is tapped in SettingsScreen.
// Features:
//  • Circular avatar with camera-icon overlay; tapping opens image picker
//    (gallery or camera). Falls back to a person icon when no image is set.
//  • Editable: First Name, Last Name, Date of Birth (bottom-sheet date picker)
//  • Read-only display: My Roles (with icons), Rescue Counter,
//    My Certificates, My Ratings (star row + count)
//  • "Save changes" primary button at the bottom
//  • Fully scrollable, matches the Figma design exactly

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import '../widgets/primary_button.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Simple value objects / mock data
// (Replace with real user model / Qubit state when backend is wired)
// ─────────────────────────────────────────────────────────────────────────────

class _UserRole {
  final IconData icon;
  final String label;
  const _UserRole(this.icon, this.label);
}

const List<_UserRole> _mockRoles = [
  _UserRole(Icons.medical_services_outlined, 'Rescuer'),
  _UserRole(Icons.article_outlined, 'Article publisher'),
];

const int _mockRescueCounter = 17;
const String _mockCertificates = 'None';
const double _mockRating = 3.5; // out of 5
const int _mockRatingCount = 19;

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // ── State ──────────────────────────────────────────────────────────────────
  File? _avatarFile; // null = no photo yet → show icon
  final _firstNameController = TextEditingController(text: 'Melissa');
  final _lastNameController = TextEditingController(text: 'Peters');
  DateTime _dob = DateTime(1995, 5, 23);
  bool _isSaving = false;

  // ── Image picker ───────────────────────────────────────────────────────────
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
              leading: const Icon(Icons.photo_library_outlined,
                  color: AppColors.primaryRed),
              title: const Text('Choose from gallery'),
              onTap: () async {
                Navigator.pop(ctx);
                final picked = await picker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 85,
                );
                if (picked != null) {
                  setState(() => _avatarFile = File(picked.path));
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined,
                  color: AppColors.primaryRed),
              title: const Text('Take a photo'),
              onTap: () async {
                Navigator.pop(ctx);
                final picked = await picker.pickImage(
                  source: ImageSource.camera,
                  imageQuality: 85,
                );
                if (picked != null) {
                  setState(() => _avatarFile = File(picked.path));
                }
              },
            ),
            if (_avatarFile != null)
              ListTile(
                leading: const Icon(Icons.delete_outline,
                    color: AppColors.primaryRed),
                title: const Text(
                  'Remove photo',
                  style: TextStyle(color: AppColors.primaryRed),
                ),
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

  // ── Save ───────────────────────────────────────────────────────────────────
  Future<void> _save() async {
    setState(() => _isSaving = true);
    // TODO: call Qubit / backend save API
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _isSaving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Profile updated successfully'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    Navigator.pop(context);
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  String get _formattedDob =>
      '${_dob.day.toString().padLeft(2, '0')}/'
      '${_dob.month.toString().padLeft(2, '0')}/'
      '${_dob.year}';

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: Column(
          children: [
            // ── App bar ──────────────────────────────────────────────────────
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
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
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
            ),

            // ── Scrollable body ──────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Avatar ───────────────────────────────────────────────
                    Center(
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // Circle avatar
                          Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF3D3B8E),
                                width: 2.5,
                              ),
                              color: const Color(0xFFE8E8E8),
                            ),
                            child: ClipOval(
                              child: _avatarFile != null
                                  ? Image.file(
                                      _avatarFile!,
                                      fit: BoxFit.cover,
                                      width: 110,
                                      height: 110,
                                    )
                                  : const Icon(
                                      Icons.person_rounded,
                                      size: 64,
                                      color: AppColors.textGrey,
                                    ),
                            ),
                          ),

                          // Camera badge
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
                                  border: Border.all(
                                      color: Colors.white, width: 2),
                                ),
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── First Name ───────────────────────────────────────────
                    _FieldLabel('First Name'),
                    const SizedBox(height: 8),
                    _EditableField(controller: _firstNameController),

                    const SizedBox(height: 20),

                    // ── Last Name ────────────────────────────────────────────
                    _FieldLabel('Last Name'),
                    const SizedBox(height: 8),
                    _EditableField(controller: _lastNameController),

                    const SizedBox(height: 20),

                    // ── Date of Birth ────────────────────────────────────────
                    _FieldLabel('Date of Birth'),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _pickDate,
                      child: _ReadOnlyField(
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formattedDob,
                              style: const TextStyle(
                                fontSize: 16,
                                color: AppColors.textDark,
                              ),
                            ),
                            const Icon(Icons.keyboard_arrow_down_rounded,
                                color: AppColors.textDark, size: 24),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── My Roles ─────────────────────────────────────────────
                    _FieldLabel('My Roles'),
                    const SizedBox(height: 8),
                    _ReadOnlyField(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _mockRoles
                            .map(
                              (r) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  children: [
                                    Icon(r.icon,
                                        size: 20,
                                        color: AppColors.textDark),
                                    const SizedBox(width: 10),
                                    Text(
                                      r.label,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: AppColors.textDark,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Rescue Counter ────────────────────────────────────────
                    _FieldLabel('Rescue Counter'),
                    const SizedBox(height: 8),
                    _ReadOnlyField(
                      child: Text(
                        '$_mockRescueCounter',
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── My certificates ───────────────────────────────────────
                    _FieldLabel('My certificates'),
                    const SizedBox(height: 8),
                    _ReadOnlyField(
                      child: Text(
                        _mockCertificates,
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.hintGrey,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── My ratings ────────────────────────────────────────────
                    _FieldLabel('My ratings'),
                    const SizedBox(height: 8),
                    _ReadOnlyField(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _StarRow(rating: _mockRating),
                          Text(
                            '$_mockRatingCount ratings',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textGrey,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 36),

                    // ── Save button ───────────────────────────────────────────
                    PrimaryButton(
                      label: 'Save changes',
                      onPressed: _save,
                      isLoading: _isSaving,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private helper widgets
// ─────────────────────────────────────────────────────────────────────────────

/// Bold field label (e.g. "First Name").
class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: AppColors.textDark,
      ),
    );
  }
}

/// White rounded editable text field.
class _EditableField extends StatelessWidget {
  final TextEditingController controller;
  final String? hint;

  const _EditableField({required this.controller, this.hint});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(
          fontSize: 16,
          color: AppColors.textDark,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.hintGrey),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

/// White rounded read-only container for non-editable info fields.
class _ReadOnlyField extends StatelessWidget {
  final Widget child;
  const _ReadOnlyField({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: child,
    );
  }
}

/// Renders a row of up to 5 stars for a given [rating] (supports half-stars).
class _StarRow extends StatelessWidget {
  final double rating; // e.g. 3.5
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
          filled
              ? Icons.star_rounded
              : half
                  ? Icons.star_half_rounded
                  : Icons.star_outline_rounded,
          color: const Color(0xFFFFBD00),
          size: size,
        );
      }),
    );
  }
}