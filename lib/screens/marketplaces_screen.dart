// lib/screens/marketplaces_screen.dart

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/filter_dropdown.dart';
import '../models/marketplace.dart';
import 'marketplace_detail_screen.dart';

// ════════════════════════════════════════════════════════════════════════════
// MarketplacesScreen
//
// Shown when "Marketplaces" is tapped in the bottom navigation bar.
// Features:
//  • Joined two-pill filter bar ("Select product category" | "Select
//    location") opening bottom-sheet pickers, plus a standalone funnel
//    icon button that opens both filters at once in a single sheet
//  • Both filters are combined with AND logic — a marketplace must match
//    the selected category AND the selected location to show up
//    ("All" matches everything for that filter)
//  • Live "Showing Total X marketplace" counter that updates as filters
//    change
//  • Scrollable 3-column grid of marketplace cards. Each card shows the
//    marketplace's image if it has one, otherwise the red toolbox/bell
//    placeholder icon from the Figma
//  • Tapping a card opens [MarketplaceDetailScreen] for that marketplace
// ════════════════════════════════════════════════════════════════════════════

class MarketplacesScreen extends StatefulWidget {
  /// Currently selected bottom-nav index, forwarded from the parent so
  /// the nav bar highlights "Marketplaces" correctly when pushed.
  final int selectedNavIndex;
  final ValueChanged<int> onNavTap;

  const MarketplacesScreen({
    super.key,
    this.selectedNavIndex = 2,
    required this.onNavTap,
  });

  @override
  State<MarketplacesScreen> createState() => _MarketplacesScreenState();
}

class _MarketplacesScreenState extends State<MarketplacesScreen> {
  ProductCategory? _selectedCategory;
  MarketLocation? _selectedLocation;

  List<Marketplace> get _filteredMarketplaces {
    return mockMarketplaces.where((market) {
      final matchesCategory = _selectedCategory == null ||
          _selectedCategory == ProductCategory.all ||
          market.category == _selectedCategory;
      final matchesLocation = _selectedLocation == null ||
          _selectedLocation == MarketLocation.all ||
          market.location == _selectedLocation;
      return matchesCategory && matchesLocation;
    }).toList();
  }

  void _openCombinedFilterSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        // Local copies so the sheet can preview changes, then commit them
        // to the screen state via "Apply".
        ProductCategory? tempCategory = _selectedCategory;
        MarketLocation? tempLocation = _selectedLocation;

        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: AppColors.borderGrey,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const Text('Filter by', style: AppTextStyles.fieldLabel),
                    const SizedBox(height: 16),
                    Text('Product category',
                        style: AppTextStyles.fieldLabel
                            .copyWith(fontSize: 13, color: AppColors.textGrey)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ProductCategory.values.map((cat) {
                        final isSelected = tempCategory == cat ||
                            (tempCategory == null && cat == ProductCategory.all);
                        return ChoiceChip(
                          label: Text(cat.label),
                          selected: isSelected,
                          selectedColor: AppColors.primaryRed,
                          backgroundColor: AppColors.background,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppColors.textDark,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected
                                  ? AppColors.primaryRed
                                  : AppColors.borderGrey,
                            ),
                          ),
                          onSelected: (_) =>
                              setSheetState(() => tempCategory = cat),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    Text('Location',
                        style: AppTextStyles.fieldLabel
                            .copyWith(fontSize: 13, color: AppColors.textGrey)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: MarketLocation.values.map((loc) {
                        final isSelected = tempLocation == loc ||
                            (tempLocation == null && loc == MarketLocation.all);
                        return ChoiceChip(
                          label: Text(loc.label),
                          selected: isSelected,
                          selectedColor: AppColors.primaryRed,
                          backgroundColor: AppColors.background,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppColors.textDark,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected
                                  ? AppColors.primaryRed
                                  : AppColors.borderGrey,
                            ),
                          ),
                          onSelected: (_) =>
                              setSheetState(() => tempLocation = loc),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.textDark,
                              side: const BorderSide(
                                  color: AppColors.borderGrey),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                            onPressed: () {
                              setSheetState(() {
                                tempCategory = ProductCategory.all;
                                tempLocation = MarketLocation.all;
                              });
                            },
                            child: const Text('Reset'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryRed,
                              foregroundColor: Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                _selectedCategory = tempCategory;
                                _selectedLocation = tempLocation;
                              });
                              Navigator.pop(sheetContext);
                            },
                            child: const Text('Apply'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final results = _filteredMarketplaces;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Filter bar ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: Row(
                children: [
                  const Text(
                    'Filter:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.borderGrey),
                      ),
                      child: Row(
                        children: [
                          FilterDropdown<ProductCategory>(
                            placeholder: 'Select product category',
                            value: _selectedCategory,
                            options: ProductCategory.values,
                            labelBuilder: (c) => c.label,
                            onChanged: (c) =>
                                setState(() => _selectedCategory = c),
                          ),
                          Container(
                            width: 1,
                            height: 22,
                            color: AppColors.borderGrey,
                          ),
                          FilterDropdown<MarketLocation>(
                            placeholder: 'Select location',
                            value: _selectedLocation,
                            options: MarketLocation.values,
                            labelBuilder: (l) => l.label,
                            onChanged: (l) =>
                                setState(() => _selectedLocation = l),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _openCombinedFilterSheet,
                    child: const Icon(
                      Icons.filter_alt_outlined,
                      size: 28,
                      color: AppColors.primaryRed,
                    ),
                  ),
                ],
              ),
            ),

            // ── Result counter ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textGrey,
                  ),
                  children: [
                    const TextSpan(text: 'Showing Total '),
                    TextSpan(
                      text: '${results.length}',
                      style: const TextStyle(
                        color: Color(0xFFE8902E),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const TextSpan(text: ' marketplace'),
                  ],
                ),
              ),
            ),

            // ── Grid ──────────────────────────────────────────────────────
            Expanded(
              child: results.isEmpty
                  ? Center(
                      child: Text(
                        'No marketplaces match these filters.',
                        style: AppTextStyles.subtitle,
                        textAlign: TextAlign.center,
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                      itemCount: results.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 18,
                        crossAxisSpacing: 14,
                        childAspectRatio: 0.72,
                      ),
                      itemBuilder: (context, index) {
                        return _MarketplaceCard(marketplace: results[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SoteriaBottomNav(
        selectedIndex: widget.selectedNavIndex,
        onTap: widget.onNavTap,
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Marketplace grid card
// ════════════════════════════════════════════════════════════════════════════

class _MarketplaceCard extends StatelessWidget {
  final Marketplace marketplace;

  const _MarketplaceCard({required this.marketplace});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MarketplaceDetailScreen(marketplace: marketplace),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.disabledRed,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.primaryRed, width: 1.4),
                image: marketplace.imageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(marketplace.imageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              alignment: Alignment.center,
              // Placeholder icon — only shown when there is no image,
              // matching the toolbox/bell glyph from the Figma.
              child: marketplace.imageUrl == null
                  ? const Icon(
                      Icons.handyman_outlined,
                      size: 34,
                      color: AppColors.primaryRed,
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            marketplace.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryRed,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            marketplace.category.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(Icons.location_on,
                    size: 11, color: AppColors.textGrey),
              ),
              const SizedBox(width: 2),
              Expanded(
                child: Text(
                  marketplace.locationLabel,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textGrey,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}