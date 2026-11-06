import 'package:flutter/material.dart';

import '../../core/l10n/strings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/neo_widgets.dart';
import '../../data/models/models.dart';
import '../../data/providers.dart';
import '../../data/repositories/booking_repository.dart';
import '../../data/repositories/users_repository.dart';
import 'booking_detail_page.dart';
import '../shell/root_shell.dart';

/// Bookings tab. A single list covers both sides of the marketplace, split by
/// role so a user who is both renter and owner sees the right counts.
class MyBookingsPage extends ConsumerStatefulWidget {
  const MyBookingsPage({super.key});

  @override
  ConsumerState<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends ConsumerState<MyBookingsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 2, vsync: this);

  BookingRole _role = BookingRole.renter;
  BookingStatus? _status;
  final Map<BookingRole, PaginatedList<Booking>> _pages =
      <BookingRole, PaginatedList<Booking>>{
    BookingRole.renter: const PaginatedList<Booking>(
      items: <Booking>[],
      meta: <String, dynamic>{},
    ),
    BookingRole.owner: const PaginatedList<Booking>(
      items: <Booking>[],
      meta: <String, dynamic>{},
    ),
  };
  final Set<String> _loading = <String>{};
  final Map<String, String?> _errors = <String, String?>{};
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_maybeLoadMore);
    Future<void>.microtask(_load);
  }

  @override
  void dispose() {
    _tabs.dispose();
    _scroll.dispose();
    super.dispose();
  }

  String get _key => '${_role.wire}:${_status?.wire ?? 'all'}';

  bool get _initialLoaded => _pages[_role]!.items.isNotEmpty;

  Future<void> _load({bool append = false}) async {
    // Capture the request's role/status so a slow response can never land
    // in a list the user has since switched away from.
    final String key = _key;
    final BookingRole role = _role;
    final BookingStatus? status = _status;
    final int nextPage = append ? _pages[role]!.page + 1 : 1;
    setState(() {
      _loading.add(key);
      if (!append) _errors[key] = null;
    });
    try {
      final PaginatedList<Booking> page =
          await ref.read(bookingRepositoryProvider).mine(
                role: role,
                status: status,
                page: nextPage,
                limit: 20,
              );
      if (!mounted || key != _key) return;
      setState(() {
        _pages[role] = append
            ? PaginatedList<Booking>(
                items: <Booking>[..._pages[role]!.items, ...page.items],
                meta: page.meta,
              )
            : page;
        _errors[key] = null;
      });
    } on ApiException catch (e) {
      if (mounted) setState(() => _errors[key] = e.message);
    } finally {
      if (mounted) setState(() => _loading.remove(key));
    }
  }

  void _maybeLoadMore() {
    if (!_scroll.hasClients || _loading.contains(_key)) return;
    final double remaining =
        _scroll.position.maxScrollExtent - _scroll.position.pixels;
    final PaginatedList<Booking> page = _pages[_role]!;
    if (remaining < 500 && page.hasMore) _load(append: true);
  }

  Future<void> _refresh() => _load();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final PaginatedList<Booking> page = _pages[_role]!;
    final String key = _key;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.accent,
          onRefresh: _refresh,
          child: CustomScrollView(
            controller: _scroll,
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.sm,
                    AppSpacing.lg,
                    0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(L10n.i.bkTitle, style: theme.textTheme.displayMedium),
                      const SizedBox(height: AppSpacing.md),
                      SegmentedButton<BookingRole>(
                        segments: <ButtonSegment<BookingRole>>[
                          ButtonSegment<BookingRole>(
                            value: BookingRole.renter,
                            label: Text(L10n.i.bkTabRenting),
                            icon: const Icon(Icons.shopping_bag_outlined, size: 16),
                          ),
                          ButtonSegment<BookingRole>(
                            value: BookingRole.owner,
                            label: Text(L10n.i.bkTabMine),
                            icon: const Icon(Icons.storefront_outlined, size: 16),
                          ),
                        ],
                        selected: <BookingRole>{_role},
                        onSelectionChanged: (Set<BookingRole> value) {
                          setState(() => _role = value.first);
                          _load();
                        },
                        showSelectedIcon: false,
                        style: SegmentedButton.styleFrom(
                          selectedBackgroundColor: AppColors.accentSoft,
                          selectedForegroundColor: AppColors.accent,
                          backgroundColor: theme.colorScheme.surface,
                          side: BorderSide(color: theme.colorScheme.outline),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      SizedBox(
                        height: 34,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: <Widget>[
                            NeoChip(
                              label: L10n.i.bkChipAll,
                              dense: true,
                              selected: _status == null,
                              onTap: () => setState(() {
                                _status = null;
                                _load();
                              }),
                            ),
                            const SizedBox(width: 6),
                            ...BookingStatus.values.map((BookingStatus s) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: NeoChip(
                                  label: s.label,
                                  dense: true,
                                  selected: _status == s,
                                  onTap: () => setState(() {
                                    _status = s;
                                    _load();
                                  }),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ..._body(page, key),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _body(PaginatedList<Booking> page, String key) {
    if (_loading.contains(key) && !_initialLoaded) {
      return <Widget>[
        SliverPadding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          sliver: SliverList(
            delegate: SliverChildListDelegate(
              List<Widget>.generate(
                  4, (int i) => const SkeletonCard(height: 110)),
            ),
          ),
        ),
      ];
    }

    final String? error = _errors[key];
    if (error != null && page.items.isEmpty) {
      return <Widget>[
        SliverFillRemaining(
          hasScrollBody: false,
          child: NeoErrorState(message: error, onRetry: _refresh),
        ),
      ];
    }

    if (page.items.isEmpty) {
      return <Widget>[
        SliverFillRemaining(
          hasScrollBody: false,
          child: NeoEmptyState(
            icon: _role == BookingRole.renter
                ? Icons.receipt_long_outlined
                : Icons.storefront_outlined,
            title: _role == BookingRole.renter
                ? L10n.i.bkEmptyMine
                : L10n.i.bkEmptyOwned,
            message: _role == BookingRole.renter
                ? L10n.i.bkEmptyMineBody
                : L10n.i.bkEmptyOwnedBody,
            actionLabel:
                _role == BookingRole.renter ? L10n.i.bkBrowseCta : null,
            onAction: () => openShellTab(context, ShellTab.explore),
          ),
        ),
      ];
    }

    return <Widget>[
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          0,
        ),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) => _BookingCard(
              booking: page.items[index],
              onChanged: _refresh,
            ),
            childCount: page.items.length,
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: ListFooterLoader(
          loading: _loading.contains(key),
          endLabel: page.hasMore ? null : L10n.i.bkEndList,
        ),
      ),
    ];
  }
}

class _BookingCard extends ConsumerWidget {
  const _BookingCard({required this.booking, required this.onChanged});

  final Booking booking;
  final Future<void> Function() onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final String me = ref.watch(sessionProvider).user?.id ?? '';
    final bool asOwner = booking.isOwner(me);
    final UserRef? counterparty = asOwner ? booking.renter : booking.owner;
    final Equipment? equipment = booking.equipment;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: NeoCard(
        onTap: () async {
          await Navigator.of(context).push<void>(
            MaterialPageRoute<void>(
              builder: (BuildContext _) =>
                  BookingDetailPage(bookingId: booking.id),
            ),
          );
          onChanged();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                EquipmentImage(
                  source: equipment == null || equipment.images.isEmpty
                      ? ''
                      : equipment.images.first,
                  width: 58,
                  height: 58,
                  radius: AppRadii.md,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        equipment?.title ?? L10n.i.bkFallbackTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        Dates.range(booking.startDate, booking.endDate),
                        style: theme.textTheme.bodySmall,
                      ),
                      Text(
                        '${L10n.i.flowUnitCount(booking.quantity)} · '
                        '${asOwner ? L10n.i.roleRenter : (counterparty?.fullName ?? L10n.i.roleOwner)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    BookingStatusBadge(status: booking.status),
                    const SizedBox(height: 6),
                    Text(
                      Money.format(booking.totalPrice),
                      style: theme.textTheme.titleSmall,
                    ),
                  ],
                ),
              ],
            ),
            if (booking.paymentStatus == PaymentStatus.paid ||
                booking.paymentStatus == PaymentStatus.pending) ...[
              const Divider(height: AppSpacing.md),
              Row(
                children: [
                  Icon(
                    booking.paymentStatus == PaymentStatus.paid
                        ? Icons.check_circle_outline_rounded
                        : Icons.receipt_outlined,
                    size: 15,
                    color: booking.paymentStatus == PaymentStatus.paid
                        ? AppColors.success
                        : AppColors.grey400,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    booking.paymentStatus == PaymentStatus.paid
                        ? L10n.i.bkPaidInfo(Money.format(booking.ownerPayout))
                        : L10n.i.bkPaymentPending,
                    style: theme.textTheme.bodySmall,
                  ),
                  const Spacer(),
                  if (asOwner && booking.status == BookingStatus.pending) ...[
                    TextButton(
                      onPressed: () => _transition(context, ref, 'reject'),
                      child: Text(L10n.i.bkDecline),
                    ),
                    TextButton(
                      onPressed: () => _transition(context, ref, 'accept'),
                      child: Text(L10n.i.bkAccept),
                    ),
                  ] else if (!asOwner &&
                      booking.status == BookingStatus.accepted &&
                      booking.paymentStatus == PaymentStatus.pending) ...[
                    TextButton(
                      onPressed: () {
                        openShellTab(context, 0);
                        Navigator.of(context).pop();
                      },
                      child: Text(L10n.i.bkPayNow),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _transition(
    BuildContext context,
    WidgetRef ref,
    String action,
  ) async {
    final BookingRepository repo = ref.read(bookingRepositoryProvider);
    try {
      final Booking updated = switch (action) {
        'accept' => await repo.accept(booking.id),
        'reject' => await repo.reject(booking.id),
        'start' => await repo.start(booking.id),
        _ => await repo.complete(booking.id),
      };
      onChanged();
      if (context.mounted) {
        showNeoSnack(
          context,
          L10n.i.bdSnack(updated.status.label),
          icon: Icons.check_circle_outline_rounded,
        );
      }
    } on ApiException catch (e) {
      if (context.mounted) showNeoSnack(context, e.message, isError: true);
    }
  }
}

/// Status pill used across booking surfaces.
class BookingStatusBadge extends StatelessWidget {
  const BookingStatusBadge({super.key, required this.status});

  final BookingStatus status;

  @override
  Widget build(BuildContext context) {
    final (BadgeTone tone, IconData icon) = switch (status) {
      BookingStatus.pending => (BadgeTone.warning, Icons.hourglass_top_rounded),
      BookingStatus.accepted => (
          BadgeTone.accent,
          Icons.event_available_rounded
        ),
      BookingStatus.ongoing => (BadgeTone.accent, Icons.local_shipping_rounded),
      BookingStatus.completed => (BadgeTone.success, Icons.done_all_rounded),
      BookingStatus.rejected => (BadgeTone.danger, Icons.block_rounded),
      BookingStatus.cancelled => (BadgeTone.neutral, Icons.cancel_outlined),
      BookingStatus.disputed => (
          BadgeTone.danger,
          Icons.report_problem_outlined
        ),
    };
    return NeoBadge(label: status.label, tone: tone, icon: icon);
  }
}
