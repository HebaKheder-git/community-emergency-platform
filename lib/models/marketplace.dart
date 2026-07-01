// lib/models/marketplace.dart

/// Broad category a marketplace's stock falls under. Used by the
/// "Select product category" filter menu on [MarketplacesScreen].
enum ProductCategory {
  all,
  fixTools,
  medicalSupplies,
  fireSafety,
  floodGear,
  food,
}

extension ProductCategoryX on ProductCategory {
  /// Label shown in the filter menu and on each marketplace card.
  String get label {
    switch (this) {
      case ProductCategory.all:
        return 'All';
      case ProductCategory.fixTools:
        return 'fix tools';
      case ProductCategory.medicalSupplies:
        return 'medical supplies';
      case ProductCategory.fireSafety:
        return 'fire safety';
      case ProductCategory.floodGear:
        return 'flood gear';
      case ProductCategory.food:
        return 'food & water';
    }
  }
}

/// Region/location a marketplace belongs to. Used by the
/// "Select location" filter menu on [MarketplacesScreen].
enum MarketLocation {
  all,
  alDreikeesh,
  tartous,
  damascus,
  aleppo,
}

extension MarketLocationX on MarketLocation {
  /// Label shown in the filter menu.
  String get label {
    switch (this) {
      case MarketLocation.all:
        return 'All';
      case MarketLocation.alDreikeesh:
        return 'Syria, Tartous, Al-Dreikeesh';
      case MarketLocation.tartous:
        return 'Syria, Tartous';
      case MarketLocation.damascus:
        return 'Syria, Damascus';
      case MarketLocation.aleppo:
        return 'Syria, Aleppo';
    }
  }
}

/// A single product/tool sold inside one [Marketplace], shown on
/// [MarketplaceDetailScreen] (e.g. "Screwdriver", "10 pieces", "$1.35").
class MarketplaceItem {
  final String id;
  final String name;
  final String quantityLabel; // e.g. "10 pieces"
  final double price;

  /// Network/asset image path for the product thumbnail. Null falls back
  /// to a neutral placeholder box (no general icon needed here since the
  /// Figma always shows a photo for items, unlike the marketplace cards).
  final String? imageUrl;

  const MarketplaceItem({
    required this.id,
    required this.name,
    required this.quantityLabel,
    required this.price,
    this.imageUrl,
  });

  String get formattedPrice => '\$${price.toStringAsFixed(2)}';
}

/// A single marketplace location, shown as a card in the grid on
/// [MarketplacesScreen] and as the header of [MarketplaceDetailScreen].
class Marketplace {
  final String id;
  final String name;
  final ProductCategory category;
  final MarketLocation location;

  /// Specific human-readable location line shown under the card name
  /// (e.g. "Syria, Tartous, Al-Dreikeesh"). Kept separate from
  /// [MarketLocation] so multiple markets can share a filter bucket
  /// while still showing slightly different address text.
  final String locationLabel;

  /// Card thumbnail. Null falls back to the red toolbox/bell icon seen
  /// in the Figma when a marketplace has no photo on file yet.
  final String? imageUrl;

  final List<MarketplaceItem> items;

  const Marketplace({
    required this.id,
    required this.name,
    required this.category,
    required this.location,
    required this.locationLabel,
    required this.items,
    this.imageUrl,
  });
}

/// Temporary mock data so the marketplace screens are fully scrollable
/// and filterable without backend wiring yet. Swap out once Qubit is
/// connected — keep the [Marketplace] / [MarketplaceItem] shapes stable.
final List<Marketplace> mockMarketplaces = List.generate(24, (i) {
  return Marketplace(
    id: 'market_$i',
    name: 'AL Dreikeesh market',
    category: ProductCategory.fixTools,
    location: MarketLocation.alDreikeesh,
    locationLabel: 'Syria, Tartous, Al-Dreikeesh',
    items: const [
      MarketplaceItem(
        id: 'item_1',
        name: 'Screwdriver',
        quantityLabel: '10 pieces',
        price: 1.35,
        imageUrl:
            'https://images.unsplash.com/photo-1581147036324-c1c89c2c8b5c?w=200',
      ),
      MarketplaceItem(
        id: 'item_2',
        name: 'Wrench',
        quantityLabel: '4 pieces',
        price: 0.87,
        imageUrl:
            'https://images.unsplash.com/photo-1530124566582-a618bc2615dc?w=200',
      ),
      MarketplaceItem(
        id: 'item_3',
        name: 'American Hammer',
        quantityLabel: '2 pieces',
        price: 1.87,
        imageUrl:
            'https://images.unsplash.com/photo-1572981779307-38b8cabb2407?w=200',
      ),
      MarketplaceItem(
        id: 'item_4',
        name: 'Screwdriver',
        quantityLabel: '10 pieces',
        price: 1.35,
        imageUrl:
            'https://images.unsplash.com/photo-1581147036324-c1c89c2c8b5c?w=200',
      ),
      MarketplaceItem(
        id: 'item_5',
        name: 'Wrench',
        quantityLabel: '4 pieces',
        price: 0.87,
        imageUrl:
            'https://images.unsplash.com/photo-1530124566582-a618bc2615dc?w=200',
      ),
      MarketplaceItem(
        id: 'item_6',
        name: 'American Hammer',
        quantityLabel: '2 pieces',
        price: 1.87,
        imageUrl:
            'https://images.unsplash.com/photo-1572981779307-38b8cabb2407?w=200',
      ),
    ],
  );
});