import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../theme/app_theme.dart';

/// Result handed back to the parent screen every time the user picks a
/// point on the map (via GPS, tap, or address search).
class PickedLocation {
  final double latitude;
  final double longitude;
  final String area;
  final String city;
  final String postalCode;
  final String formattedAddress;

  const PickedLocation({
    required this.latitude,
    required this.longitude,
    required this.area,
    required this.city,
    required this.postalCode,
    required this.formattedAddress,
  });
}

/// A real, interactive, free map (OpenStreetMap tiles via flutter_map — no
/// API key required) that:
///  - shows the user's current GPS position on load,
///  - lets them tap anywhere to drop the pin there instead,
///  - reverse-geocodes whatever point is selected into area/city/postcode
///    and reports it back through [onLocationPicked],
///  - exposes [searchAddress] (call via a GlobalKey<LocationMapPickerState>)
///    so a search bar elsewhere in the screen can move the map too.
///
/// Drop this in wherever the old static/fake map preview used to be.
class LocationMapPicker extends StatefulWidget {
  final LatLng? initialPosition;
  final double height;
  final ValueChanged<PickedLocation>? onLocationPicked;

  const LocationMapPicker({
    super.key,
    this.initialPosition,
    this.height = 200,
    this.onLocationPicked,
  });

  @override
  State<LocationMapPicker> createState() => LocationMapPickerState();
}

class LocationMapPickerState extends State<LocationMapPicker> {
  final MapController _mapController = MapController();

  // Used only if GPS/geocoding both fail on first load, so the map still
  // renders something sensible instead of a blank grey box.
  static const LatLng _fallback = LatLng(18.5204, 73.8567); // Pune, India

  LatLng? _currentPoint;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.initialPosition != null) {
      _currentPoint = widget.initialPosition;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _reverseGeocode(widget.initialPosition!);
      });
    } else {
      _useMyLocation();
    }
  }

  /// Fetches the device's current GPS position, moves the map there, and
  /// reverse-geocodes it. Also wired up to the "Track my location" pill.
  Future<void> _useMyLocation() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Location services are turned off on this device.';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permission denied.';
        }
      }
      if (permission == LocationPermission.deniedForever) {
        throw 'Location permission is permanently denied. Enable it from Settings.';
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      await _selectPoint(LatLng(position.latitude, position.longitude), moveMap: true);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _currentPoint ??= _fallback;
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Call this from outside (via a GlobalKey) when the user submits the
  /// "Search Address" field, so the map jumps to that address.
  Future<void> searchAddress(String query) async {
    if (query.trim().isEmpty) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final results = await locationFromAddress(query);
      if (results.isEmpty) {
        throw 'No results found for that address.';
      }
      final loc = results.first;
      await _selectPoint(LatLng(loc.latitude, loc.longitude), moveMap: true);
    } catch (_) {
      setState(() => _error = 'Address not found.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _selectPoint(LatLng point, {bool moveMap = false}) async {
    setState(() => _currentPoint = point);
    if (moveMap) {
      _mapController.move(point, 16);
    }
    await _reverseGeocode(point);
  }

  Future<void> _reverseGeocode(LatLng point) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        point.latitude,
        point.longitude,
      );
      if (placemarks.isEmpty || !mounted) return;

      final p = placemarks.first;
      final area = [p.subLocality, p.thoroughfare]
          .where((s) => s != null && s.trim().isNotEmpty)
          .join(', ');
      final city = p.locality?.isNotEmpty == true
          ? p.locality!
          : (p.subAdministrativeArea ?? '');
      final postalCode = p.postalCode ?? '';
      final formatted =
          [area, city, postalCode].where((s) => s.isNotEmpty).join(', ');

      widget.onLocationPicked?.call(
        PickedLocation(
          latitude: point.latitude,
          longitude: point.longitude,
          area: area.isEmpty ? (p.name ?? '') : area,
          city: city,
          postalCode: postalCode,
          formattedAddress: formatted,
        ),
      );
    } catch (_) {
      // Reverse geocoding can legitimately fail (offline, rate limit, no
      // results for the platform geocoder) — keep whatever text is there.
    }
  }

  @override
  Widget build(BuildContext context) {
    final point = _currentPoint ?? _fallback;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: widget.height,
        width: double.infinity,
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: point,
                initialZoom: 15,
                onTap: (_, latLng) => _selectPoint(latLng),
              ),
              children: [
                TileLayer(
                  // Free, no API key: CartoDB Voyager basemap. Swap for
                  // OpenStreetMap's own {s}.tile.openstreetmap.org tiles
                  // only for light testing — their usage policy asks
                  // production apps not to hit those servers directly.
                  urlTemplate:
                      'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
                  subdomains: const ['a', 'b', 'c', 'd'],
                  userAgentPackageName: 'com.soteria.app',
                  maxZoom: 19,
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: point,
                      width: 40,
                      height: 40,
                      alignment: Alignment.topCenter,
                      child: const Icon(
                        Icons.location_on,
                        color: AppColors.primaryRed,
                        size: 40,
                      ),
                    ),
                  ],
                ),
                RichAttributionWidget(
                  alignment: AttributionAlignment.bottomLeft,
                  attributions: [
                    TextSourceAttribution(
                      '© OpenStreetMap contributors, © CARTO',
                    ),
                  ],
                ),
              ],
            ),
            if (_isLoading)
              const Positioned.fill(
                child: ColoredBox(
                  color: Color(0x33000000),
                  child: Center(
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.primaryRed,
                      ),
                    ),
                  ),
                ),
              ),
            Positioned(
              right: 10,
              bottom: 10,
              child: _TrackMyLocationPill(onTap: _useMyLocation),
            ),
            if (_error != null)
              Positioned(
                left: 10,
                right: 10,
                top: 10,
                child: _ErrorBanner(message: _error!),
              ),
          ],
        ),
      ),
    );
  }
}

class _TrackMyLocationPill extends StatelessWidget {
  final VoidCallback onTap;
  const _TrackMyLocationPill({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(color: Color(0x1F000000), blurRadius: 6),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.my_location, color: AppColors.primaryRed, size: 16),
            const SizedBox(width: 6),
            Text('Track my location', style: AppTextStyles.linkRed.copyWith(fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        message,
        style: const TextStyle(color: Colors.white, fontSize: 11),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}