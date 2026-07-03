import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/primary_button.dart';
import '../widgets/verification_step_indicator.dart';
import '../widgets/location_map_picker.dart';
import 'verification_pending_screen.dart';

// ════════════════════════════════════════════════════════════════════════════
// Step 3 — Location Permission Gate (Image 8)
// Shows "Track yourself." prompt, then advances to the location selector.
// ════════════════════════════════════════════════════════════════════════════

class VerificationStep3LocationScreen extends StatelessWidget {
  const VerificationStep3LocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Step indicator — steps 1 & 2 done, step 3 active
              const VerificationStepIndicator(currentStep: 3),

              const Spacer(flex: 3),

              // Icon + copy
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Light-red circle with a location pin icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primaryRed.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.location_on_outlined,
                      size: 38,
                      color: AppColors.primaryRed,
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: const TextSpan(
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryRed,
                            ),
                            children: [
                              TextSpan(text: 'Track yourself'),
                              TextSpan(
                                text: '.',
                                style: TextStyle(color: AppColors.primaryRed),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Please allow location permission.',
                          style: AppTextStyles.subtitle,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const Spacer(flex: 4),

              // Allow button → navigates to the map / address picker.
              // The actual OS permission prompt now happens inside
              // LocationMapPicker as soon as that screen mounts.
              PrimaryButton(
                label: 'Allow',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const VerificationSelectLocationScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Step 3 — Select Location (Image 9)
// Search bar + real interactive map + editable address fields.
// ════════════════════════════════════════════════════════════════════════════

class VerificationSelectLocationScreen extends StatefulWidget {
  const VerificationSelectLocationScreen({super.key});

  @override
  State<VerificationSelectLocationScreen> createState() =>
      _VerificationSelectLocationScreenState();
}

class _VerificationSelectLocationScreenState
    extends State<VerificationSelectLocationScreen> {
  final _searchController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalController = TextEditingController();
  final _extraController = TextEditingController();

  // Lets us call methods (searchAddress) on the map widget from outside,
  // e.g. from the search bar's submit handler.
  final _mapKey = GlobalKey<LocationMapPickerState>();

  String get _formattedAddress =>
      '${_streetController.text}, ${_cityController.text}, ${_postalController.text}';

  @override
  void dispose() {
    _searchController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _postalController.dispose();
    _extraController.dispose();
    super.dispose();
  }

  void _onConfirmPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VerificationConfirmLocationScreen(
          address: _formattedAddress,
        ),
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
                    // Step indicator — steps 1 & 2 done, step 3 active
                    const VerificationStepIndicator(currentStep: 3),
                    const SizedBox(height: 24),

                    // Title
                    const Text(
                      'Select Location',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Search bar
                    TextField(
                      controller: _searchController,
                      style: AppTextStyles.inputText,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (value) =>
                          _mapKey.currentState?.searchAddress(value),
                      decoration: InputDecoration(
                        hintText: 'Search Address',
                        hintStyle: AppTextStyles.hint,
                        prefixIcon: GestureDetector(
                          onTap: () => _mapKey.currentState
                              ?.searchAddress(_searchController.text),
                          child: const Icon(Icons.search,
                              color: AppColors.hintGrey, size: 20),
                        ),
                        filled: true,
                        fillColor: AppColors.background,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide:
                              const BorderSide(color: AppColors.borderGrey),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide:
                              const BorderSide(color: AppColors.borderGrey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: const BorderSide(
                              color: AppColors.primaryRed, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── Real interactive map ─────────────────────────────
                    // Shows GPS position on load, lets the user tap to drop
                    // the pin elsewhere, and reverse-geocodes into the
                    // fields below via onLocationPicked.
                    LocationMapPicker(
                      key: _mapKey,
                      height: 160,
                      onLocationPicked: (loc) {
                        setState(() {
                          _streetController.text = loc.area;
                          _cityController.text = loc.city;
                          _postalController.text = loc.postalCode;
                        });
                      },
                    ),
                    const SizedBox(height: 10),

                    // Detected address label
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 18, color: AppColors.textGrey),
                        const SizedBox(width: 6),
                        Expanded(
                          child: AnimatedBuilder(
                            animation: Listenable.merge([
                              _streetController,
                              _cityController,
                              _postalController,
                            ]),
                            builder: (context, _) => Text(
                              _formattedAddress,
                              style: AppTextStyles.subtitle,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── Editable address fields ──────────────────────────
                    _buildAddressField(
                        controller: _streetController,
                        hint: 'Street / Area'),
                    const SizedBox(height: 10),
                    _buildAddressField(
                        controller: _cityController, hint: 'City'),
                    const SizedBox(height: 10),
                    _buildAddressField(
                        controller: _postalController, hint: 'Postal Code'),
                    const SizedBox(height: 10),
                    _buildAddressField(
                        controller: _extraController, hint: ''),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // ── Confirm Location button ──────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                0,
                AppSpacing.screenPadding,
                24,
              ),
              child: PrimaryButton(
                label: 'Confirm Location',
                onPressed: _onConfirmPressed,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressField({
    required TextEditingController controller,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      style: AppTextStyles.inputText,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.hint,
        filled: true,
        fillColor: AppColors.background,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
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
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Step 3 — Confirm Location (Image 10)
// All 3 steps complete; shows the selected address with a "Change" option.
// ════════════════════════════════════════════════════════════════════════════

class VerificationConfirmLocationScreen extends StatelessWidget {
  final String address;

  const VerificationConfirmLocationScreen({
    super.key,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // All 3 steps done
              const VerificationStepIndicator(currentStep: 4),
              const SizedBox(height: 32),

              // Label
              const Text(
                'Your Permanent location  is:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 12),

              // Address pill
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    vertical: 16, horizontal: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: AppColors.borderGrey),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 20, color: AppColors.textGrey),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        address,
                        style: AppTextStyles.inputText,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Warning + Change button
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(Icons.info_outline,
                        size: 16, color: AppColors.textGrey),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textGrey,
                            height: 1.45),
                        children: [
                          TextSpan(
                              text:
                                  'Your permanent location can only be changed '),
                          TextSpan(
                            text: 'once in a year',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          TextSpan(text: '.'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Change button
              GestureDetector(
                onTap: () => Navigator.pop(context), // go back to select
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Change',
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // Submit → goes to pending screen
              PrimaryButton(
                label: 'Submit',
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const VerificationPendingScreen(),
                    ),
                    (route) => false,
                  );
                },
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}