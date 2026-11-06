import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/l10n/strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/neo_widgets.dart';
import '../../../data/models/models.dart';
import '../../../data/providers.dart';
import '../../../data/repositories/equipment_repository.dart';
import '../../equipment/equipment_detail_page.dart';
import '../../equipment/widgets/equipment_card.dart';

/// `GET /equipment/popular` — most booked / best rated right now.
final AutoDisposeFutureProvider<List<Equipment>> popularEquipmentProvider =
    FutureProvider.autoDispose<List<Equipment>>((Ref ref) async =>
        (await ref.watch(equipmentRepositoryProvider).popular(limit: 10)).items);

/// `GET /equipment/nearby` — around Kigali centre until device location is
/// wired in.
final AutoDisposeFutureProvider<List<Equipment>> nearbyEquipmentProvider =
    FutureProvider.autoDispose<List<Equipment>>((Ref ref) async =>
        (await ref.watch(equipmentRepositoryProvider).nearby(const EquipmentQuery(
          limit: 10,
          latitude: AppConfig.defaultLatitude,
          longitude: AppConfig.defaultLongitude,
          radiusKm: 25,
        )))
            .items);

/// Horizontal "Popular" and "Near you" rails shown above the full catalogue
/// when no filter is active. Each rail hides itself if it has nothing to show.
class DiscoveryRails extends ConsumerWidget {
  const DiscoveryRails({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S s = L10n.i;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _Rail(
          title: s.explorePopular,
          icon: Icons.local_fire_department_rounded,
          data: ref.watch(popularEquipmentProvider),
        ),
        _Rail(
          title: s.exploreNearby,
          subtitle: s.exploreNearbySub,
          icon: Icons.near_me_rounded,
          data: ref.watch(nearbyEquipmentProvider),
        ),
      ],
    );
  }
}

class _Rail extends StatelessWidget {
  const _Rail({
    required this.title,
    required this.icon,
    required this.data,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final AsyncValue<List<Equipment>> data;

  static const double _cardWidth = 188;
  static const double _height = 262;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<Equipment>? items = data.valueOrNull;
    if (data.hasError || (items != null && items.isEmpty)) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: <Widget>[
                Icon(icon, size: 18, color: AppColors.accent),
                const SizedBox(width: 6),
                Text(title, style: theme.textTheme.titleMedium),
                if (subtitle != null) ...<Widget>[
                  const SizedBox(width: 8),
                  Text(subtitle!, style: theme.textTheme.bodySmall),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: _height,
            child: items == null
                ? ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    scrollDirection: Axis.horizontal,
                    itemCount: 3,
                    separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
                    itemBuilder: (_, __) => const SizedBox(
                      width: _cardWidth,
                      child: SkeletonCard(height: _height),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    scrollDirection: Axis.horizontal,
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
                    itemBuilder: (BuildContext context, int i) => EquipmentCard(
                      item: items[i],
                      width: _cardWidth,
                      onTap: () => Navigator.of(context).push<void>(
                        MaterialPageRoute<void>(
                          builder: (BuildContext _) =>
                              EquipmentDetailPage(equipmentId: items[i].id),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
