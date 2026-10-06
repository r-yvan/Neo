import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/neo_widgets.dart';
import '../../data/models/models.dart';
import '../../data/providers.dart';
import '../../data/repositories/booking_repository.dart';
import '../../data/repositories/social_repository.dart';
import '../booking/booking_flow_page.dart';
import '../chat/chat_page.dart';
import '../profile/public_profile_page.dart';
import '../reviews/reviews_page.dart';
import '../reviews/write_review_sheet.dart';
import 'widgets/equipment_card.dart';

/// Single listing view: carousel, availability calendar, price breakdown and
/// the primary call-to-action pinned to the bottom.
class EquipmentDetailPage extends ConsumerStatefulWidget {
  const EquipmentDetailPage({super.key, required this.equipmentId});

  final String equipmentId;

  @override
  ConsumerState<EquipmentDetailPage> createState() => _EquipmentDetailPageState();
}

class _EquipmentDetailPageState extends ConsumerState<EquipmentDetailPage> {
  Equipment? _item;
  String? _error;
  bool _loading = true;
  bool _favorite = false;
  bool _busy = false;

  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  DateTime _focusedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_load);
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final Equipment item =
          await ref.read(equipmentRepositoryProvider).byId(widget.equipmentId);
      final List<FavoriteEntry> saved =
          await ref.read(favoritesRepositoryProvider).list(limit: 100);
      if (!mounted) return;
      setState(() {
        _item = item;
        _favorite = saved.items.any((FavoriteEntry f) => f.equipment.id == item.id);
        _error = null;
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

  Future<void> _toggleFavorite() async {
    final Equipment? item = _item;
    if (item == null) return;
    final bool next = !_favorite;
    setState(() => _favorite = next);
    try {
      final FavoritesRepository repo = ref.read(favoritesRepositoryProvider);
      if (next) {
        await repo.add(item.id);
      } else {
        await repo.remove(item.id);
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _favorite = !next);
        showNeoSnack(context, e.message, isError: true);
      }
    }
  }

  Future<void> _book() async {
    final Equipment? item = _item;
    if (item == null) return;
    final DateTime start = _rangeStart ?? DateTime.now().add(const Duration(days: 1));
    final DateTime end = _rangeEnd ?? start;

    final bool? created = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (BuildContext _) => BookingFlowPage(
          equipment: item,
          initialStart: start,
          initialEnd: end,
        ),
      ),
    );
    if (created == true) _load();
  }

  Future<void> _contactOwner() async {
    final Equipment? item = _item;
    final UserRef? owner = item?.owner;
    if (item == null || owner == null) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (BuildContext _) => ChatPage(peer: owner, bookingId: null),
      ),
    );
  }

  Future<void> _report() async {
    final Equipment? item = _item;
    if (item == null) return;
    await showNeoSheet<void>(
      context,
      scrollable: true,
      child: _ReportSheet(targetType: 'EQUIPMENT', targetId: item.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    if (_loading) {
      return const Scaffold(body: NeoLoading(label: 'Loading listing…'));
    }
    if (_error != null || _item == null) {
      return Scaffold(
        appBar: AppBar(leading: const BackButton()),
        body: NeoErrorState(message: _error ?? 'Not found', onRetry: _load),
      );
    }

    final Equipment item = _item!;
    final bool isMine = ref.watch(sessionProvider).user?.id == item.ownerId;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: theme.scaffoldBackgroundColor,
            surfaceTintColor: Colors.transparent,
            leading: Padding(
              padding: const EdgeInsets.all(6),
              child: Material(
                color: Colors.black.withValues(alpha: 0.35),
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(6),
                child: Material(
                  color: Colors.black.withValues(alpha: 0.35),
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: _report,
                    child: const Icon(Icons.flag_outlined, color: Colors.white, size: 20),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(6),
                child: Material(
                  color: Colors.black.withValues(alpha: 0.35),
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: _toggleFavorite,
                    child: Icon(
                      _favorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: _favorite ? AppColors.danger : Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  ImageCarousel(
                    images: item.images,
                    height: 300,
                    categoryLabel: item.category.label,
                    badge: item.boostIsActive
                        ? const NeoBadge(
                            label: 'Boosted',
                            tone: BadgeTone.accent,
                            icon: Icons.bolt_rounded,
                          )
                        : null,
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(item.title, style: theme.textTheme.headlineLarge),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      if (item.boostIsActive)
                        const NeoBadge(
                          label: 'Boosted',
                          tone: BadgeTone.accent,
                          icon: Icons.bolt_rounded,
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Icon(Icons.place_outlined,
                          size: 15, color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(item.location, style: theme.textTheme.bodyMedium),
                      ),
                      RatingRow(rating: item.averageRating, reviewCount: item.totalReviews),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: StatTile(
                          label: 'Per day',
                          value: Money.format(item.pricePerDay),
                          icon: Icons.sell_outlined,
                          tone: AppColors.accent,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: StatTile(
                          label: 'Available',
                          value: '${item.quantity}',
                          icon: Icons.inventory_2_outlined,
                          caption: item.isAvailable ? 'Ready to rent' : 'Paused',
                          tone: item.isAvailable
                              ? AppColors.success
                              : AppColors.grey500,
                        ),
                      ),
                    ],
                  ),
                  if (item.hasDeposit) ...[
                    const SizedBox(height: AppSpacing.sm),
                    NeoCard(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          const Icon(Icons.shield_outlined,
                              size: 18, color: AppColors.warning),
                          const SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: Text(
                              'A refundable deposit of ${Money.format(item.depositAmount!)} is recorded with the booking.',
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (item.description != null && item.description!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.lg),
                    Text('About this equipment', style: theme.textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.xs),
                    Text(item.description!, style: theme.textTheme.bodyLarge),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  if (item.owner != null) _ownerCard(item.owner!),
                  const SizedBox(height: AppSpacing.lg),
                  Text('Availability', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(
                    'Pick your rental dates. Blocked days cannot be booked.',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _calendar(item),
                  const SizedBox(height: AppSpacing.lg),
                  _pricePreview(item),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _bottomBar(context, item, isMine),
    );
  }

  Widget _ownerCard(UserRef owner) {
    final ThemeData theme = Theme.of(context);
    return NeoCard(
      onTap: () => Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (BuildContext _) => PublicProfilePage(userId: owner.id),
        ),
      ),
      child: Row(
        children: [
          NeoAvatar(initials: owner.initials, imageUrl: owner.profileImage, size: 48),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(owner.fullName, style: theme.textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(
                  owner.totalReviews > 0
                      ? '${owner.averageRating.toStringAsFixed(1)} · ${owner.totalReviews} reviews'
                      : 'New owner',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, size: 20),
        ],
      ),
    );
  }

  Widget _calendar(Equipment item) {
    final Set<DateTime> blocked = item.blockedDates;
    final Set<DateTime> today = <DateTime>{
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
    };

    return NeoCard(
      padding: const EdgeInsets.fromLTRB(6, 6, 6, 10),
      child: TableCalendar<Object>(
        firstDay: DateTime.now(),
        lastDay: DateTime.now().add(const Duration(days: 365)),
        focusedDay: _focusedMonth,
        rowHeight: 44,
        daysOfWeekHeight: 30,
        selectedDayPredicate: (DateTime day) =>
            _rangeStart != null && Dates.isSameDay(day, _rangeStart!),
        rangeStartDay: _rangeStart,
        rangeEndDay: _rangeEnd,
        startingDayOfWeek: StartingDayOfWeek.monday,
        availableCalendarFormats: const <CalendarFormat>[],
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          rangeHighlightColor: AppColors.accent,
          todayDecoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.14),
            shape: BoxShape.circle,
          ),
          todayTextStyle: const TextStyle(
            fontFamily: kFontFamily,
            color: AppColors.accent,
            fontWeight: AppFontWeight.semiBold,
          ),
          defaultTextStyle: TextStyle(
            fontFamily: kFontFamily,
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: AppFontWeight.medium,
          ),
          weekendTextStyle: TextStyle(
            fontFamily: kFontFamily,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: AppFontWeight.medium,
          ),
          disabledTextStyle: TextStyle(
            fontFamily: kFontFamily,
            color: AppColors.grey300,
            decoration: TextDecoration.lineThrough,
            decorationColor: AppColors.grey300,
          ),
        ),
        headerStyle: const HeaderStyle(
          titleCentered: true,
          formatButtonVisible: false,
          leftChevronIcon: Icon(Icons.chevron_left_rounded, size: 20),
          rightChevronIcon: Icon(Icons.chevron_right_rounded, size: 20),
          titleTextStyle: TextStyle(
            fontFamily: kFontFamily,
            fontSize: 15,
            fontWeight: AppFontWeight.semiBold,
          ),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            fontFamily: kFontFamily,
            fontSize: 11,
            fontWeight: AppFontWeight.semiBold,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          weekendStyle: TextStyle(
            fontFamily: kFontFamily,
            fontSize: 11,
            fontWeight: AppFontWeight.semiBold,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        onDaySelected: (DateTime selected, DateTime focused) {
          setState(() {
            _focusedMonth = focused;
            _updateRange(selected, blocked);
          });
        },
      ),
    );
  }

  void _updateRange(DateTime selected, Set<DateTime> blocked) {
    if (blocked.any((DateTime d) => Dates.isSameDay(d, selected))) {
      showNeoSnack(context, 'That day is not available',
          isError: true, icon: Icons.event_busy_rounded);
      return;
    }
    if (_rangeStart == null || _rangeEnd != null) {
      _rangeStart = selected;
      _rangeEnd = null;
      return;
    }
    if (selected.isBefore(_rangeStart!)) {
      _rangeStart = selected;
      _rangeEnd = null;
      return;
    }
    // Reject ranges that cross a blocked day.
    final List<DateTime> span = Dates.rangeInclusive(_rangeStart!, selected);
    if (span.any((DateTime d) => blocked.any((DateTime b) => Dates.isSameDay(b, d)))) {
      showNeoSnack(context, 'Your range includes an unavailable day',
          isError: true, icon: Icons.event_busy_rounded);
      _rangeStart = null;
      _rangeEnd = null;
      return;
    }
    _rangeEnd = selected;
  }

  Widget _pricePreview(Equipment item) {
    final DateTime? start = _rangeStart;
    final DateTime? end = _rangeEnd;
    if (start == null || end == null) {
      return NeoCard(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.touch_app_outlined,
                size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                'Select your dates on the calendar to see the total.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      );
    }

    final ({double total, double commission, double deposit}) preview =
        BookingRepository.preview(
      pricePerDay: item.pricePerDay,
      depositAmount: item.depositAmount,
      startDate: start,
      endDate: end,
      quantity: 1,
    );
    final int days = BookingRepository.rentalDays(start, end);

    return NeoCard(
      border: true,
      child: Column(
        children: [
          DetailRow(label: '${Money.format(item.pricePerDay)} × $days day${days == 1 ? '' : 's'}', value: Money.format(preview.total)),
          DetailRow(
            label: 'Platform fee (10%)',
            value: Money.format(preview.commission),
            valueColour: AppColors.accent,
          ),
          const Divider(height: AppSpacing.md),
          DetailRow(
            label: 'Total payable',
            value: Money.format(preview.total),
            emphasis: true,
          ),
        ],
      ),
    );
  }

  Widget _bottomBar(BuildContext context, Equipment item, bool isMine) {
    final ThemeData theme = Theme.of(context);
    final DateTime start = _rangeStart ?? DateTime.now().add(const Duration(days: 1));
    final DateTime end = _rangeEnd ?? start;
    final ({double total, double commission, double deposit}) preview =
        BookingRepository.preview(
      pricePerDay: item.pricePerDay,
      depositAmount: item.depositAmount,
      startDate: start,
      endDate: end,
      quantity: 1,
    );

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        MediaQuery.of(context).padding.bottom + AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(top: BorderSide(color: theme.colorScheme.outline)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _rangeEnd == null ? 'Total for 1 day' : 'Total',
                  style: theme.textTheme.bodySmall,
                ),
                Text(
                  Money.format(preview.total),
                  style: theme.textTheme.numeric,
                ),
              ],
            ),
          ),
          if (isMine)
            NeoButton(
              label: 'Edit listing',
              variant: NeoButtonVariant.secondary,
              expand: false,
              onPressed: () => Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (BuildContext _) => EquipmentFormPage(existing: item),
                ),
              ),
            )
          else ...[
            NeoIconButton(
              icon: Icons.chat_bubble_outline_rounded,
              tooltip: 'Message owner',
              onPressed: _busy ? null : _contactOwner,
              filled: true,
            ),
            const SizedBox(width: AppSpacing.xs),
            NeoButton(
              label: item.isAvailable ? 'Request to book' : 'Unavailable',
              expand: false,
              loading: _busy,
              onPressed:
                  item.isAvailable ? () async { setState(() => _busy = true); await _book(); setState(() => _busy = false); } : null,
            ),
          ],
        ],
      ),
    );
  }
}

/// Report a listing to the moderation queue.
class _ReportSheet extends ConsumerStatefulWidget {
  const _ReportSheet({required this.targetType, required this.targetId});

  final String targetType;
  final String targetId;

  @override
  ConsumerState<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends ConsumerState<_ReportSheet> {
  static const List<String> _reasons = <String>[
    'Misleading photos',
    'Price looks wrong',
    'Item was not as described',
    'Owner is unresponsive',
    'Duplicate listing',
    'Something else',
  ];

  String _reason = _reasons.first;
  final TextEditingController _details = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _details.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _busy = true);
    try {
      await ref.read(trustRepositoryProvider).report(
            targetType: widget.targetType,
            targetId: widget.targetId,
            reason: _reason,
            details: _details.text.trim(),
          );
      if (mounted) {
        Navigator.of(context).pop();
        showNeoSnack(context, 'Report sent. Our team will review it.',
            icon: Icons.flag_rounded);
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        showNeoSnack(context, e.message, isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Report this listing', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Reports are reviewed by the Neo team. Serious issues may lead to a listing being removed.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          ..._reasons.map((String reason) => NeoChip(
                label: reason,
                selected: _reason == reason,
                onTap: () => setState(() => _reason = reason),
              )),
          const SizedBox(height: AppSpacing.md),
          NeoField(
            label: 'Anything else we should know? (optional)',
            controller: _details,
            maxLines: 3,
          ),
          const SizedBox(height: AppSpacing.lg),
          NeoButton(
            label: 'Submit report',
            loading: _busy,
            variant: NeoButtonVariant.secondary,
            onPressed: _busy ? null : _submit,
          ),
        ],
      ),
    );
  }
}