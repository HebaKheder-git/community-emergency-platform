// lib/models/service_provider.dart

import 'package:flutter/material.dart';
import 'marketplace.dart' show MarketLocation;

/// Broad category a service provider falls under. Used by the
/// "Select service category" filter menu on [ServiceProvidersScreen].
enum ServiceCategory {
  all,
  waterTruck,
  tractor,
  personalCar,
  towingTruck,
  ambulance,
  generator,
  fuelDelivery,
  other,
}

extension ServiceCategoryX on ServiceCategory {
  /// Label shown in the filter menu and on each provider card.
  String get label {
    switch (this) {
      case ServiceCategory.all:
        return 'All';
      case ServiceCategory.waterTruck:
        return 'Water truck';
      case ServiceCategory.tractor:
        return 'Tractor';
      case ServiceCategory.personalCar:
        return 'Personal car';
      case ServiceCategory.towingTruck:
        return 'Towing truck';
      case ServiceCategory.ambulance:
        return 'Ambulance';
      case ServiceCategory.generator:
        return 'Generator';
      case ServiceCategory.fuelDelivery:
        return 'Fuel delivery';
      case ServiceCategory.other:
        return 'Other';
    }
  }

  /// Fallback icon drawn inside the provider's image box when
  /// [ServiceProvider.imagePath] is null (see [ServiceProviderCard]).
  IconData get fallbackIcon {
    switch (this) {
      case ServiceCategory.all:
        return Icons.miscellaneous_services_outlined;
      case ServiceCategory.waterTruck:
        return Icons.local_shipping_outlined;
      case ServiceCategory.tractor:
        return Icons.agriculture_outlined;
      case ServiceCategory.personalCar:
        return Icons.directions_car_outlined;
      case ServiceCategory.towingTruck:
        return Icons.car_repair_outlined;
      case ServiceCategory.ambulance:
        return Icons.local_hospital_outlined;
      case ServiceCategory.generator:
        return Icons.bolt_outlined;
      case ServiceCategory.fuelDelivery:
        return Icons.local_gas_station_outlined;
      case ServiceCategory.other:
        return Icons.handyman_outlined;
    }
  }
}

/// How a single contact entry should be rendered/launched.
enum ContactType { phone, whatsapp, email }

/// One reachable contact method for a provider (a provider can have any
/// combination — e.g. just a phone number, or phone + WhatsApp + email).
class ContactInfo {
  final ContactType type;
  final String value;

  const ContactInfo({required this.type, required this.value});
}

/// A single entry in the Service Providers list.
///
/// In the real app this will likely be replaced/wrapped by a Qubit state
/// model fed from the backend, but the shape (fields below) should stay
/// the same so the UI doesn't need to change when that wiring happens.
class ServiceProvider {
  final String id;
  final String name;
  final ServiceCategory category;

  /// Pre-formatted price string, e.g. 'free', '\$2.00', '\$1.80'.
  final String priceLabel;

  final MarketLocation location;

  /// Pre-formatted availability string, e.g. '24/7', 'Sat Sun | 24 h'.
  final String availabilityLabel;

  final List<ContactInfo> contacts;

  /// Path or URL to the provider's photo. When null, [ServiceProviderCard]
  /// shows [ServiceCategory.fallbackIcon] instead. Once real photos are
  /// available, just set this (Image.asset for a bundled asset, or swap
  /// the card's image builder for Image.network) — no other code needs
  /// to change.
  final String? imagePath;

  const ServiceProvider({
    required this.id,
    required this.name,
    required this.category,
    required this.priceLabel,
    required this.location,
    required this.availabilityLabel,
    required this.contacts,
    this.imagePath,
  });
}

/// Temporary mock data so the screen is fully scrollable/interactive
/// without backend wiring yet. Swap this out once Qubit is connected.
final List<ServiceProvider> mockServiceProviders = List.generate(3, (round) {
  return [
    ServiceProvider(
      id: 'sp_${round}_adam',
      name: 'Adam Smith',
      category: ServiceCategory.waterTruck,
      priceLabel: 'free',
      location: MarketLocation.alDreikeesh,
      availabilityLabel: '24/7',
      contacts: const [
        ContactInfo(type: ContactType.phone, value: '0988899923'),
      ],
    ),
    ServiceProvider(
      id: 'sp_${round}_john',
      name: 'John Kevin',
      category: ServiceCategory.tractor,
      priceLabel: '\$2.00',
      location: MarketLocation.alDreikeesh,
      availabilityLabel: 'Sat Sun | 24 h',
      contacts: const [
        ContactInfo(type: ContactType.whatsapp, value: '0935353535'),
        ContactInfo(type: ContactType.phone, value: '0924242424'),
      ],
    ),
    ServiceProvider(
      id: 'sp_${round}_sami',
      name: 'Sami Brown',
      category: ServiceCategory.personalCar,
      priceLabel: '\$1.80',
      location: MarketLocation.alDreikeesh,
      availabilityLabel: 'Sat Sun | 2:00 - 6:00',
      contacts: const [
        ContactInfo(type: ContactType.whatsapp, value: '0999999999'),
        ContactInfo(type: ContactType.phone, value: '0999999999'),
        ContactInfo(type: ContactType.email, value: 'samB@gmail.com'),
      ],
    ),
  ];
}).expand((group) => group).toList();