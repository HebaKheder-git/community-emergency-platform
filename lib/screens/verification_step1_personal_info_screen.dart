import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../widgets/primary_button.dart';
import '../widgets/verification_step_indicator.dart';
import 'verification_step2_document_screen.dart';

/// Step 1 of 3 — collects First Name, Last Name, and Date of Birth.
/// The DOB hint text ("Your date of birth can only be changed once...") 
/// appears only after the user starts interacting with the DOB fields,
/// matching the difference between Figma images 2 and 3.
class VerificationStep1PersonalInfoScreen extends StatefulWidget {
  const VerificationStep1PersonalInfoScreen({super.key});

  @override
  State<VerificationStep1PersonalInfoScreen> createState() =>
      _VerificationStep1PersonalInfoScreenState();
}

class _VerificationStep1PersonalInfoScreenState
    extends State<VerificationStep1PersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _dayController = TextEditingController();
  final _monthController = TextEditingController();
  final _yearController = TextEditingController();

  final _dayFocus = FocusNode();
  final _monthFocus = FocusNode();
  final _yearFocus = FocusNode();

  bool _dobTouched = false; // shows the DOB warning once any DOB field is touched

  @override
  void initState() {
    super.initState();
    _dayFocus.addListener(_onDobFocusChange);
    _monthFocus.addListener(_onDobFocusChange);
    _yearFocus.addListener(_onDobFocusChange);
  }

  void _onDobFocusChange() {
    if (_dayFocus.hasFocus || _monthFocus.hasFocus || _yearFocus.hasFocus) {
      if (!_dobTouched) setState(() => _dobTouched = true);
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dayController.dispose();
    _monthController.dispose();
    _yearController.dispose();
    _dayFocus.dispose();
    _monthFocus.dispose();
    _yearFocus.dispose();
    super.dispose();
  }

  bool get _canProceed {
    return _firstNameController.text.trim().isNotEmpty &&
        _lastNameController.text.trim().isNotEmpty &&
        _dayController.text.trim().isNotEmpty &&
        _monthController.text.trim().isNotEmpty &&
        _yearController.text.trim().length == 4;
  }

  void _onNextPressed() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const VerificationStep2DocumentScreen(),
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
                child: Form(
                  key: _formKey,
                  onChanged: () => setState(() {}),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Step indicator
                      const VerificationStepIndicator(currentStep: 1),
                      const SizedBox(height: 32),

                      // ── First Name ──────────────────────────────────────
                      const Text('First Name', style: _labelStyle),
                      const SizedBox(height: 8),
                      _buildNameField(
                        controller: _firstNameController,
                        hint: 'Your name',
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Please enter your first name'
                            : null,
                      ),
                      const SizedBox(height: 6),
                      _buildNameWarning(),
                      const SizedBox(height: 20),

                      // ── Last Name ───────────────────────────────────────
                      const Text('Last Name', style: _labelStyle),
                      const SizedBox(height: 8),
                      _buildNameField(
                        controller: _lastNameController,
                        hint: 'Your name',
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Please enter your last name'
                            : null,
                      ),
                      const SizedBox(height: 6),
                      _buildNameWarning(),
                      const SizedBox(height: 20),

                      // ── Date of Birth ────────────────────────────────────
                      const Text('Date Of Birth', style: _labelStyle),
                      const SizedBox(height: 8),
                      _buildDobRow(),
                      const SizedBox(height: 6),

                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: _dobTouched
                            ? _buildInfoText(
                                key: const ValueKey('dob_warning'),
                                text: 'Your date of birth can only be changed ',
                                bold: 'once',
                                suffix: ' after verification. Enter it carefully!',
                              )
                            : const SizedBox.shrink(key: ValueKey('dob_empty')),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),

            // ── Sticky Next button ──────────────────────────────────────────
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

  // ── Helpers ────────────────────────────────────────────────────────────────

  Widget _buildNameField({
    required TextEditingController controller,
    required String hint,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      style: AppTextStyles.inputText,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.hint,
        filled: true,
        fillColor: AppColors.background,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: AppColors.borderGrey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: AppColors.borderGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide:
              const BorderSide(color: AppColors.primaryRed, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildNameWarning() {
    return _buildInfoText(
      text: 'Your name can only be changed ',
      bold: 'once',
      suffix: ' after verification. Enter it carefully!',
    );
  }

  Widget _buildInfoText({
    Key? key,
    required String text,
    required String bold,
    required String suffix,
  }) {
    return Row(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 2),
          child: Icon(Icons.info_outline,
              size: 14, color: AppColors.textGrey),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textGrey, height: 1.4),
              children: [
                TextSpan(text: text),
                TextSpan(
                  text: bold,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(text: suffix),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDobRow() {
    return Row(
      children: [
        // Day
        _DobBox(
          controller: _dayController,
          focusNode: _dayFocus,
          hint: 'DD',
          maxLength: 2,
          onChanged: (_) {
            if (_dayController.text.length == 2) {
              FocusScope.of(context).requestFocus(_monthFocus);
            }
            setState(() {});
          },
        ),
        const SizedBox(width: 12),
        // Month
        _DobBox(
          controller: _monthController,
          focusNode: _monthFocus,
          hint: 'MM',
          maxLength: 2,
          onChanged: (_) {
            if (_monthController.text.length == 2) {
              FocusScope.of(context).requestFocus(_yearFocus);
            }
            setState(() {});
          },
        ),
        const SizedBox(width: 12),
        // Year — wider
        _DobBox(
          controller: _yearController,
          focusNode: _yearFocus,
          hint: 'YYYY',
          maxLength: 4,
          flex: 2,
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }
}

// ── Sub-widget: individual DOB box ─────────────────────────────────────────

class _DobBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final int maxLength;
  final int flex;
  final ValueChanged<String>? onChanged;

  const _DobBox({
    required this.controller,
    required this.focusNode,
    required this.hint,
    required this.maxLength,
    this.flex = 1,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: maxLength,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: onChanged,
        style: AppTextStyles.inputText,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.hint.copyWith(fontSize: 14),
          counterText: '',
          filled: true,
          fillColor: AppColors.background,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.borderGrey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.borderGrey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                const BorderSide(color: AppColors.primaryRed, width: 1.5),
          ),
        ),
      ),
    );
  }
}

// ── Text style constant ─────────────────────────────────────────────────────
const TextStyle _labelStyle = TextStyle(
  fontSize: 17,
  fontWeight: FontWeight.w700,
  color: AppColors.textDark,
);