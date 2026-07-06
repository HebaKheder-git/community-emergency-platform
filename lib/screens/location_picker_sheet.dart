import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/primary_button.dart';
import '../widgets/location_map_picker.dart';

/// Simple value object for the address pieces edited in the sheet.
class EmergencyLocation {
  final String country;
  final String city;
  final String state;

  const EmergencyLocation({
    required this.country,
    required this.city,
    required this.state,
  });

  String get formatted => '$country, $city, $state';

  EmergencyLocation copyWith({
    String? country,
    String? city,
    String? state,
  }) {
    return EmergencyLocation(
      country: country ?? this.country,
      city: city ?? this.city,
      state: state ?? this.state,
    );
  }
}

/// Draggable bottom sheet matching the "Select Location" Figma screen:
/// search bar, real interactive map with a "You are here" marker + "Track my
/// location" pill, current address line, and 3 editable address fields.
///
/// Call [showLocationPickerSheet] to present it; it returns the confirmed
/// [EmergencyLocation], or null if dismissed without confirming.
Future<EmergencyLocation?> showLocationPickerSheet(
  BuildContext context, {
  required EmergencyLocation initial,
}) {
  return showModalBottomSheet<EmergencyLocation>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => LocationPickerSheet(initial: initial),
  );
}

class LocationPickerSheet extends StatefulWidget {
  final EmergencyLocation initial;

  const LocationPickerSheet({super.key, required this.initial});

  @override
  State<LocationPickerSheet> createState() => _LocationPickerSheetState();
}

class _LocationPickerSheetState extends State<LocationPickerSheet> {
  late final TextEditingController _searchController;
  late final TextEditingController _countryController;
  late final TextEditingController _cityController;
  late final TextEditingController _stateController;

  // Lets us call methods (searchAddress, track-my-location) on the map
  // widget from outside, e.g. from the search bar's submit handler.
  final _mapKey = GlobalKey<LocationMapPickerState>();

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _countryController = TextEditingController(text: widget.initial.country);
    _cityController = TextEditingController(text: widget.initial.city);
    _stateController = TextEditingController(text: widget.initial.state);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  void _confirm() {
    Navigator.pop(
      context,
      EmergencyLocation(
        country: _countryController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.78,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          child: SafeArea(
            top: false,
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                12,
                AppSpacing.screenPadding,
                24,
              ),
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 18),
                    decoration: BoxDecoration(
                      color: AppColors.textDark,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),

                // Header
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back,
                          color: AppColors.textDark, size: 24),
                    ),
                    const SizedBox(width: 14),
                    const Text(
                      'Select Location',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Search address
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
                          color: AppColors.hintGrey),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(28),
                      borderSide: const BorderSide(color: AppColors.borderGrey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(28),
                      borderSide: const BorderSide(color: AppColors.borderGrey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(28),
                      borderSide: const BorderSide(color: AppColors.primaryRed),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Real interactive map — shows GPS position, tap to drop
                // pin elsewhere, reverse-geocodes into the fields below.
                LocationMapPicker(
                  key: _mapKey,
                  height: 190,
                  onLocationPicked: (loc) {
                    setState(() {
                      _countryController.text = loc.country;
                      _cityController.text = loc.city;
                      _stateController.text = loc.state;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Current resolved address line
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        color: AppColors.textDark, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AnimatedBuilder(
                        animation: Listenable.merge(
                            [_countryController, _cityController, _stateController]),
                        builder: (context, _) => Text(
                          '${_countryController.text}, ${_cityController.text}, ${_stateController.text}',
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _AddressField(controller: _countryController, hint: 'country'),
                const SizedBox(height: AppSpacing.fieldGap),
                _AddressField(controller: _cityController, hint: 'City'),
                const SizedBox(height: AppSpacing.fieldGap),
                _AddressField(
                  controller: _stateController,
                  hint: 'state ',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 28),

                PrimaryButton(
                  label: 'Confirm Location',
                  onPressed: _confirm,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AddressField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;

  const _AddressField({
    required this.controller,
    required this.hint,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Focus(
      child: Builder(builder: (context) {
        final hasFocus = Focus.of(context).hasFocus;
        return TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: AppTextStyles.inputText,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.hint,
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28),
              borderSide: BorderSide(
                color: hasFocus ? AppColors.primaryRed : AppColors.borderGrey,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28),
              borderSide: const BorderSide(color: AppColors.borderGrey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28),
              borderSide:
                  const BorderSide(color: AppColors.primaryRed, width: 1.4),
            ),
          ),
        );
      }),
    );
  }
}