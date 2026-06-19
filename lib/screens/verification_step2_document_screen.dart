import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import '../widgets/primary_button.dart';
import '../widgets/verification_step_indicator.dart';
import 'verification_step3_location_screen.dart';

/// Step 2 of 3 — user picks a document type (ID Card / Passport / Driver's
/// License) and uploads front & back images. Switching document types resets
/// the uploads but keeps the selection interactive. Only ONE document type
/// needs to be filled to enable "Next".
class VerificationStep2DocumentScreen extends StatefulWidget {
  const VerificationStep2DocumentScreen({super.key});

  @override
  State<VerificationStep2DocumentScreen> createState() =>
      _VerificationStep2DocumentScreenState();
}

enum _DocType { idCard, passport, driversLicense }

class _VerificationStep2DocumentScreenState
    extends State<VerificationStep2DocumentScreen> {
  _DocType? _selectedDoc;
  File? _frontImage;
  File? _backImage;

  final _picker = ImagePicker();

  bool get _canProceed =>
      _selectedDoc != null &&
      (_frontImage != null || _backImage != null);

  Future<void> _pickImage(bool isFront) async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    setState(() {
      if (isFront) {
        _frontImage = File(picked.path);
      } else {
        _backImage = File(picked.path);
      }
    });
  }

  void _onDocSelected(_DocType type) {
    if (_selectedDoc == type) return;
    setState(() {
      _selectedDoc = type;
      _frontImage = null;
      _backImage = null;
    });
  }

  void _onNextPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const VerificationStep3LocationScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Step indicator — step 1 done, step 2 active
                    const VerificationStepIndicator(currentStep: 2),
                    const SizedBox(height: 28),

                    // ── Document type label ─────────────────────────────
                    const Text(
                      'Document Type',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.hintGrey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── Document type options ───────────────────────────
                    _DocTypeOption(
                      label: 'ID Card',
                      icon: Icons.badge_outlined,
                      isSelected: _selectedDoc == _DocType.idCard,
                      onTap: () => _onDocSelected(_DocType.idCard),
                    ),
                    const SizedBox(height: 10),
                    _DocTypeOption(
                      label: 'Passport',
                      icon: Icons.language_outlined,
                      isSelected: _selectedDoc == _DocType.passport,
                      onTap: () => _onDocSelected(_DocType.passport),
                    ),
                    const SizedBox(height: 10),
                    _DocTypeOption(
                      label: "Driver's License",
                      icon: Icons.drive_eta_outlined,
                      isSelected: _selectedDoc == _DocType.driversLicense,
                      onTap: () => _onDocSelected(_DocType.driversLicense),
                    ),

                    // ── Upload boxes — animate in when a doc is chosen ──
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      transitionBuilder: (child, animation) =>
                          FadeTransition(opacity: animation, child: child),
                      child: _selectedDoc != null
                          ? Padding(
                              key: ValueKey(_selectedDoc),
                              padding: const EdgeInsets.only(top: 24),
                              child: Column(
                                children: [
                                  _ImageUploadBox(
                                    label: 'Tap to upload front side',
                                    imageFile: _frontImage,
                                    onTap: () => _pickImage(true),
                                  ),
                                  const SizedBox(height: 16),
                                  _ImageUploadBox(
                                    label: 'Tap to upload back side',
                                    imageFile: _backImage,
                                    onTap: () => _pickImage(false),
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // ── Sticky Next button ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                0,
                AppSpacing.screenPadding,
                24,
              ),
              child: PrimaryButton(
                label: 'Next',
                enabled: _canProceed,
                onPressed: _onNextPressed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Document type pill ──────────────────────────────────────────────────────

class _DocTypeOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _DocTypeOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color:
                isSelected ? AppColors.primaryRed : AppColors.borderGrey,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color:
                  isSelected ? AppColors.primaryRed : AppColors.textDark,
            ),
            const SizedBox(width: 14),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color:
                    isSelected ? AppColors.primaryRed : AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Dashed upload box ───────────────────────────────────────────────────────

class _ImageUploadBox extends StatelessWidget {
  final String label;
  final File? imageFile;
  final VoidCallback onTap;

  const _ImageUploadBox({
    required this.label,
    required this.imageFile,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.hintGrey,
            width: 1.5,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
          // Dashed effect via a CustomPainter fallback or via DashedBorder
          // Using the standard Border here; for true dashes see DashedBorder package.
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(11),
          child: imageFile != null
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(imageFile!, fit: BoxFit.cover),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: onTap,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.primaryRed,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit,
                              color: Colors.white, size: 14),
                        ),
                      ),
                    ),
                  ],
                )
              : _EmptyUploadContent(label: label),
        ),
      ),
    );
  }
}

class _EmptyUploadContent extends StatelessWidget {
  final String label;
  const _EmptyUploadContent({required this.label});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.image_outlined,
              size: 32,
              color: AppColors.textDark,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTextStyles.inputText,
            ),
            const SizedBox(height: 10),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderGrey),
              ),
              child: const Text(
                'Browse',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textGrey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Paints the dashed border seen in the Figma design
class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const dashWidth = 8.0;
    const dashSpace = 6.0;
    const strokeWidth = 1.5;
    const radius = 12.0;

    final paint = Paint()
      ..color = AppColors.hintGrey
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(1, 1, size.width - 2, size.height - 2),
          const Radius.circular(radius),
        ),
      );

    final pathMetrics = path.computeMetrics().toList();
    for (final metric in pathMetrics) {
      double distance = 0;
      bool draw = true;
      while (distance < metric.length) {
        final segmentEnd =
            (distance + (draw ? dashWidth : dashSpace)).clamp(0, metric.length);
        if (draw) {
          canvas.drawPath(
            metric.extractPath(distance, segmentEnd.toDouble()),
            paint,
          );
        }
        distance = segmentEnd.toDouble();
        draw = !draw;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}