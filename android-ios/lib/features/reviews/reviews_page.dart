import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/neo_widgets.dart';
import '../../data/models/models.dart';
import '../../data/providers.dart';
import '../../data/repositories/users_repository.dart' show PaginatedList;
import '../profile/public_profile_page.dart';

/// Review list. Used for a listing (`?equipmentId=`), a person (`?userId=`)
/// or the signed-in user's own reviews (`mine: true`).
class ReviewsPage extends ConsumerStatefulWidget {
  const ReviewsPage({
    super.key,
    this.equipmentId,
    this.userId,
    this.mine = false,
    this.title = 'Reviews',
  });

  final String? equipmentId;
  final String? userId;
  final bool mine;
  final String title;

  @override
  ConsumerState<ReviewsPage> createState() => _ReviewsPageState();
}

class _ReviewsPageState extends ConsumerState<ReviewsPage> {
  List<Review> _items = const <Review>[];
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

  Future<PaginatedList<Review>> _fetch(int page) async {
    final ReviewsRepository repo = ref.read(reviewsRepositoryProvider);
    if (widget.mine) return repo.given(page: page);
    if (widget.equipmentId != null) {
      return repo.forEquipment(widget.equipmentId!, page: page);
    }
    return repo.forUser(widget.userId!, page: page);
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final PaginatedList<Review> page = await _fetch(1);
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
      final PaginatedList<Review> page = await _fetch(_page + 1);
      if (!mounted) return;
      setState(() {
        _items = <Review>[..._items, ...page.items];
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

  Future<void> _delete(Review review) async {
    setState(
        () => _items = _items.where((Review r) => r.id != review.id).toList());
    try {
      await ref.read(reviewsRepositoryProvider).delete(review.id);
      if (mounted)
        showNeoSnack(context, 'Review deleted',
            icon: Icons.delete_outline_rounded);
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
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text(widget.title, style: theme.textTheme.titleLarge),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.accent,
          onRefresh: _load,
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification n) {
              if (n.metrics.pixels > n.metrics.maxScrollExtent - 400)
                _loadMore();
              return false;
            },
            child: _loading && _items.isEmpty
                ? const NeoLoading()
                : _error != null && _items.isEmpty
                    ? NeoErrorState(message: _error!, onRetry: _load)
                    : _items.isEmpty
                        ? const NeoEmptyState(
                            icon: Icons.reviews_outlined,
                            title: 'No reviews yet',
                            message:
                                'Reviews appear once a rental has been completed and rated.',
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            itemCount: _items.length,
                            itemBuilder: (BuildContext context, int index) =>
                                _ReviewCard(
                              review: _items[index],
                              onDelete: () => _delete(_items[index]),
                            ),
                          ),
          ),
        ),
      ),
      bottomNavigationBar: _loadingMore
          ? const Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.lg),
              child: ListFooterLoader(loading: true),
            )
          : null,
    );
  }
}

class _ReviewCard extends ConsumerWidget {
  const _ReviewCard({required this.review, this.onDelete});

  final Review review;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final String me = ref.watch(sessionProvider).user?.id ?? '';
    final bool mine = review.fromUser?.id == me;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: NeoCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                NeoAvatar(
                  initials: review.fromUser?.initials ?? '?',
                  imageUrl: review.fromUser?.profileImage,
                  size: 36,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.fromUser?.fullName ?? 'Renter',
                        style: theme.textTheme.titleSmall,
                      ),
                      Text(
                        Dates.relative(review.createdAt),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                if (onDelete != null && mine)
                  NeoIconButton(
                    icon: Icons.delete_outline_rounded,
                    tooltip: 'Delete review',
                    onPressed: onDelete,
                  )
                else
                  Row(
                    children: List<Widget>.generate(5, (int i) {
                      return Icon(
                        i < review.rating
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        size: 15,
                        color: i < review.rating
                            ? AppColors.star
                            : theme.colorScheme.outline,
                      );
                    }),
                  ),
              ],
            ),
            if (review.comment != null && review.comment!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(review.comment!, style: theme.textTheme.bodyMedium),
            ],
            if (review.equipmentTitle != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  Icon(Icons.inventory_2_outlined,
                      size: 13, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      review.equipmentTitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodySmall,
                    ),
                  ),
                  if (review.bookingStartDate != null &&
                      review.bookingEndDate != null)
                    Text(
                      Dates.range(
                        review.bookingStartDate!,
                        review.bookingEndDate!,
                      ),
                      style: AppTypography.labelSmall
                          ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
