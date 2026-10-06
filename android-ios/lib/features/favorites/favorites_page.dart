import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/neo_widgets.dart';
import '../../data/models/models.dart';
import '../../data/providers.dart';
import '../equipment/equipment_detail_page.dart';
import '../equipment/widgets/equipment_card.dart';

/// Saved listings. Backed by `GET /favorites` with infinite scroll.
class FavoritesPage extends ConsumerStatefulWidget {
  const FavoritesPage({super.key});

  @override
  ConsumerState<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends ConsumerState<FavoritesPage> {
  List<FavoriteEntry> _items = const <FavoriteEntry>[];
  int _page = 1;
  bool _hasMore = true;
  bool _loading = true;
  bool _loadingMore = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_load);
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final PaginatedList<FavoriteEntry> page =
          await ref.read(favoritesRepositoryProvider).list();
      if (!mounted) return;
      setState(() {
        _items = page.items;
        _page = 1;
        _hasMore = page.hasMore;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message;
          _loading = false;
        });
      }
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || !_hasMore) return;
    setState(() => _loadingMore = true);
    try {
      final PaginatedList<FavoriteEntry> page =
          await ref.read(favoritesRepositoryProvider).list(page: _page + 1);
      if (!mounted) return;
      setState(() {
        _items = <FavoriteEntry>[..._items, ...page.items];
        _page = _page + 1;
        _hasMore = page.hasMore;
        _loadingMore = false;
      });
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message;
          _loadingMore = false;
        });
      }
    }
  }

  Future<void> _remove(FavoriteEntry entry) async {
    setState(() {
      _items = _items
          .where((FavoriteEntry e) => e.equipment.id != entry.equipment.id)
          .toList();
    });
    try {
      await ref.read(favoritesRepositoryProvider).remove(entry.equipment.id);
    } on ApiException catch (e) {
      if (mounted) {
        showNeoSnack(context, e.message, isError: true);
        _load();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.accent,
          onRefresh: _load,
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification notification) {
              if (notification.metrics.pixels >
                  notification.metrics.maxScrollExtent - 400) {
                _loadMore();
              }
              return false;
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.sm,
                      AppSpacing.lg,
                      AppSpacing.md,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text('Saved', style: theme.textTheme.displayMedium),
                        ),
                        if (_items.isNotEmpty)
                          Text(
                            '${_items.length} item${_items.length == 1 ? '' : 's'}',
                            style: theme.textTheme.bodySmall,
                          ),
                      ],
                    ),
                  ),
                ),
                ..._body(),
                const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _body() {
    if (_loading && _items.isEmpty) {
      return <Widget>[
        const SliverFillRemaining(
          hasScrollBody: false,
          child: NeoLoading(),
        ),
      ];
    }
    if (_error != null && _items.isEmpty) {
      return <Widget>[
        SliverFillRemaining(
          hasScrollBody: false,
          child: NeoErrorState(message: _error!, onRetry: _load),
        ),
      ];
    }
    if (_items.isEmpty) {
      return <Widget>[
        SliverFillRemaining(
          hasScrollBody: false,
          child: NeoEmptyState(
            icon: Icons.favorite_border_rounded,
            title: 'Nothing saved yet',
            message:
                'Tap the heart on any listing to keep it here while you compare options.',
          ),
        ),
      ];
    }
    return <Widget>[
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) => Dismissible(
              key: ValueKey<String>(_items[index].equipment.id),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.danger.withValues(alpha: 0.12),
                  borderRadius: AppRadii.lgAll,
                ),
                child: const Icon(Icons.delete_outline_rounded,
                    color: AppColors.danger),
              ),
              onDismissed: (_) => _remove(_items[index]),
              child: EquipmentListTile(
                item: _items[index].equipment,
                onTap: () => Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(
                    builder: (BuildContext _) => EquipmentDetailPage(
                      equipmentId: _items[index].equipment.id,
                    ),
                  ),
                ),
              ),
            ),
            childCount: _items.length,
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: ListFooterLoader(
          loading: _loadingMore,
          endLabel: _hasMore ? null : 'End of your saved list',
        ),
      ),
    ];
  }
}