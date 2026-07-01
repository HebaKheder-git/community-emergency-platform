// lib/widgets/service_provider_card.dart

import 'package:flutter/material.dart';
import 'package:soteria/models/marketplace.dart';
import '../theme/app_theme.dart';
import '../models/service_provider.dart';

/// The dark maroon row card used on [ServiceProvidersScreen] — a square
/// image/icon box on the left, name + category/price + location/
/// availability + contact methods on the right.
///
/// The left-hand box shows [ServiceProvider.imagePath] (via Image.asset
/// or Image.network — just swap the builder below) when it's set;
/// otherwise it falls back to an icon for the provider's category. No
/// other code needs to change once real photos are available.
class ServiceProviderCard extends StatelessWidget {
  final ServiceProvider provider;
  final VoidCallback? onTap;

  const ServiceProviderCard({
    super.key,
    required this.provider,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.maroonCard,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ImageBox(provider: provider),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      provider.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          provider.category.label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          '|',
                          style: TextStyle(color: Colors.white54, fontSize: 14),
                        ),
                        const SizedBox(width: 6),
                        const _BadgeIcon(
                          icon: Icons.attach_money_rounded,
                          background: Colors.white,
                          iconColor: AppColors.maroonCard,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          provider.priceLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 15, color: Colors.white70),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${provider.location.label}  |  ${provider.availabilityLabel}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 14,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: provider.contacts
                          .map((c) => _ContactChip(contact: c))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImageBox extends StatelessWidget {
  final ServiceProvider provider;
  const _ImageBox({required this.provider});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 68,
        height: 68,
        color: const Color(0xFFF2E9E8),
        alignment: Alignment.center,
        // Swap this child for `Image.asset(provider.imagePath!, fit:
        // BoxFit.cover)` or `Image.network(...)` once real photos exist —
        // the rest of the card needs no changes.
        child: provider.imagePath != null
            ? Image.asset(provider.imagePath!, fit: BoxFit.cover, width: 68, height: 68)
            : Icon(
                provider.category.fallbackIcon,
                size: 32,
                color: AppColors.maroonCard,
              ),
      ),
    );
  }
}

class _BadgeIcon extends StatelessWidget {
  final IconData icon;
  final Color background;
  final Color iconColor;

  const _BadgeIcon({
    required this.icon,
    required this.background,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Icon(icon, size: 10, color: iconColor),
    );
  }
}

class _ContactChip extends StatelessWidget {
  final ContactInfo contact;
  const _ContactChip({required this.contact});

  @override
  Widget build(BuildContext context) {
    switch (contact.type) {
      case ContactType.phone:
        return _row(
          const Icon(Icons.call, size: 15, color: Colors.white),
          contact.value,
        );
      case ContactType.whatsapp:
        return _row(
          const _BadgeIcon(
            icon: Icons.chat_bubble,
            background: AppColors.whatsappGreen,
            iconColor: Colors.white,
          ),
          contact.value,
        );
      case ContactType.email:
        return _row(
          const _BadgeIcon(
            icon: Icons.alternate_email,
            background: Colors.white,
            iconColor: AppColors.maroonCard,
          ),
          contact.value,
        );
    }
  }

  Widget _row(Widget icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon,
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}