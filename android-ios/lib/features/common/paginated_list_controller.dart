import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/utils/parsing.dart';
import '../../../data/repositories/equipment_repository.dart';
import '../../../data/repositories/users_repository.dart';

/// A page-backed list with explicit loading / error / end-of-data states.
///
/// Kept as a plain [Notifier] (no codegen) so the whole lifecycle is readable
/// in one file.
class PaginatedListController<T> extends Notifier<PaginatedList<T>> {
  PaginatedListController(this._fetch, {this.pageSize = 20, this.autoLoad = true});

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
    return const PaginatedList<T>(items: <Never>[], meta: <String, dynamic>{});
  }

  List<T> get items => state.items;
  bool get isEmpty => state.items.isEmpty;
  bool get hasMore => state.hasMore;

  Future<void> loadInitial() async {
    error = null;
    try {
      state = await _fetch(1, pageSize);
      initialised = true;
    } on ApiException catch (e) {
      error = e.message;
      initialised = true;
    }
  }

  Future<void> refresh() async {
    isRefreshing = true;
    try {
      state = await _fetch(1, pageSize);
      error = null;
    } on ApiException catch (e) {
      error = e.message;
    } finally {
      isRefreshing = false;
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore || !state.hasMore || error != null) return;
    isLoadingMore = true;
    final int next = state.page + 1;
    try {
      state = state.merge(await _fetch(next, pageSize));
    } on ApiException catch (e) {
      error = e.message;
    } finally {
      isLoadingMore = false;
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
      items:
          state.items.where((T e) => !test(e)).toList(growable: false),
      meta: state.meta,
    );
  }
}