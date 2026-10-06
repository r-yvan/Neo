/// Pagination envelope returned by every list endpoint:
/// `{ "data": [...], "meta": { total, page, limit, totalPages } }`.
library;

import '../core/utils/parsing.dart';

class PageMeta {
  const PageMeta({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory PageMeta.fromJson(Map<String, dynamic> json) => PageMeta(
        total: asInt(json['total']),
        page: asInt(json['page'], 1),
        limit: asInt(json['limit'], 20),
        totalPages: asInt(json['totalPages'], 1),
      );

  const PageMeta.empty()
      : total = 0,
        page = 1,
        limit = 20,
        totalPages = 1;

  final int total;
  final int page;
  final int limit;
  final int totalPages;

  bool get hasMore => page < totalPages;
  bool get isEmpty => total == 0;

  PageMeta nextPage() => PageMeta(
        total: total,
        page: page + 1,
        limit: limit,
        totalPages: totalPages,
      );
}

class Paginated<T> {
  const Paginated({required this.items, required this.meta});

  factory Paginated.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) parse,
  ) =>
      Paginated<T>(
        items: asMapList(json['data']).map(parse).toList(),
        meta: json['meta'] == null
            ? const PageMeta.empty()
            : PageMeta.fromJson(asMap(json['meta'])),
      );

  /// Wraps a plain array response (chat conversations, booking timeline).
  factory Paginated.fromList(List<dynamic> raw, T Function(Map<String, dynamic>) parse) =>
      Paginated<T>(
        items: asMapList(raw).map(parse).toList(),
        meta: const PageMeta.empty(),
      );

  final List<T> items;
  final PageMeta meta;

  int get length => items.length;
  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;
  bool get hasMore => meta.hasMore;

  Paginated<T> merge(Paginated<T> next) => Paginated<T>(
        items: <T>[...items, ...next.items],
        meta: next.meta,
      );

  /// Raw shape, used for the on-disk offline cache.
  Map<String, dynamic> toRawJson(T Function(T item) encode) => {
        'data': items.map(encode).toList(),
        'meta': {
          'total': meta.total,
          'page': meta.page,
          'limit': meta.limit,
          'totalPages': meta.totalPages,
        },
      };
}