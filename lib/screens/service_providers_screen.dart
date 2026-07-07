// lib/screens/service_providers_screen.dart

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/service_provider_card.dart';
import '../models/service_provider.dart';
import '../models/marketplace.dart' show MarketLocation, MarketLocationX;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/trust_verification/trust_verification_cubit.dart';
import '../cubits/trust_verification/trust_verification_state.dart';
import '../widgets/unverified_access_notice.dart';

// ════════════════════════════════════════════════════════════════════════════
// ServiceProvidersScreen
//
// Shown when "Service providers" is tapped in the bottom navigation bar.
// Features:
//  • Joined two-pill filter bar ("Select service category" | "Select
//    location") opening bottom-sheet pickers, plus a standalone funnel
//    icon button that opens both filters at once in a single sheet
//  • Both filters are combined with AND logic — a provider must match the
//    selected category AND the selected location to show up ("All"
//    matches everything for that filter)
//  • Live "Showing Total X service provider" counter that updates as
//    filters change
//  • Scrollable list of provider cards. Each card shows the provider's
//    photo if it has one, otherwise a category icon placeholder
// ════════════════════════════════════════════════════════════════════════════

class ServiceProvidersScreen extends StatefulWidget {
  final int selectedNavIndex;
  final ValueChanged<int> onNavTap;

  const ServiceProvidersScreen({
    super.key,
    this.selectedNavIndex = 3,
    required this.onNavTap,
  });

  @override
  State<ServiceProvidersScreen> createState() =>
      _ServiceProvidersScreenState();
}

class _ServiceProvidersScreenState extends State<ServiceProvidersScreen> {
  ServiceCategory _selectedCategory = ServiceCategory.all;
  MarketLocation _selectedLocation = MarketLocation.all;

  List<ServiceProvider> get _filtered {
    return mockServiceProviders.where((p) {
      final matchesCategory = _selectedCategory == ServiceCategory.all ||
          p.category == _selectedCategory;
      final matchesLocation = _selectedLocation == MarketLocation.all ||
          p.location == _selectedLocation;
      return matchesCategory && matchesLocation;
    }).toList();
  }

  // ── Single-filter bottom sheets ─────────────────────────────────────────
  Future<void> _pickCategory() async {
    final result = await showModalBottomSheet<ServiceCategory>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _SingleOptionSheet<ServiceCategory>(
        title: 'Select service category',
        options: ServiceCategory.values,
        selected: _selectedCategory,
        labelBuilder: (c) => c.label,
      ),
    );
    if (result != null) setState(() => _selectedCategory = result);
  }

  Future<void> _pickLocation() async {
    final result = await showModalBottomSheet<MarketLocation>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _SingleOptionSheet<MarketLocation>(
        title: 'Select location',
        options: MarketLocation.values,
        selected: _selectedLocation,
        labelBuilder: (l) => l.label,
      ),
    );
    if (result != null) setState(() => _selectedLocation = result);
  }

  // ── Combined filter sheet (funnel icon) ─────────────────────────────────
  Future<void> _openCombinedFilterSheet() async {
    ServiceCategory tempCategory = _selectedCategory;
    MarketLocation tempLocation = _selectedLocation;

    final applied = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              minChildSize: 0.4,
              maxChildSize: 0.9,
              expand: false,
              builder: (ctx, scrollController) {
                return SafeArea(
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(20, 16, 20, 4),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Filter',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primaryRed,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          children: [
                            _SheetSectionLabel('Service category'),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: ServiceCategory.values.map((c) {
                                final selected = c == tempCategory;
                                return ChoiceChip(
                                  label: Text(c.label),
                                  selected: selected,
                                  selectedColor: AppColors.primaryRed,
                                  labelStyle: TextStyle(
                                    color: selected
                                        ? Colors.white
                                        : AppColors.textDark,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  backgroundColor: const Color(0xFFF2F2F2),
                                  onSelected: (_) =>
                                      setSheetState(() => tempCategory = c),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 20),
                            _SheetSectionLabel('Location'),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: MarketLocation.values.map((l) {
                                final selected = l == tempLocation;
                                return ChoiceChip(
                                  label: Text(l.label),
                                  selected: selected,
                                  selectedColor: AppColors.primaryRed,
                                  labelStyle: TextStyle(
                                    color: selected
                                        ? Colors.white
                                        : AppColors.textDark,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  backgroundColor: const Color(0xFFF2F2F2),
                                  onSelected: (_) =>
                                      setSheetState(() => tempLocation = l),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                        child: SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryRed,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text(
                              'Apply',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );

    if (applied == true) {
      setState(() {
        _selectedCategory = tempCategory;
        _selectedLocation = tempLocation;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final providers = _filtered;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      body: BlocBuilder<TrustVerificationCubit, TrustVerificationState>(
        builder: (context, state) {
          final verified = state.data.isApproved;
        if (!verified){
            return UnverifiedAccessNotice();}
        return SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Filter row ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: Row(
                children: [
                  const Text(
                    'Filter:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryRed,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(23),
                        border: Border.all(color: AppColors.borderGrey),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _FilterPill(
                              label: _selectedCategory == ServiceCategory.all
                                  ? 'Select service category'
                                  : _selectedCategory.label,
                              onTap: _pickCategory,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 22,
                            color: AppColors.borderGrey,
                          ),
                          Expanded(
                            child: _FilterPill(
                              label: _selectedLocation == MarketLocation.all
                                  ? 'Select location'
                                  : _selectedLocation.label,
                              onTap: _pickLocation,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _openCombinedFilterSheet,
                    behavior: HitTestBehavior.opaque,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Icon(
                        Icons.filter_alt_outlined,
                        color: AppColors.primaryRed,
                        size: 28,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Result count ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textGrey,
                  ),
                  children: [
                    const TextSpan(text: 'Showing Total '),
                    TextSpan(
                      text: '${providers.length}',
                      style: const TextStyle(
                        color: AppColors.primaryRed,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const TextSpan(text: ' service provider'),
                  ],
                ),
              ),
            ),

            // ── List ──────────────────────────────────────────────────────
            Expanded(
              child: providers.isEmpty
                  ? const Center(
                      child: Text(
                        'No service providers match these filters.',
                        style: TextStyle(color: AppColors.textGrey),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                      itemCount: providers.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        return ServiceProviderCard(provider: providers[index]);
                      },
                    ),
            ),
          ],
        ),
      );
      },
),
      bottomNavigationBar: SoteriaBottomNav(
        selectedIndex: widget.selectedNavIndex,
        onTap: widget.onNavTap,
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Small private helpers
// ════════════════════════════════════════════════════════════════════════════

class _FilterPill extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _FilterPill({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(23),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13.5,
                  color: AppColors.textGrey,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Container(
              width: 18,
              height: 18,
              decoration: const BoxDecoration(
                color: AppColors.primaryRed,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 14,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetSectionLabel extends StatelessWidget {
  final String text;
  const _SheetSectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: AppColors.textDark,
        ),
      ),
    );
  }
}

/// Single-choice bottom sheet used by both [_pickCategory] and
/// [_pickLocation]. "All" is always present since it's the first/default
/// value of each enum.
class _SingleOptionSheet<T> extends StatelessWidget {
  final String title;
  final List<T> options;
  final T selected;
  final String Function(T) labelBuilder;

  const _SingleOptionSheet({
    required this.title,
    required this.options,
    required this.selected,
    required this.labelBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 6),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryRed,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.5,
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: options.length,
              itemBuilder: (context, index) {
                final option = options[index];
                final isSelected = option == selected;
                return RadioListTile<T>(
                  value: option,
                  groupValue: selected,
                  activeColor: AppColors.primaryRed,
                  title: Text(
                    labelBuilder(option),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w400,
                      color: AppColors.textDark,
                    ),
                  ),
                  onChanged: (value) => Navigator.pop(context, value),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}