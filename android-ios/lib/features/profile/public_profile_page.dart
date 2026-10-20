import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/neo_widgets.dart';
import '../../data/models/models.dart';
import '../../data/providers.dart';
import '../../data/repositories/users_repository.dart';
import '../chat/chat_page.dart';
import '../equipment/equipment_detail_page.dart';

/// Another member's public face: avatar, rating, recent reviews and their
/// live listings. Purely read-only; opened by tapping a name or avatar.
class PublicProfilePage extends ConsumerStatefulWidget {
  const PublicProfilePage({super.key, required this.userId});

  final String userId;

  @override
  ConsumerState<PublicProfilePage> createState() => _PublicProfilePageState();
}

class _PublicProfilePageState extends ConsumerState<PublicProfilePage> {
  PublicProfile? _profile;
  List<Review> _reviews = const <Review>[];
  List<Equipment> _listings = const <Equipment>[];
  bool _loading = true;
  String? _error;
  int _reviewPage = 1;
  bool _reviewLoadingMore = false;

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
      final repo = ref.read(usersRepositoryProvider);
      final results = await Future.wait(<Future<dynamic>>[
        repo.profile(widget.userId),
        repo.reviews(widget.userId, page: 1, limit: 10),
        repo.equipment(widget.userId, limit: 20),
      ]);
      if (!mounted) return;
      setState(() {
        _profile = results[0] as PublicProfile;
        _reviews = (results[1] as PaginatedList<Review>).items;
        _listings = (results[2] as List<Equipment>).toList();
        _reviewPage = 1;
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

  Future<void> _loadMoreReviews() async {
    if (_reviewLoadingMore) return;
    setState(() => _reviewLoadingMore = true);
    try {
      final PaginatedList<Review> next = await ref
          .read(usersRepositoryProvider)
          .reviews(widget.userId, page: _reviewPage + 1, limit: 10);
      if (!mounted) return;
      setState(() {
        _reviewPage += 1;
        _reviews = <Review>[..._reviews, ...next.items];
        _reviewLoadingMore = false;
      });
    } on ApiException catch (_) {
      if (mounted) setState(() => _reviewLoadingMore = false);
    }
  }

  void _openChat() {
    final PublicProfile? profile = _profile;
    if (profile == null) return;
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (BuildContext _) => ChatPage(
          peer: UserRef(
            id: profile.id,
            fullName: profile.fullName,
            profileImage: profile.profileImage,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final Widget body;
    if (_loading && _profile == null) {
      body = const Center(child: NeoLoading());
    } else if (_error != null) {
      body = ListView(
        children: <Widget>[
          const SizedBox(height: 80),
          NeoErrorState(message: _error!, onRetry: _load),
        ],
      );
    } else {
      body = RefreshIndicator(
        color: AppColors.accent,
        onRefresh: _load,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: <Widget>[
            SliverToBoxAdapter(child: _header(context)),
            _listingsSection(context),
            _reviewsSection(context),
            const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.xxl),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(_profile?.fullName ?? 'Profile'),
        actions: !_loading
            ? <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: NeoIconButton(
                    icon: Icons.chat_bubble_outline_rounded,
                    tooltip: 'Message',
                    onPressed: _openChat,
                  ),
                ),
              ]
            : const <Widget>[],
      ),
      body: body,
    );
  }

  Widget _header(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final PublicProfile profile = _profile!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        0,
      ),
      child: Column(
        children: <Widget>[
          NeoAvatar(
            initials: profile.initials,
            imageUrl: profile.profileImage,
            size: 84,
            ring: true,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            profile.fullName,
            style: theme.textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RatingRow(
                rating: profile.averageRating,
                reviewCount: profile.totalReviews,
              ),
              const SizedBox(width: AppSpacing.sm),
              for (final UserRole role in profile.roles)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: NeoBadge(label: role.label, tone: BadgeTone.neutral),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            profile.createdAt != null
                ? 'Member since ${Dates.short(profile.createdAt!)}'
                : '',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _listingsSection(BuildContext context) {
    if (_listings.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
    final ThemeData theme = Theme.of(context);

    return SliverMainAxisGroup(
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: SectionHeader(
                title: 'Listings',
                subtitle: '${_listings.length} item${_listings.length == 1 ? '' : 's'}'),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                final Equipment item = _listings[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: NeoCard(
                    onTap: () => Navigator.of(context).push<void>(
                      MaterialPageRoute<void>(
                        builder: (BuildContext _) =>
                            EquipmentDetailPage(equipmentId: item.id),
                      ),
                    ),
                    child: Row(
                      children: <Widget>[
                        _ListingThumb(item),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                item.title,
                                style: theme.textTheme.titleSmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '${Money.format(item.pricePerDay)}/day • ${item.location}',
                                style: theme.textTheme.bodySmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        RatingRow(
                          rating: item.averageRating,
                          reviewCount: item.totalReviews,
                          showCount: false,
                          size: 12,
                        ),
                      ],
                    ),
                  ),
                );
              },
              childCount: _listings.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _reviewsSection(BuildContext context) {
    if (_reviews.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverMainAxisGroup(
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: SectionHeader(
              title: 'Reviews',
              subtitle: '${_profile!.totalReviews} total',
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) =>
                  _ReviewTile(review: _reviews[index]),
              childCount: _reviews.length,
            ),
          ),
        ),
        if (_reviews.length < _profile!.totalReviews)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Center(
                child: _reviewLoadingMore
                    ? const NeoLoading()
                    : NeoButton(
                        label: 'Show more',
                        variant: NeoButtonVariant.ghost,
                        expand: false,
                        onPressed: _loadMoreReviews,
                      ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.review});

  final Review review;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return NeoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              NeoAvatar(
                initials: review.fromUser?.initials ?? '?',
                imageUrl: review.fromUser?.profileImage,
                size: 32,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      review.fromUser?.fullName ?? 'Anonymous',
                      style: theme.textTheme.titleSmall,
                    ),
                    Text(
                      Dates.relative(review.createdAt),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              RatingRow(
                rating: review.rating.toDouble(),
                reviewCount: 0,
                showCount: false,
                size: 13,
              ),
            ],
          ),
          if (review.comment != null && review.comment!.isNotEmpty) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            Text(review.comment!, style: theme.textTheme.bodyMedium),
          ],
          if (review.equipmentTitle != null) ...<Widget>[
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Rented: ${review.equipmentTitle}',
              style: theme.textTheme.bodySmall!.copyWith(
                color: AppColors.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// thumb for a listing row above
class _ListingThumb extends StatelessWidget {
  const _ListingThumb(this.item);

  final Equipment item;

  @override
  Widget build(BuildContext context) {
    return EquipmentImage(
      source: item.images.isNotEmpty ? item.images.first : '',
      width: 56,
      height: 56,
    );
  }
}
