import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/strings.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/neo_widgets.dart';
import '../../data/models/admin_models.dart';
import '../../data/providers.dart';
import 'admin_tabs.dart';

/// Back-office for ADMIN accounts: platform health at a glance plus
/// moderation queues for users, listings, money, trust & safety and reviews.
class AdminConsolePage extends ConsumerStatefulWidget {
  const AdminConsolePage({super.key});

  @override
  ConsumerState<AdminConsolePage> createState() => _AdminConsolePageState();
}

class _AdminConsolePageState extends ConsumerState<AdminConsolePage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 6, vsync: this);

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final S s = L10n.i;
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(s.adminTitle, style: theme.textTheme.headlineMedium),
        bottom: TabBar(
          controller: _tabs,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelColor: AppColors.accent,
          indicatorColor: AppColors.accent,
          indicatorSize: TabBarIndicatorSize.label,
          dividerColor: theme.colorScheme.outline,
          labelStyle: theme.textTheme.titleSmall,
          unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
          tabs: <Widget>[
            Tab(text: s.adminOverview),
            Tab(text: s.adminUsers),
            Tab(text: s.adminListings),
            Tab(text: s.adminMoney),
            Tab(text: s.adminTrust),
            Tab(text: s.adminReviews),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: <Widget>[
          _Overview(onJump: (int i) => _tabs.animateTo(i)),
          const AdminUsersTab(),
          const AdminListingsTab(),
          const AdminMoneyTab(),
          const AdminTrustTab(),
          const AdminReviewsTab(),
        ],
      ),
    );
  }
}

final AutoDisposeFutureProvider<(AdminStats, AdminAnalytics)>
    _overviewProvider =
    FutureProvider.autoDispose<(AdminStats, AdminAnalytics)>((Ref ref) async {
  final repo = ref.watch(adminRepositoryProvider);
  final List<Object> res =
      await Future.wait<Object>(<Future<Object>>[repo.dashboard(), repo.analytics()]);
  return (res[0] as AdminStats, res[1] as AdminAnalytics);
});

class _Overview extends ConsumerWidget {
  const _Overview({required this.onJump});

  final ValueChanged<int> onJump;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<(AdminStats, AdminAnalytics)> data =
        ref.watch(_overviewProvider);
    return RefreshIndicator(
      color: AppColors.accent,
      onRefresh: () => ref.refresh(_overviewProvider.future),
      child: data.when(
        loading: () => ListView(
          padding: const EdgeInsets.all(20),
          children: const <Widget>[
            SkeletonCard(height: 150),
            SizedBox(height: 12),
            SkeletonCard(height: 220),
          ],
        ),
        error: (Object e, _) => ListView(children: <Widget>[
          const SizedBox(height: 120),
          NeoErrorState(
            message: e is ApiException ? e.message : '$e',
            onRetry: () => ref.invalidate(_overviewProvider),
          ),
        ]),
        data: ((AdminStats, AdminAnalytics) v) =>
            _OverviewBody(stats: v.$1, analytics: v.$2, onJump: onJump),
      ),
    );
  }
}

class _OverviewBody extends StatelessWidget {
  const _OverviewBody({
    required this.stats,
    required this.analytics,
    required this.onJump,
  });

  final AdminStats stats;
  final AdminAnalytics analytics;
  final ValueChanged<int> onJump;

  @override
  Widget build(BuildContext context) {
    final S s = L10n.i;
    final ThemeData theme = Theme.of(context);
    final int attention = stats.openReports + stats.openDisputes;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      children: <Widget>[
        // Revenue hero.
        Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            borderRadius: AppRadii.xlAll,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[AppColors.accent, Color(0xFFFF7A5C)],
            ),
            boxShadow: AppShadows.accent,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  const Icon(Icons.insights_rounded, color: Colors.white, size: 18),
                  const SizedBox(width: 6),
                  Text(s.adminRevenue.toUpperCase(),
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: Colors.white.withValues(alpha: 0.85))),
                ],
              ),
              const SizedBox(height: 10),
              Text(Money.format(stats.totalRevenue),
                  style: theme.textTheme.displayMedium?.copyWith(color: Colors.white)),
              const SizedBox(height: 4),
              Text(s.adminRevenueSub,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: Colors.white.withValues(alpha: 0.85))),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.5,
          children: <Widget>[
            StatTile(
                label: s.adminUsers,
                value: '${stats.totalUsers}',
                icon: Icons.people_alt_outlined,
                onTap: () => onJump(1)),
            StatTile(
                label: s.adminListings,
                value: '${stats.totalEquipment}',
                icon: Icons.inventory_2_outlined,
                onTap: () => onJump(2)),
            StatTile(
                label: s.adminBookings,
                value: '${stats.totalBookings}',
                icon: Icons.receipt_long_outlined,
                onTap: () => onJump(3)),
            StatTile(
                label: s.adminPending,
                value: '${stats.pendingBookings}',
                icon: Icons.hourglass_top_rounded),
            StatTile(
                label: s.adminCompleted,
                value: '${stats.completedBookings}',
                icon: Icons.task_alt_rounded),
            StatTile(
                label: s.adminTrust,
                value: '$attention',
                icon: Icons.shield_outlined,
                tone: attention > 0 ? AppColors.accent : null,
                onTap: () => onJump(4)),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        SectionHeader(title: s.adminNeedsAttention),
        const SizedBox(height: AppSpacing.xs),
        if (attention == 0)
          NeoCard(
            child: Row(
              children: <Widget>[
                const Icon(Icons.verified_rounded, color: AppColors.success),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: Text(s.adminAllClear, style: theme.textTheme.bodyMedium)),
              ],
            ),
          )
        else
          Row(
            children: <Widget>[
              Expanded(
                child: _AttentionCard(
                  icon: Icons.flag_outlined,
                  label: s.adminOpenReports,
                  count: stats.openReports,
                  onTap: () => onJump(4),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _AttentionCard(
                  icon: Icons.gavel_rounded,
                  label: s.adminOpenDisputes,
                  count: stats.openDisputes,
                  onTap: () => onJump(4),
                ),
              ),
            ],
          ),
        const SizedBox(height: AppSpacing.lg),
        SectionHeader(title: s.adminLast30),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: <Widget>[
            Expanded(
                child: StatTile(
                    label: s.adminNewUsers,
                    value: '+${analytics.newUsers}',
                    icon: Icons.person_add_alt_1_outlined)),
            const SizedBox(width: 10),
            Expanded(
                child: StatTile(
                    label: s.adminNewBookings,
                    value: '+${analytics.newBookings}',
                    icon: Icons.event_available_outlined)),
            const SizedBox(width: 10),
            Expanded(
                child: StatTile(
                    label: s.adminRevenue,
                    value: Money.compact(analytics.revenueLastMonth),
                    icon: Icons.payments_outlined)),
          ],
        ),
        if (analytics.topEquipment.isNotEmpty) ...<Widget>[
          const SizedBox(height: AppSpacing.lg),
          SectionHeader(title: s.adminTopListings),
          const SizedBox(height: AppSpacing.xs),
          NeoCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: <Widget>[
                for (int i = 0; i < analytics.topEquipment.length; i++)
                  ListTile(
                    leading: CircleAvatar(
                      radius: 16,
                      backgroundColor:
                          i == 0 ? AppColors.accent : AppColors.accentSoft,
                      child: Text('${i + 1}',
                          style: theme.textTheme.labelLarge?.copyWith(
                              color: i == 0 ? Colors.white : AppColors.accent)),
                    ),
                    title: Text(analytics.topEquipment[i].title,
                        style: theme.textTheme.titleSmall,
                        overflow: TextOverflow.ellipsis),
                    subtitle: Text(analytics.topEquipment[i].category.label,
                        style: theme.textTheme.bodySmall),
                    trailing: RatingRow(
                      rating: analytics.topEquipment[i].averageRating,
                      reviewCount: analytics.topEquipment[i].totalReviews,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _AttentionCard extends StatelessWidget {
  const _AttentionCard({
    required this.icon,
    required this.label,
    required this.count,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool hot = count > 0;
    return NeoCard(
      onTap: onTap,
      child: Row(
        children: <Widget>[
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: hot ? AppColors.accentSoft : theme.colorScheme.surfaceContainerHighest,
              borderRadius: AppRadii.mdAll,
            ),
            child: Icon(icon,
                size: 18,
                color: hot ? AppColors.accent : theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('$count',
                    style: theme.textTheme.titleLarge
                        ?.copyWith(color: hot ? AppColors.accent : null)),
                Text(label,
                    style: theme.textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
