import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/primary_button.dart';

/// Simple value object for the address pieces edited in the sheet.
class EmergencyLocation {
  final String area;
  final String city;
  final String postalCode;

  const EmergencyLocation({
    required this.area,
    required this.city,
    required this.postalCode,
  });

  String get formatted => '$area, $city, $postalCode';

  EmergencyLocation copyWith({
    String? area,
    String? city,
    String? postalCode,
  }) {
    return EmergencyLocation(
      area: area ?? this.area,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
    );
  }
}

/// Draggable bottom sheet matching the "Select Location" Figma screen:
/// search bar, static map preview with a "You are here" marker + "Track my
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
  late final TextEditingController _areaController;
  late final TextEditingController _cityController;
  late final TextEditingController _postalController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _areaController = TextEditingController(text: widget.initial.area);
    _cityController = TextEditingController(text: widget.initial.city);
    _postalController = TextEditingController(text: widget.initial.postalCode);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _areaController.dispose();
    _cityController.dispose();
    _postalController.dispose();
    super.dispose();
  }

  void _trackMyLocation() {
    // TODO: integrate `geolocator` (or similar) to fetch the device's
    // current coordinates and reverse-geocode them into area/city/postal.
    // Stubbed for now so the UI flow is complete and ready to wire up.
  }

  void _confirm() {
    Navigator.pop(
      context,
      EmergencyLocation(
        area: _areaController.text.trim(),
        city: _cityController.text.trim(),
        postalCode: _postalController.text.trim(),
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
                  decoration: InputDecoration(
                    hintText: 'Search Address',
                    hintStyle: AppTextStyles.hint,
                    prefixIcon:
                        const Icon(Icons.search, color: AppColors.hintGrey),
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

                // Map preview (static placeholder — swap for
                // google_maps_flutter / mapbox once a maps key is available)
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    height: 190,
                    width: double.infinity,
                    color: const Color(0xFFE3E6E8),
                    child: Stack(
                      children: [
                        // Faux road
                        Positioned(
                          left: -40,
                          top: -20,
                          child: Transform.rotate(
                            angle: -0.55,
                            child: Container(
                              width: 320,
                              height: 36,
                              color: const Color(0xFFF3D27A),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 16,
                          bottom: 16,
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: const BoxDecoration(
                              color: Color(0xFFCFE8D2),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        // "You are here" marker
                        Positioned.fill(
                          child: Align(
                            alignment: const Alignment(0.15, -0.2),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.textDark,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'You are here',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 38,
                                  height: 38,
                                  margin: const EdgeInsets.only(top: 2),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFF08A3C),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.restaurant,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          left: 24,
                          top: 6,
                          child: Icon(Icons.location_on,
                              color: AppColors.primaryRed, size: 22),
                        ),
                        // Track my location pill
                        Positioned(
                          right: 12,
                          bottom: 12,
                          child: GestureDetector(
                            onTap: _trackMyLocation,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x1F000000),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.my_location,
                                      color: AppColors.primaryRed, size: 16),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Track my location',
                                    style: AppTextStyles.linkRed
                                        .copyWith(fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
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
                            [_areaController, _cityController, _postalController]),
                        builder: (context, _) => Text(
                          '${_areaController.text}, ${_cityController.text}, ${_postalController.text}',
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

                _AddressField(controller: _areaController, hint: 'Area'),
                const SizedBox(height: AppSpacing.fieldGap),
                _AddressField(controller: _cityController, hint: 'City'),
                const SizedBox(height: AppSpacing.fieldGap),
                _AddressField(
                  controller: _postalController,
                  hint: 'Postal Code',
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