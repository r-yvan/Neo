import 'package:flutter/material.dart';

import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/neo_widgets.dart';
import '../../data/repositories/users_repository.dart' show PaginatedList;

/// Imperative handle so a parent can refresh or patch the list after a
/// mutation (approve, ban, resolve…).
class PagedListController<T> {
  _PagedListViewState<T>? _state;

  Future<void> refresh() async => _state?._load();

  void replaceWhere(bool Function(T) test, T Function(T) update) =>
      _state?._replace(test, update);

  void removeWhere(bool Function(T) test) => _state?._remove(test);
}

/// A pull-to-refresh, infinitely scrolling list over any paginated endpoint,
/// with skeleton loading, empty and error states built in.
class PagedListView<T> extends StatefulWidget {
  const PagedListView({
    super.key,
    required this.fetch,
    required this.itemBuilder,
    required this.emptyIcon,
    required this.emptyTitle,
    required this.emptyMessage,
    this.controller,
    this.header,
    this.padding = const EdgeInsets.fromLTRB(20, 8, 20, 32),
    this.separator = 12,
    this.skeletonHeight = 96,
  });

  final Future<PaginatedList<T>> Function(int page) fetch;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptyMessage;
  final PagedListController<T>? controller;

  /// Optional widget built above the items once data has loaded (summary
  /// cards, filters). Receives the loaded items.
  final Widget Function(BuildContext context, List<T> items)? header;
  final EdgeInsets padding;
  final double separator;
  final double skeletonHeight;

  @override
  State<PagedListView<T>> createState() => _PagedListViewState<T>();
}

class _PagedListViewState<T> extends State<PagedListView<T>> {
  List<T> _items = <T>[];
  int _page = 1;
  bool _hasMore = false;
  bool _loading = true;
  bool _loadingMore = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    widget.controller?._state = this;
    _load();
  }

  @override
  void didUpdateWidget(covariant PagedListView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._state = null;
      widget.controller?._state = this;
    }
  }

  @override
  void dispose() {
    if (widget.controller?._state == this) widget.controller?._state = null;
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = _items.isEmpty;
      _error = null;
    });
    try {
      final PaginatedList<T> page = await widget.fetch(1);
      if (!mounted) return;
      setState(() {
        _items = List<T>.from(page.items);
        _page = 1;
        _hasMore = page.hasMore;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || !_hasMore || _error != null) return;
    setState(() => _loadingMore = true);
    try {
      final PaginatedList<T> page = await widget.fetch(_page + 1);
      if (!mounted) return;
      setState(() {
        _items = <T>[..._items, ...page.items];
        _page += 1;
        _hasMore = page.hasMore;
      });
    } on ApiException catch (e) {
      if (mounted) showNeoSnack(context, e.message, isError: true);
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  void _replace(bool Function(T) test, T Function(T) update) => setState(
      () => _items = _items.map((T e) => test(e) ? update(e) : e).toList());

  void _remove(bool Function(T) test) =>
      setState(() => _items = _items.where((T e) => !test(e)).toList());

  @override
  Widget build(BuildContext context) {
    final Widget body;
    if (_loading) {
      body = ListView.separated(
        padding: widget.padding,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: 5,
        separatorBuilder: (_, __) => SizedBox(height: widget.separator),
        itemBuilder: (_, __) => SkeletonCard(height: widget.skeletonHeight),
      );
    } else if (_error != null && _items.isEmpty) {
      body = ListView(
        padding: widget.padding,
        physics: const AlwaysScrollableScrollPhysics(),
        children: <Widget>[
          const SizedBox(height: 80),
          NeoErrorState(message: _error!, onRetry: _load),
        ],
      );
    } else if (_items.isEmpty) {
      body = ListView(
        padding: widget.padding,
        physics: const AlwaysScrollableScrollPhysics(),
        children: <Widget>[
          if (widget.header != null) widget.header!(context, _items),
          const SizedBox(height: 48),
          NeoEmptyState(
            icon: widget.emptyIcon,
            title: widget.emptyTitle,
            message: widget.emptyMessage,
          ),
        ],
      );
    } else {
      final bool hasHeader = widget.header != null;
      final int offset = hasHeader ? 1 : 0;
      body = NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification n) {
          if (n.metrics.pixels > n.metrics.maxScrollExtent - 320) _loadMore();
          return false;
        },
        child: ListView.separated(
          padding: widget.padding,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: _items.length + offset + 1,
          separatorBuilder: (_, __) => SizedBox(height: widget.separator),
          itemBuilder: (BuildContext context, int i) {
            if (hasHeader && i == 0) return widget.header!(context, _items);
            final int index = i - offset;
            if (index == _items.length) {
              return ListFooterLoader(loading: _loadingMore);
            }
            return widget.itemBuilder(context, _items[index]);
          },
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.accent,
      onRefresh: _load,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: KeyedSubtree(
          key: ValueKey<String>(
              _loading ? 'loading' : (_items.isEmpty ? 'empty' : 'list')),
          child: body,
        ),
      ),
    );
  }
}
