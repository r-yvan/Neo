import 'package:flutter/material.dart';

import '../../../core/l10n/strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/neo_widgets.dart';
import '../../../data/models/map_models.dart';
import '../../equipment/widgets/equipment_card.dart' show equipmentCategoryIcon;

/// Card in the bottom carousel for one lender or borrower.
class MapPersonCard extends StatelessWidget {
  const MapPersonCard({
    super.key,
    required this.person,
    required this.selected,
    required this.onTap,
    required this.onProfile,
    required this.onMessage,
  });

  final MapPerson person;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onProfile;
  final VoidCallback onMessage;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final S s = L10n.i;
    final MapPerson p = person;
    final bool lender = p is MapLender;

    final List<String> meta = <String>[
      s.mapKmAway(p.distanceKm),
      if (p.locationLabel != null) p.locationLabel!,
    ];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppRadii.xlAll,
        border: Border.all(
          color: selected
              ? (lender ? AppColors.accent : theme.colorScheme.onSurface)
              : theme.colorScheme.outline,
          width: selected ? 1.6 : 1,
        ),
        boxShadow: AppShadows.raised,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppRadii.xlAll,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    NeoAvatar(initials: p.initials, imageUrl: p.profileImage, size: 44),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Flexible(
                                child: Text(p.fullName,
                                    style: theme.textTheme.titleSmall,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                              ),
                              if (p.isVerified) ...<Widget>[
                                const SizedBox(width: 4),
                                const Icon(Icons.verified_rounded,
                                    size: 15, color: AppColors.success),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(meta.join(' · '),
                              style: theme.textTheme.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    NeoBadge(
                      label: lender ? s.mapLender : s.mapBorrower,
                      tone: lender ? BadgeTone.accent : BadgeTone.neutral,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(child: lender ? _lenderBody(context, p) : _borrowerBody(context, p as MapBorrower)),
                const SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    if (p.totalReviews > 0)
                      RatingRow(rating: p.averageRating, reviewCount: p.totalReviews)
                    else if (p is MapBorrower && p.activeAt != null)
                      Text(s.mapActive(Dates.relative(p.activeAt)),
                          style: theme.textTheme.bodySmall),
                    const Spacer(),
                    _Pill(
                      label: s.mapViewProfile,
                      icon: Icons.person_outline_rounded,
                      onTap: onProfile,
                    ),
                    const SizedBox(width: 8),
                    _Pill(
                      label: s.mapMessage,
                      icon: Icons.chat_bubble_outline_rounded,
                      primary: true,
                      onTap: onMessage,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _lenderBody(BuildContext context, MapLender l) {
    final ThemeData theme = Theme.of(context);
    final S s = L10n.i;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        for (final category in l.categories.take(4))
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                color: AppColors.accentSoft,
                borderRadius: AppRadii.smAll,
              ),
              child: Icon(equipmentCategoryIcon(category), size: 16, color: AppColors.accent),
            ),
          ),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(s.mapListings(l.listingCount), style: theme.textTheme.bodySmall),
              Text.rich(
                TextSpan(children: <InlineSpan>[
                  TextSpan(text: '${s.mapFromPrice} ', style: theme.textTheme.bodySmall),
                  TextSpan(
                    text: Money.format(l.minPricePerDay),
                    style: theme.textTheme.titleSmall?.copyWith(color: AppColors.accent),
                  ),
                  TextSpan(text: s.perDay, style: theme.textTheme.bodySmall),
                ]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _borrowerBody(BuildContext context, MapBorrower b) {
    final ThemeData theme = Theme.of(context);
    final S s = L10n.i;
    final String text = (b.note ?? '').isEmpty ? s.mapApproxArea : b.note!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: AppRadii.mdAll,
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.format_quote_rounded, size: 18, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              (b.note ?? '').isEmpty ? text : '${s.mapLookingFor}: $text',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.icon, required this.onTap, this.primary = false});

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color fg = primary ? Colors.white : theme.colorScheme.onSurface;
    return Material(
      color: primary ? AppColors.accent : theme.colorScheme.surfaceContainerHighest,
      borderRadius: AppRadii.pillAll,
      child: InkWell(
        borderRadius: AppRadii.pillAll,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, size: 15, color: fg),
              const SizedBox(width: 5),
              Text(label, style: theme.textTheme.labelMedium?.copyWith(color: fg)),
            ],
          ),
        ),
      ),
    );
  }
}
