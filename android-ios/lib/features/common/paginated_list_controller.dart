import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../data/repositories/users_repository.dart';

/// A page-backed list with explicit loading / error / end-of-data states.
///
/// Kept as a plain [Notifier] (no codegen) so the whole lifecycle is readable
/// in one file.
class PaginatedListController<T> extends Notifier<PaginatedList<T>> {
  PaginatedListController(this._fetch,
      {this.pageSize = 20, this.autoLoad = true});

  /// Fetches one page. Implementations receive the 1-based page number.
  final Future<PaginatedList<T>> Function(int page, int limit) _fetch;

  final int pageSize;
  final bool autoLoad;

  bool isLoadingMore = false;
  bool isRefreshing = false;
  String? error;
  bool initialised = false;

  @override
  PaginatedList<T> build() {
    if (autoLoad) {
      Future<void>.microtask(loadInitial);
    }
    return PaginatedList<T>(items: <T>[], meta: <String, dynamic>{});
  }

  List<T> get items => state.items;
  bool get isEmpty => state.items.isEmpty;
  bool get hasMore => state.hasMore;

  void _publish() {
    state = PaginatedList<T>(items: state.items, meta: state.meta);
  }

  Future<void> loadInitial() async {
    error = null;
    initialised = false;
    _publish();
    try {
      state = await _fetch(1, pageSize);
      initialised = true;
    } on ApiException catch (e) {
      error = e.message;
      initialised = true;
      _publish();
    }
  }

  Future<void> refresh() async {
    isRefreshing = true;
    error = null;
    try {
      state = await _fetch(1, pageSize);
    } on ApiException catch (e) {
      error = e.message;
      _publish();
    } finally {
      isRefreshing = false;
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore || !state.hasMore || error != null) return;
    isLoadingMore = true;
    _publish();
    final int next = state.page + 1;
    try {
      state = state.merge(await _fetch(next, pageSize));
    } on ApiException catch (e) {
      error = e.message;
      _publish();
    } finally {
      isLoadingMore = false;
      _publish();
    }
  }

  /// Replaces the whole page, used after a mutation that changes ordering.
  Future<void> reload() => loadInitial();

  void replaceWhere(bool Function(T) test, T replacement) {
    state = PaginatedList<T>(
      items: state.items
          .map((T e) => test(e) ? replacement : e)
          .toList(growable: false),
      meta: state.meta,
    );
  }

  void removeWhere(bool Function(T) test) {
    state = PaginatedList<T>(
      items: state.items.where((T e) => !test(e)).toList(growable: false),
      meta: state.meta,
    );
  }
}
