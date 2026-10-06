import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_config.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/parsing.dart';
import '../../core/widgets/neo_widgets.dart';
import '../../data/models/models.dart';
import '../../data/providers.dart';
import '../../data/repositories/equipment_repository.dart';
import '../../data/repositories/users_repository.dart';
import '../common/paginated_list_controller.dart';
import '../equipment/equipment_detail_page.dart';
import '../equipment/widgets/equipment_card.dart';
import '../favorites/favorites_page.dart';
import '../notifications/notifications_page.dart';

/// Home / Explore.
///
/// Boosted listings already come back first from `GET /equipment`, so the grid
/// is rendered in response order and nothing is re-sorted client-side.
class ExplorePage extends ConsumerStatefulWidget {
  const ExplorePage({super.key});

  @override
  ConsumerState<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends ConsumerState<ExplorePage> {
  final TextEditingController _search = TextEditingController();
  final ScrollController _scroll = ScrollController();

  String? _category;
  String? _location;
  EquipmentQuery _query = const EquipmentQuery();
  Timer? _debounce;

  late final NotifierProvider<PaginatedListController<Equipment>,
      PaginatedList<Equipment>> _listProvider;

  @override
  void initState() {
    super.initState();
    _listProvider = NotifierProvider<PaginatedListController<Equipment>,
        PaginatedList<Equipment>>(
      PaginatedListController<Equipment>(_fetch, pageSize: AppConfig.pageSize),
    );
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scroll.dispose();
    _search.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final double remaining =
        _scroll.position.maxScrollExtent - _scroll.position.pixels;
    if (remaining < 600) {
      ref.read(_listProvider.notifier).loadMore();
    }
  }

  Future<PaginatedList<Equipment>> _fetch(int page, int limit) async {
    final result = await ref
        .read(equipmentRepositoryProvider)
        .list(_query.copyWith(page: page, limit: limit));
    return result;
  }

  void _applyQuery({String? search, EquipmentCategory? category, bool clearCategory = false, String? location}) {
    setState(() {
      _query = _query.copyWith(
        page: 1,
        search: search,
        category: category,
        clearCategory: clearCategory,
        location: location ?? _location,
      );
    });
    ref.invalidate(_listProvider);
  }

  Future<void> _openFilters() async {
    final EquipmentQuery? result = await showNeoSheet<EquipmentQuery>(
      context,
      scrollable: true,
      child: _FilterSheet(initial: _query),
    );
    if (result == null || !mounted) return;
    setState(() {
      _query = result;
      _category = result.category?.wire;
      _location = result.location;
    });
    ref.invalidate(_listProvider);
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<PaginatedList<Equipment>> list =
        ref.watch(_listProvider);
    final AppUser? user = ref.watch(sessionProvider).user;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.accent,
          onRefresh: () async {
            await ref.read(_listProvider.notifier).refresh();
            ref.invalidate(platformConfigProvider);
          },
          child: CustomScrollView(
            controller: _scroll,
            slivers: [
              SliverToBoxAdapter(child: _header(context, user)),
              SliverToBoxAdapter(child: _searchBar(context)),
              SliverToBoxAdapter(child: _categories(context)),
              SliverToBoxAdapter(child: _metaRow(context)),
              ..._body(list),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context, AppUser? user) {
    final ThemeData theme = Theme.of(context);
    final DateTime hour = DateTime.now();
    final String greeting = hour.hour < 12
        ? 'Good morning'
        : (hour.hour < 18 ? 'Good afternoon' : 'Good evening');

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        0,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user == null
                      ? greeting
                      : '$greeting, ${user.fullName.split(' ').first}',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 2),
                Text('Find your event gear', style: theme.textTheme.displayMedium),
              ],
            ),
          ),
          NotificationsButton(
            onTap: () => Navigator.of(context).push<void>(
              MaterialPageRoute<void>(
                builder: (BuildContext _) => const NotificationsPage(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        0,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _search,
              textInputAction: TextInputAction.search,
              onChanged: (String value) {
                _debounce?.cancel();
                _debounce = Timer(const Duration(milliseconds: 420), () {
                  if (mounted) _applyQuery(search: value.trim());
                });
              },
              onSubmitted: (String value) =>
                  _applyQuery(search: value.trim()),
              decoration: const InputDecoration(
                hintText: 'Chairs, tents, speakers…',
                prefixIcon: Icon(Icons.search_rounded, size: 20),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          _FilterButton(
            active: _query.isFiltered,
            onTap: _openFilters,
          ),
        ],
      ),
    );
  }

  Widget _categories(BuildContext context) {
    return SizedBox(
      height: 62,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          0,
        ),
        children: <Widget>[
          NeoChip(
            label: 'All',
            selected: _category == null,
            onTap: () => _applyQuery(clearCategory: true, search: _search.text.trim()),
          ),
          const SizedBox(width: AppSpacing.xs),
          ...EquipmentCategory.values.map((EquipmentCategory category) {
            return Padding(
              padding: const EdgeInsets.only(right: AppSpacing.xs),
              child: NeoChip(
                label: _shortLabel(category),
                icon: equipmentCategoryIcon(category),
                selected: _category == category.wire,
                onTap: () => _applyQuery(
                  category: category,
                  search: _search.text.trim(),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _metaRow(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AsyncValue<PaginatedList<Equipment>> list =
        ref.watch(_listProvider);

    final String count = list.whenOrNull(
          data: (PaginatedList<Equipment> p) =>
              '${p.meta['total'] ?? p.items.length} items',
          orElse: () => '',
        );

    final List<String> active = <String>[
      if (_location != null) _location!,
      if (_query.minPrice != null || _query.maxPrice != null) 'Price filter',
      if (_query.date != null) Dates.short(_query.date!),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          Text(count, style: theme.textTheme.labelMedium),
          if (active.isNotEmpty) ...[
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: active
                      .map((String a) => NeoBadge(
                            label: a,
                            tone: BadgeTone.accent,
                            icon: Icons.filter_alt_off_rounded,
                          ))
                      .toList(),
                ),
              ),
            ),
          ],
          const Spacer(),
          if (_query.isFiltered)
            TextButton(
              onPressed: () {
                _search.clear();
                setState(() {
                  _category = null;
                  _location = null;
                  _query = const EquipmentQuery();
                });
                ref.invalidate(_listProvider);
              },
              child: const Text('Clear'),
            ),
        ],
      ),
    );
  }

  List<Widget> _body(AsyncValue<PaginatedList<Equipment>> list) {
    return list.when(
      loading: () => <Widget>[
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          sliver: _grid(
            List<Widget>.generate(
              6,
              (int i) => const SkeletonCard(height: 210),
            ),
          ),
        ),
      ],
      error: (Object error, StackTrace _) => <Widget>[
        SliverFillRemaining(
          hasScrollBody: false,
          child: NeoErrorState(
            message: error is ApiException
                ? error.message
                : 'Could not load equipment.',
            onRetry: () => ref.read(_listProvider.notifier).loadInitial(),
          ),
        ),
      ],
      data: (PaginatedList<Equipment> page) {
        if (page.isEmpty) {
          return <Widget>[
            SliverFillRemaining(
              hasScrollBody: false,
              child: NeoEmptyState(
                icon: Icons.search_off_rounded,
                title: _query.isFiltered
                    ? 'No matches'
                    : 'No equipment yet',
                message: _query.isFiltered
                    ? 'Try a different category, area or price range.'
                    : 'Be the first to list chairs, tables or sound on Neo.',
                actionLabel: _query.isFiltered ? 'Clear filters' : null,
                onAction: () {
                  _search.clear();
                  setState(() {
                    _category = null;
                    _location = null;
                    _query = const EquipmentQuery();
                  });
                  ref.invalidate(_listProvider);
                },
              ),
            ),
          ];
        }
        return <Widget>[
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            sliver: _grid(
              page.items.asMap().entries.map((MapEntry<int, Equipment> e) {
                return EquipmentCard(
                  item: e.value,
                  onTap: () => Navigator.of(context).push<void>(
                    MaterialPageRoute<void>(
                      builder: (BuildContext _) => EquipmentDetailPage(
                        equipmentId: e.value.id,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          SliverToBoxAdapter(
            child: ListFooterLoader(
              loading: ref.watch(_listProvider.notifier).isLoadingMore,
              endLabel: page.hasMore ? null : 'That is everything for now',
            ),
          ),
        ];
      },
    );
  }

  Widget _grid(List<Widget> children) => SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: AppSpacing.sm,
          crossAxisSpacing: AppSpacing.sm,
          childAspectRatio: 0.63,
        ),
        delegate: SliverChildListDelegate(children),
      );

  String _shortLabel(EquipmentCategory category) => switch (category) {
        EquipmentCategory.chairs => 'Chairs',
        EquipmentCategory.tables => 'Tables',
        EquipmentCategory.tents => 'Tents',
        EquipmentCategory.speakers => 'Sound',
        EquipmentCategory.lights => 'Lights',
        EquipmentCategory.coolers => 'Coolers',
        EquipmentCategory.generators => 'Power',
        EquipmentCategory.decorations => 'Decor',
        EquipmentCategory.other => 'Other',
      };
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.active, required this.onTap});

  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? AppColors.accent : Theme.of(context).colorScheme.surface,
      borderRadius: AppRadii.mdAll,
      child: InkWell(
        borderRadius: AppRadii.mdAll,
        onTap: onTap,
        child: Container(
          height: 54,
          width: 54,
          decoration: BoxDecoration(
            borderRadius: AppRadii.mdAll,
            border: Border.all(
              color: active
                  ? AppColors.accent
                  : Theme.of(context).colorScheme.outline,
            ),
          ),
          child: Icon(
            Icons.tune_rounded,
            size: 21,
            color: active ? Colors.white : null,
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet for price, date and location filters.
class _FilterSheet extends ConsumerStatefulWidget {
  const _FilterSheet({required this.initial});

  final EquipmentQuery initial;

  @override
  ConsumerState<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<_FilterSheet> {
  late EquipmentQuery _query = widget.initial;
  late final TextEditingController _location =
      TextEditingController(text: widget.initial.location ?? '');
  late DateTime? _date = widget.initial.date;

  @override
  void dispose() {
    _location.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AsyncValue<List<RwandaLocation>> locations =
        ref.watch(locationsProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Filters', style: theme.textTheme.headlineMedium),
          const SizedBox(height: AppSpacing.lg),
          Text('Where', style: theme.textTheme.titleSmall),
          const SizedBox(height: AppSpacing.xs),
          NeoField(
            label: 'Sector or district',
            hint: 'Kigali - Nyarugenge',
            controller: _location,
            prefixIcon: Icons.place_outlined,
          ),
          if (locations.hasValue && locations.value!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: locations.value!
                  .take(4)
                  .expand((RwandaLocation l) => l.districts.take(4))
                  .map((String district) => NeoChip(
                        label: district,
                        dense: true,
                        selected: _location.text == district,
                        onTap: () => setState(() {
                          _location.text = district;
                          _query = _query.copyWith(location: district);
                        }),
                      ))
                  .toList(),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Text('Daily price (RWF)', style: theme.textTheme.titleSmall),
              const Spacer(),
              Text(
                _priceLabel,
                style: theme.textTheme.labelMedium
                    ?.copyWith(color: AppColors.accent),
              ),
            ],
          ),
          RangeSlider(
            values: RangeValues(
              (_query.minPrice ?? 0).toDouble(),
              (_query.maxPrice ?? 200000).toDouble(),
            ),
            min: 0,
            max: 200000,
            divisions: 40,
            labels: RangeLabels(
              _shortPrice(_query.minPrice ?? 0),
              _shortPrice(_query.maxPrice ?? 200000),
            ),
            onChanged: (RangeValues v) => setState(() {
              _query = _query.copyWith(
                minPrice: v.start <= 0 ? null : v.start,
                maxPrice: v.end >= 200000 ? null : v.end,
              );
            }),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text('Available on', style: theme.textTheme.titleSmall),
          const SizedBox(height: AppSpacing.xs),
          NeoCard(
            onTap: _pickDate,
            child: Row(
              children: [
                const Icon(Icons.event_rounded, size: 20, color: AppColors.accent),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    _date == null
                        ? 'Any date'
                        : '${Dates.weekdayLong(_date!)} ${Dates.full(_date!)}',
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                if (_date != null)
                  TextButton(
                    onPressed: () => setState(() {
                      _date = null;
                      _query = _query.copyWith(clearDate: true);
                    }),
                    child: const Text('Clear'),
                  )
                else
                  const Icon(Icons.chevron_right_rounded, size: 20),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          NeoButton(
            label: 'Show results',
            onPressed: () {
              Navigator.of(context).pop(
                _query.copyWith(location: _location.text.trim()),
              );
            },
          ),
          const SizedBox(height: AppSpacing.xs),
          NeoButton(
            label: 'Reset',
            variant: NeoButtonVariant.ghost,
            onPressed: () => Navigator.of(context).pop(const EquipmentQuery()),
          ),
        ],
      ),
    );
  }

  String get _priceLabel {
    final double? min = _query.minPrice;
    final double? max = _query.maxPrice;
    if (min == null && max == null) return 'Any';
    return '${min == null ? '0' : _shortPrice(min)} – '
        '${max == null ? '200K+' : _shortPrice(max)}';
  }

  String _shortPrice(double v) => Money.compact(v).replaceAll(' RWF', '');

  Future<void> _pickDate() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      helpText: 'When do you need it?',
    );
    if (picked != null) {
      setState(() {
        _date = picked;
        _query = _query.copyWith(date: picked);
      });
    }
  }
}

/// Bell with an unread dot driven by `GET /notifications/unread`.
class NotificationsButton extends ConsumerStatefulWidget {
  const NotificationsButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  ConsumerState<NotificationsButton> createState() => _NotificationsButtonState();
}

class _NotificationsButtonState extends ConsumerState<NotificationsButton> {
  int _unread = 0;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_load);
  }

  Future<void> _load() async {
    try {
      final result = await ref
          .read(notificationsRepositoryProvider)
          .unread(limit: 1);
      if (mounted) {
        setState(() {
          _unread = result.meta['total'] as int? ?? 0;
          _loaded = true;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loaded = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return IconButton(
      onPressed: () {
        _load();
        widget.onTap();
      },
      icon: Badge(
        isLabelVisible: _unread > 0,
        backgroundColor: AppColors.accent,
        label: Text('$_unread'),
        child: const Icon(Icons.notifications_none_rounded, size: 24),
      ),
      tooltip: 'Notifications',
      style: IconButton.styleFrom(
        backgroundColor: theme.colorScheme.surface,
        shape: const CircleBorder(),
      ),
    );
  }
}