import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/neo_widgets.dart';
import '../../../data/models/models.dart';

/// Two-column marketplace tile. Boosted listings carry a distinct accent
/// treatment so paid placement reads instantly.
class EquipmentCard extends StatelessWidget {
  const EquipmentCard({
    super.key,
    required this.item,
    this.onTap,
    this.onFavorite,
    this.favorite = false,
    this.width,
    this.showOwner = true,
  });

  final Equipment item;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final bool favorite;
  final double? width;
  final bool showOwner;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool boosted = item.boostIsActive;

    return SizedBox(
      width: width,
      child: NeoCard(
        onTap: onTap,
        padding: EdgeInsets.zero,
        elevated: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 4 / 3,
                  child: EquipmentImage(
                    source: item.images.isEmpty ? '' : item.images.first,
                    width: double.infinity,
                    radius: 0,
                    fallbackIcon: _categoryIcon(item.category),
                    fallbackLabel: item.category.label,
                  ),
                ),
                if (boosted)
                  Positioned(
                    top: AppSpacing.xs,
                    left: AppSpacing.xs,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: AppRadii.pillAll,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.bolt_rounded,
                              size: 12, color: Colors.white),
                          const SizedBox(width: 2),
                          Text(
                            'Boosted',
                            style: AppTypography.labelSmall
                                .copyWith(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (onFavorite != null)
                  Positioned(
                    top: AppSpacing.xxs,
                    right: AppSpacing.xxs,
                    child: Material(
                      color: Theme.of(context)
                          .colorScheme
                          .surface
                          .withValues(alpha: 0.92),
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: onFavorite,
                        child: Padding(
                          padding: const EdgeInsets.all(7),
                          child: Icon(
                            favorite
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            size: 18,
                            color: favorite
                                ? AppColors.danger
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ),
                if (!item.isAvailable)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.42),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(AppRadii.lg),
                        ),
                      ),
                      child: const Center(
                        child: NeoBadge(
                          label: 'Unavailable',
                          tone: BadgeTone.neutral,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.place_outlined,
                          size: 13, color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          item.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: Money.format(item.pricePerDay),
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(color: theme.colorScheme.onSurface),
                                  ),
                                  TextSpan(
                                    text: ' / day',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (item.totalReviews > 0)
                              Padding(
                                padding: const EdgeInsets.only(top: 3),
                                child: RatingRow(
                                  rating: item.averageRating,
                                  reviewCount: item.totalReviews,
                                  size: 12,
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (showOwner && item.owner != null)
                        NeoAvatar(
                          initials: item.owner!.initials,
                          imageUrl: item.owner!.profileImage,
                          size: 28,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Single-column row used in "my listings", search results and owner views.
class EquipmentListTile extends StatelessWidget {
  const EquipmentListTile({
    super.key,
    required this.item,
    this.onTap,
    this.trailing,
    this.subtitleOverride,
  });

  final Equipment item;
  final VoidCallback? onTap;
  final Widget? trailing;
  final String? subtitleOverride;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: NeoCard(
        onTap: onTap,
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            EquipmentImage(
              source: item.images.isEmpty ? '' : item.images.first,
              width: 84,
              height: 84,
              radius: AppRadii.md,
              fallbackIcon: _categoryIcon(item.category),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitleOverride ?? '${item.category.label} · ${item.location}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '${Money.format(item.pricePerDay)}/day',
                        style: theme.textTheme.titleSmall
                            ?.copyWith(color: AppColors.accent),
                      ),
                      if (item.boostIsActive) ...[
                        const SizedBox(width: AppSpacing.xs),
                        const NeoBadge(
                          label: 'Boosted',
                          tone: BadgeTone.accent,
                          icon: Icons.bolt_rounded,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

IconData _categoryIcon(EquipmentCategory category) => switch (category) {
      EquipmentCategory.chairs => Icons.event_seat_rounded,
      EquipmentCategory.tables => Icons.table_restaurant_rounded,
      EquipmentCategory.tents => Icons.holiday_village_rounded,
      EquipmentCategory.speakers => Icons.speaker_rounded,
      EquipmentCategory.lights => Icons.flare_rounded,
      EquipmentCategory.coolers => Icons.ac_unit_rounded,
      EquipmentCategory.generators => Icons.electric_bolt_rounded,
      EquipmentCategory.decorations => Icons.auto_awesome_rounded,
      EquipmentCategory.other => Icons.inventory_2_rounded,
    };

/// Public so screens can use the same glyph for category headers.
IconData equipmentCategoryIcon(EquipmentCategory category) =>
    _categoryIcon(category);