//lib/screens/home_location_search_screen.dart



import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../theme/app_theme.dart';
import '../widgets/primary_button.dart';
import '../widgets/location_map_picker.dart';
import '../cubits/emergency_group/emergency_group_cubit.dart';
import 'group_search_results_screen.dart';
import 'home_screen.dart';

// ════════════════════════════════════════════════════════════════════════════
// Home location + group search flow.
//
// REVISED: entered by tapping "Search for Emergency Group" on HomeScreen
// (verified users only — see home_screen.dart). NOT automatic after
// verification, and not part of the verification wizard anymore, which is
// why this used to be VerificationStep3LocationScreen /
// VerificationSelectLocationScreen and has been renamed here to
// HomeLocationGateScreen / SelectHomeLocationScreen.
//
// Job: get a location from the user → search for a nearby emergency group
// → let them join it → send them back to HomeScreen (SOS) on success.
//
// UI behavior carried over from your original step-3 screens:
//  • No skip button.
//  • Small back arrow at the top-left of both screens. It does NOT do a
//    normal Navigator.pop — it jumps straight back to HomeScreen (same
//    pattern your own code already used elsewhere, e.g. the old "Submit"
//    button in VerificationConfirmLocationScreen).
//  • "Confirm Location" calls EmergencyGroupCubit.searchGroups() — which
//    also saves the point as the profile's home location via
//    save_as_home:true — then pushes GroupSearchResultsScreen.
//
// If you still have the old verification_step3_location_screen.dart in
// your project, delete it — this file replaces it entirely.
// ════════════════════════════════════════════════════════════════════════════

class HomeLocationGateScreen extends StatelessWidget {
  const HomeLocationGateScreen({super.key});

  void _backToHome(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

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
              const SizedBox(height: 8),

              // ── Back arrow → Home (not a normal pop) ─────────────────
              Row(
                children: [
                  IconButton(
                    icon:
                        const Icon(Icons.arrow_back, color: AppColors.textDark),
                    onPressed: () => _backToHome(context),
                  ),
                ],
              ),

              const Spacer(flex: 3),

              // Icon + copy
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
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
                              TextSpan(text: 'Find your group'),
                              TextSpan(text: '.'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Please allow location permission so we can find '
                          'the emergency group near you.',
                          style: AppTextStyles.subtitle,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const Spacer(flex: 4),

              // Allow button → the map / address picker. The actual OS
              // permission prompt happens inside LocationMapPicker as soon
              // as that screen mounts (unchanged from before).
              PrimaryButton(
                label: 'Allow',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SelectHomeLocationScreen(),
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
// Select Location — search bar + interactive map + editable address fields.
// Same picker UI as your original step-3 screen; only the destination of
// "Confirm Location" changed (now triggers the group search instead of the
// old "permanent location" confirmation screen).
// ════════════════════════════════════════════════════════════════════════════

class SelectHomeLocationScreen extends StatefulWidget {
  const SelectHomeLocationScreen({super.key});

  @override
  State<SelectHomeLocationScreen> createState() =>
      _SelectHomeLocationScreenState();
}

class _SelectHomeLocationScreenState extends State<SelectHomeLocationScreen> {
  final _searchController = TextEditingController();
  final _countryController = TextEditingController();
  final _stateController = TextEditingController();
  final _cityController = TextEditingController();

  double? _latitude;
  double? _longitude;

  final _mapKey = GlobalKey<LocationMapPickerState>();

  String get _formattedAddress =>
      '${_cityController.text}, ${_stateController.text}, ${_countryController.text}';

  String get _formattedCoordinates =>
      (_latitude != null && _longitude != null)
          ? '${_latitude!.toStringAsFixed(5)}, ${_longitude!.toStringAsFixed(5)}'
          : 'Pick a point on the map';

  @override
  void dispose() {
    _searchController.dispose();
    _countryController.dispose();
    _stateController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _backToHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  void _onConfirmPressed() {
    if (_latitude == null || _longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please pick a location on the map first.'),
        ),
      );
      return;
    }

    final cubit = EmergencyGroupCubit()
      ..searchGroups(latitude: _latitude!, longitude: _longitude!);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: const GroupSearchResultsScreen(),
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
            // ── Back arrow → Home ────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back,
                        color: AppColors.textDark),
                    onPressed: _backToHome,
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    LocationMapPicker(
                      key: _mapKey,
                      height: 160,
                      onLocationPicked: (loc) {
                        setState(() {
                          _countryController.text = loc.country;
                          _stateController.text = loc.state;
                          _cityController.text = loc.city;
                          _latitude = loc.latitude;
                          _longitude = loc.longitude;
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
                              _countryController,
                              _stateController,
                              _cityController,
                            ]),
                            builder: (context, _) => Text(
                              _formattedAddress,
                              style: AppTextStyles.subtitle,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Detected coordinates
                    Row(
                      children: [
                        const Icon(Icons.my_location,
                            size: 18, color: AppColors.textGrey),
                        const SizedBox(width: 6),
                        Text(_formattedCoordinates,
                            style: AppTextStyles.subtitle),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── Editable address fields ──────────────────────────
                    _buildAddressField(
                        controller: _countryController, hint: 'Country'),
                    const SizedBox(height: 10),
                    _buildAddressField(
                        controller: _stateController,
                        hint: 'State / Governorate'),
                    const SizedBox(height: 10),
                    _buildAddressField(
                        controller: _cityController, hint: 'City'),

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