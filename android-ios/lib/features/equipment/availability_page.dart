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

/// Owner-side availability editor.
///
/// The API treats a missing `Availability` row as "available", so blocking is
/// additive: the owner marks the dates they cannot rent and everything else
/// stays bookable.
class AvailabilityPage extends ConsumerStatefulWidget {
  const AvailabilityPage({super.key, required this.equipment});

  final Equipment equipment;

  @override
  ConsumerState<AvailabilityPage> createState() => _AvailabilityPageState();
}

class _AvailabilityPageState extends ConsumerState<AvailabilityPage> {
  List<AvailabilityDay> _days = const <AvailabilityDay>[];
  DateTime _focusedMonth = DateTime.now();
  Set<DateTime> _selected = <DateTime>{};
  bool _loading = true;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_load);
  }

  Future<void> _load() async {
    try {
      final List<AvailabilityDay> days =
          await ref.read(equipmentRepositoryProvider).availability(widget.equipment.id);
      if (mounted) {
        setState(() {
          _days = days;
          _loading = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message;
          _loading = false;
        });
      }
    }
  }

  Set<DateTime> get _blocked => _days
      .where((AvailabilityDay d) => !d.isAvailable)
      .map((AvailabilityDay d) => Dates.dayOnly(d.date))
      .toSet();

  Future<void> _blockSelected() async {
    if (_selected.isEmpty) return;
    setState(() => _busy = true);
    try {
      final List<AvailabilityDay> updated = await ref
          .read(equipmentRepositoryProvider)
          .blockDates(widget.equipment.id, _selected.toList());
      if (!mounted) return;
      setState(() {
        _days = updated;
        _selected = <DateTime>{};
        _busy = false;
      });
      showNeoSnack(context, 'Dates blocked', icon: Icons.event_busy_rounded);
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        showNeoSnack(context, e.message, isError: true);
      }
    }
  }

  Future<void> _unblock(DateTime date) async {
    setState(() => _busy = true);
    try {
      await ref.read(equipmentRepositoryProvider).clearDate(widget.equipment.id, date);
      if (mounted) {
        setState(() => _busy = false);
        await _load();
        showNeoSnack(context, 'Date is bookable again',
            icon: Icons.event_available_rounded);
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
    final ThemeData theme = Theme.of(context);
    final bool isPaused = !widget.equipment.isAvailable;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text('Availability', style: theme.textTheme.titleLarge),
      ),
      body: _loading
          ? const NeoLoading()
          : SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  Text(widget.equipment.title, style: theme.textTheme.headlineMedium),
                  const SizedBox(height: 2),
                  Text(
                    '${widget.equipment.quantity} units · ${widget.equipment.location}',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  NeoCard(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Accepting bookings', style: theme.textTheme.titleSmall),
                              const SizedBox(height: 2),
                              Text(
                                isPaused
                                    ? 'Paused — your listing is hidden from search'
                                    : 'Live — renters can request this item',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: !isPaused,
                          onChanged: (bool value) async {
                            try {
                              await ref
                                  .read(equipmentRepositoryProvider)
                                  .setAvailability(
                                    widget.equipment.id,
                                    isAvailable: value,
                                  );
                              if (mounted) {
                                showNeoSnack(
                                  context,
                                  value ? 'Your listing is live' : 'Listings paused',
                                );
                              }
                            } on ApiException catch (e) {
                              if (mounted) {
                                showNeoSnack(context, e.message, isError: true);
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text('Tap dates to block them', style: theme.textTheme.titleSmall),
                  const SizedBox(height: AppSpacing.xs),
                  NeoCard(
                    padding: const EdgeInsets.fromLTRB(6, 6, 6, 10),
                    child: TableCalendar<Object>(
                      firstDay: DateTime.now(),
                      lastDay: DateTime.now().add(const Duration(days: 365)),
                      focusedDay: _focusedMonth,
                      rowHeight: 44,
                      daysOfWeekHeight: 30,
                      startingDayOfWeek: StartingDayOfWeek.monday,
                      availableCalendarFormats: const <CalendarFormat>[],
                      eventLoader: (DateTime day) =>
                          _blocked.contains(Dates.dayOnly(day)) ||
                                  _selected.contains(Dates.dayOnly(day))
                              ? const <Object>[]
                              : const <Object>[],
                      selectedDayPredicate: (DateTime day) =>
                          _selected.contains(Dates.dayOnly(day)),
                      calendarStyle: CalendarStyle(
                        outsideDaysVisible: false,
                        selectedDecoration: const BoxDecoration(
                          color: AppColors.danger,
                          shape: BoxShape.circle,
                        ),
                        selectedTextStyle: const TextStyle(
                          fontFamily: kFontFamily,
                          color: Colors.white,
                          fontWeight: AppFontWeight.semiBold,
                        ),
                        todayDecoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.14),
                          shape: BoxShape.circle,
                        ),
                        todayTextStyle: const TextStyle(
                          fontFamily: kFontFamily,
                          color: AppColors.accent,
                          fontWeight: AppFontWeight.semiBold,
                        ),
                        markersMaxCount: 1,
                        markerDecoration: BoxDecoration(
                          color: AppColors.danger,
                          shape: BoxShape.circle,
                        ),
                        markerSize: 6,
                        markerMargin: const EdgeInsets.symmetric(horizontal: 1),
                        defaultTextStyle: TextStyle(
                          fontFamily: kFontFamily,
                          color: theme.colorScheme.onSurface,
                          fontWeight: AppFontWeight.medium,
                        ),
                        weekendTextStyle: TextStyle(
                          fontFamily: kFontFamily,
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: AppFontWeight.medium,
                        ),
                      ),
                      headerStyle: const HeaderStyle(
                        titleCentered: true,
                        formatButtonVisible: false,
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
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        weekendStyle: TextStyle(
                          fontFamily: kFontFamily,
                          fontSize: 11,
                          fontWeight: AppFontWeight.semiBold,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      onDaySelected: (DateTime selected, DateTime focused) {
                        setState(() {
                          _focusedMonth = focused;
                          final DateTime day = Dates.dayOnly(selected);
                          if (_selected.remove(day)) return;
                          _selected.add(day);
                        });
                      },
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    NeoErrorBanner(message: _error!),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  NeoButton(
                    label: _selected.isEmpty
                        ? 'Select dates to block'
                        : 'Block ${_selected.length} date${_selected.length == 1 ? '' : 's'}',
                    variant: NeoButtonVariant.secondary,
                    loading: _busy,
                    onPressed: _selected.isEmpty || _busy ? null : _blockSelected,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text('Blocked dates', style: theme.textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.xs),
                  if (_blocked.isEmpty)
                    NeoEmptyState(
                      compact: true,
                      icon: Icons.event_available_rounded,
                      title: 'Nothing blocked',
                      message: 'Every day is bookable right now.',
                    )
                  else
                    ...(_blocked.toList()..sort()).map((DateTime day) {
                      final int active = _activeBookingsOn(day);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                        child: NeoCard(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${Dates.weekday(day)}, ${Dates.full(day)}',
                                      style: theme.textTheme.titleSmall,
                                    ),
                                    if (active > 0) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        '$active booking${active == 1 ? '' : 's'} on this date',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(color: AppColors.warning),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              TextButton(
                                onPressed: _busy ? null : () => _unblock(day),
                                child: const Text('Unblock'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
    );
  }

  /// Best-effort overlap count so the owner does not block a paid rental by
  /// accident. Silent on failure — blocking is still allowed.
  int _activeBookingsOn(DateTime day) {
    final String userId = ref.read(sessionProvider).user?.id ?? '';
    return ref
            .read(activeBookingsProvider)
            .valueOrNull
            ?.where((Booking b) {
              if (b.ownerId != userId) return false;
              if (b.status.isTerminal) return false;
              final DateTime d = Dates.dayOnly(day);
              return !d.isBefore(Dates.dayOnly(b.startDate)) &&
                  !d.isAfter(Dates.dayOnly(b.endDate));
            })
            .length ??
        0;
  }
}

/// Owner bookings in ACCEPTED / ONGOING state, used to warn before blocking.
final FutureProvider<List<Booking>> activeBookingsProvider =
    FutureProvider<List<Booking>>((Ref ref) async {
  final result = await ref.read(bookingRepositoryProvider).mine(
        role: BookingRole.owner,
        limit: 100,
      );
  return result.items;
});