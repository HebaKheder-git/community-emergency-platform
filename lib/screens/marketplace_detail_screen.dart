// lib/screens/marketplace_detail_screen.dart

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/marketplace.dart';

// ════════════════════════════════════════════════════════════════════════════
// MarketplaceDetailScreen
//
// Opened by tapping a card on [MarketplacesScreen]. Shows the marketplace
// name in the header and a scrollable list of its items, each as a row
// card with a photo thumbnail, name, quantity, and price — matching the
// Figma exactly. Browsing only: there is intentionally no "buy" action
// per the brief (marketplaces are for finding tools nearby, not purchasing
// in-app).
// ════════════════════════════════════════════════════════════════════════════

class MarketplaceDetailScreen extends StatelessWidget {
  final Marketplace marketplace;

  const MarketplaceDetailScreen({super.key, required this.marketplace});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 14, 20, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.chevron_left_rounded,
                      size: 30,
                      color: AppColors.primaryRed,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      marketplace.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryRed,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // ── Item list ────────────────────────────────────────────────
            Expanded(
              child: marketplace.items.isEmpty
                  ? Center(
                      child: Text(
                        'No items listed yet.',
                        style: AppTextStyles.subtitle,
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                      itemCount: marketplace.items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        return _MarketplaceItemCard(
                          item: marketplace.items[index],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Item row card
// ════════════════════════════════════════════════════════════════════════════

class _MarketplaceItemCard extends StatelessWidget {
  final MarketplaceItem item;

  const _MarketplaceItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            ),
            child: SizedBox(
              width: 110,
              height: 110,
              child: item.imageUrl != null
                  ? Image.network(
                      item.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const _ItemImageFallback(),
                    )
                  : const _ItemImageFallback(),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.quantityLabel,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.hintGrey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item.formattedPrice,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Neutral placeholder shown when an item has no photo or it fails to load.
class _ItemImageFallback extends StatelessWidget {
  const _ItemImageFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFEDEDED),
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_outlined,
        size: 28,
        color: AppColors.hintGrey,
      ),
    );
  }
}