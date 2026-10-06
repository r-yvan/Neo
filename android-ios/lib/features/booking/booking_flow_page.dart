import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../chat/chat_page.dart';

/// End-to-end rental flow in a single scrollable page:
///
/// 1. dates  2. quantity  3. summary  4. payment (MTN MoMo / Airtel Money)
///
/// `POST /bookings` creates the request, `POST /payments/initiate` produces the
/// reference, and `POST /payments/confirm` settles it. Payment only unlocks
/// once the owner has accepted, which is exactly how the backend is built, so
/// the pay button stays disabled until the booking status is ACCEPTED.
class BookingFlowPage extends ConsumerStatefulWidget {
  const BookingFlowPage({
    super.key,
    required this.equipment,
    required this.initialStart,
    required this.initialEnd,
  });

  final Equipment equipment;
  final DateTime initialStart;
  final DateTime initialEnd;

  @override
  ConsumerState<BookingFlowPage> createState() => _BookingFlowPageState();
}

class _BookingFlowPageState extends ConsumerState<BookingFlowPage> {
  final PageController _pages = PageController();
  final TextEditingController _notes = TextEditingController();
  final TextEditingController _phone = TextEditingController();

  late DateTime _start = Dates.dayOnly(widget.initialStart);
  late DateTime _end = Dates.dayOnly(widget.initialEnd);
  late DateTime _focusedMonth = _start;
  int _quantity = 1;
  int _step = 0;
  MobileMoneyProvider? _provider;
  bool _busy = false;
  String? _error;
  Booking? _booking;

  static const List<_FlowStep> _steps = <_FlowStep>[
    _FlowStep('Dates', 'When do you need it?'),
    _FlowStep('Quantity', 'How many units?'),
    _FlowStep('Summary', 'Check the details'),
    _FlowStep('Payment', 'Pay with mobile money'),
  ];

  @override
  void initState() {
    super.initState();
    _phone.text = _pretty(ref.read(sessionProvider).user?.phone ?? '');
    _provider = MobileMoneyProvider.forPhone(
      ref.read(sessionProvider).user?.phone ?? '',
    );
  }

  @override
  void dispose() {
    _pages.dispose();
    _notes.dispose();
    _phone.dispose();
    super.dispose();
  }

  String _pretty(String phone) =>
      phone.startsWith('250') ? '0${phone.substring(3)}' : phone;

  int get _days => BookingRepository.rentalDays(_start, _end);

  ({double total, double commission, double deposit}) get _preview =>
      BookingRepository.preview(
        pricePerDay: widget.equipment.pricePerDay,
        depositAmount: widget.equipment.depositAmount,
        startDate: _start,
        endDate: _end,
        quantity: _quantity,
      );

  void _goTo(int step) {
    setState(() => _step = step.clamp(0, _steps.length - 1));
    _pages.animateToPage(
      _step,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _createBooking() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final Booking booking =
          await ref.read(bookingRepositoryProvider).create(
                equipmentId: widget.equipment.id,
                startDate: _start,
                endDate: _end,
                quantity: _quantity,
                notes: _notes.text.trim(),
              );
      if (!mounted) return;
      setState(() {
        _booking = booking;
        _busy = false;
      });
      _goTo(2);
      showNeoSnack(
        context,
        'Request sent to ${booking.owner?.fullName ?? 'the owner'}.',
        icon: Icons.send_rounded,
      );
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message;
          _busy = false;
        });
      }
    }
  }

  Future<void> _pay(MobileMoneyProvider provider) async {
    final Booking? booking = _booking;
    if (booking == null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final PaymentIntent intent = await ref
          .read(paymentsRepositoryProvider)
          .initiate(bookingId: booking.id, provider: provider);
      // In production the provider's USSD prompt completes out-of-band; until
      // then the renter confirms the reference, which is the documented
      // placeholder flow on the backend.
      await ref.read(paymentsRepositoryProvider).confirm(intent.paymentRef);
      if (!mounted) return;
      setState(() {
        _booking = booking.copyWith(paymentStatus: PaymentStatus.paid);
        _busy = false;
      });
      showNeoSnack(context, 'Payment confirmed. The owner has been notified.',
          icon: Icons.check_circle_outline_rounded);
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message;
          _busy = false;
        });
      }
    }
  }

  Future<void> _openChat() async {
    final Booking? booking = _booking;
    final UserRef? owner = booking?.owner ?? widget.equipment.owner;
    if (owner == null) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (BuildContext _) =>
            ChatPage(peer: owner, bookingId: booking?.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppUser? me = ref.watch(sessionProvider).user;
    final bool isOwnListing = me?.id == widget.equipment.ownerId;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text('Request to book', style: theme.textTheme.titleLarge),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (_step + 1) / _steps.length,
            backgroundColor: theme.colorScheme.outline,
            minHeight: 3,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _StepBar(steps: _steps, current: _step),
            Expanded(
              child: PageView(
                controller: _pages,
                physics: const NeverScrollableScrollPhysics(),
                children: <Widget>[
                  _datesStep(context),
                  _quantityStep(context),
                  _summaryStep(context, me, isOwnListing),
                  _paymentStep(context),
                ],
              ),
            ),
            _footer(context, isOwnListing),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------------ step 1

  Widget _datesStep(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Equipment item = widget.equipment;
    final Set<DateTime> blocked = item.blockedDates;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text(_steps[_step].title, style: theme.textTheme.headlineMedium),
        const SizedBox(height: 2),
        Text(_steps[_step].subtitle, style: theme.textTheme.bodyMedium),
        const SizedBox(height: AppSpacing.md),
        NeoCard(
          padding: const EdgeInsets.fromLTRB(6, 6, 6, 10),
          child: TableCalendar<Object>(
            firstDay: DateTime.now(),
            lastDay: DateTime.now().add(const Duration(days: 180)),
            focusedDay: _focusedMonth,
            rowHeight: 44,
            daysOfWeekHeight: 30,
            rangeStartDay: _start,
            rangeEndDay: _end,
            rangeSelectionColor: AppColors.accentSoft,
            startingDayOfWeek: StartingDayOfWeek.monday,
            availableCalendarFormats: const <CalendarFormat>[],
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              rangeHighlightColor: AppColors.accent,
              rangeOverlayDecoration: BoxDecoration(
                color: AppColors.accentSoft,
                borderRadius: AppRadii.smAll,
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
              defaultTextStyle: TextStyle(
                fontFamily: kFontFamily,
                color: theme.colorScheme.onSurface,
                fontWeight: AppFontWeight.medium,
              ),
              disabledTextStyle: TextStyle(
                fontFamily: kFontFamily,
                color: AppColors.grey300,
                decoration: TextDecoration.lineThrough,
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
            onRangeSelected: (DateTime? start, DateTime? end, DateTime focused) {
              if (start == null) return;
              final DateTime resolvedEnd = end ?? start;
              final List<DateTime> span =
                  Dates.rangeInclusive(start, resolvedEnd);
              if (span.any((DateTime d) =>
                  blocked.any((DateTime b) => Dates.isSameDay(b, d)))) {
                setState(() => _error = 'That range includes an unavailable day');
                return;
              }
              setState(() {
                _start = start;
                _end = resolvedEnd;
                _focusedMonth = focused;
                _error = null;
              });
            },
          ),
        ),
        if (blocked.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              const Icon(Icons.event_busy_rounded, size: 15, color: AppColors.grey400),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${blocked.length} day${blocked.length == 1 ? '' : 's'} blocked by the owner.',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        NeoField(
          label: 'Note for the owner (optional)',
          hint: 'Event type, delivery details, pickup time…',
          controller: _notes,
          maxLines: 3,
        ),
      ],
    );
  }

  // ------------------------------------------------------------------ step 2

  Widget _quantityStep(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ({double total, double commission, double deposit}) preview = _preview;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text(_steps[_step].title, style: theme.textTheme.headlineMedium),
        const SizedBox(height: 2),
        Text(_steps[_step].subtitle, style: theme.textTheme.bodyMedium),
        const SizedBox(height: AppSpacing.xl),
        NeoCard(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text('Units needed', style: theme.textTheme.titleMedium),
                  ),
                  Row(
                    children: [
                      _StepperButton(
                        icon: Icons.remove_rounded,
                        onPressed: _quantity > 1
                            ? () => setState(() => _quantity--)
                            : null,
                      ),
                      SizedBox(
                        width: 58,
                        child: Text(
                          '$_quantity',
                          textAlign: TextAlign.center,
                          style: theme.textStyle.numeric,
                        ),
                      ),
                      _StepperButton(
                        icon: Icons.add_rounded,
                        onPressed: _quantity < widget.equipment.quantity
                            ? () => setState(() => _quantity++)
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${widget.equipment.quantity} units available from this owner',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        NeoCard(
          child: Column(
            children: [
              DetailRow(
                label: '${Money.format(widget.equipment.pricePerDay)} × $_quantity units × $_days days',
                value: Money.format(preview.total),
              ),
              const Divider(height: AppSpacing.md),
              DetailRow(
                label: 'Estimated total',
                value: Money.format(preview.total),
                emphasis: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------------ step 3

  Widget _summaryStep(BuildContext context, AppUser? me, bool isOwnListing) {
    final ThemeData theme = Theme.of(context);
    final ({double total, double commission, double deposit}) preview = _preview;
    final Booking? booking = _booking;

    if (isOwnListing) {
      return ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: const <Widget>[
          NeoEmptyState(
            icon: Icons.info_outline_rounded,
            title: 'This is your listing',
            message: 'You cannot rent your own equipment. '
                'Manage it from the My gear tab instead.',
          ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text(_steps[_step].title, style: theme.textTheme.headlineMedium),
        const SizedBox(height: 2),
        Text(_steps[_step].subtitle, style: theme.textTheme.bodyMedium),
        const SizedBox(height: AppSpacing.lg),
        NeoCard(
          child: Column(
            children: [
              _summaryRow(
                context,
                equipmentCategoryIcon(widget.equipment.category),
                widget.equipment.title,
                '${_quantity} unit${_quantity == 1 ? '' : 's'} · '
                    '${widget.equipment.location}',
              ),
              const Divider(height: AppSpacing.lg),
              Row(
                children: [
                  const Icon(Icons.calendar_today_rounded, size: 16),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      '${Dates.weekday(_start)} ${Dates.full(_start)} → ${Dates.weekday(_end)} ${Dates.full(_end)}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  const Icon(Icons.schedule_rounded, size: 16),
                  const SizedBox(width: AppSpacing.xs),
                  Text('$_days day${_days == 1 ? '' : 's'}', style: theme.textTheme.bodyMedium),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        NeoCard(
          child: Column(
            children: [
              DetailRow(
                label: 'Rental subtotal',
                value: Money.format(preview.total),
              ),
              DetailRow(
                label: 'Platform fee (10%)',
                value: Money.format(preview.commission),
                valueColour: AppColors.accent,
              ),
              if (preview.deposit > 0)
                DetailRow(
                  label: 'Refundable deposit (recorded)',
                  value: Money.format(preview.deposit),
                ),
              const Divider(height: AppSpacing.md),
              DetailRow(
                label: 'You pay now',
                value: Money.format(preview.total),
                emphasis: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        NeoCard(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.grey500),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  'Nothing is charged yet. The owner reviews your request first — you pay only after they accept.',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: AppSpacing.md),
          NeoErrorBanner(message: _error!),
        ],
        if (booking != null) ...[
          const SizedBox(height: AppSpacing.md),
          NeoCard(
            onTap: _openChat,
            child: Row(
              children: [
                NeoAvatar(
                  initials: booking.owner?.initials ?? '?',
                  imageUrl: booking.owner?.profileImage,
                  size: 40,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Message ${booking.owner?.fullName ?? 'the owner'}',
                          style: theme.textTheme.titleSmall),
                      Text('Ask about pickup or delivery',
                          style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, size: 20),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _summaryRow(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
  ) {
    final ThemeData theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.accentSoft,
            borderRadius: AppRadii.smAll,
          ),
          child: Icon(icon, size: 22, color: AppColors.accent),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.titleSmall),
              Text(subtitle, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------------ step 4

  Widget _paymentStep(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Booking? booking = _booking;

    if (booking == null) {
      return ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: const <Widget>[
          NeoEmptyState(
            icon: Icons.receipt_long_outlined,
            title: 'No request yet',
            message: 'Go back to the summary and send your booking request first.',
          ),
        ],
      );
    }

    final bool accepted = booking.status == BookingStatus.accepted;
    final bool paid = booking.paymentStatus == PaymentStatus.paid;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text(_steps[_step].title, style: theme.textTheme.headlineMedium),
        const SizedBox(height: 2),
        Text(_steps[_step].subtitle, style: theme.textTheme.bodyMedium),
        const SizedBox(height: AppSpacing.lg),
        if (paid)
          NeoCard(
            border: true,
            child: Column(
              children: [
                const Icon(Icons.verified_rounded, size: 44, color: AppColors.success),
                const SizedBox(height: AppSpacing.sm),
                Text('Payment complete', style: theme.textTheme.headlineMedium),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  'You paid ${Money.format(booking.totalPrice)}. '
                  'The owner keeps ${Money.format(booking.ownerPayout)} and Neo keeps the 10% fee.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          )
        else if (!accepted)
          NeoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.hourglass_top_rounded, size: 18, color: AppColors.warning),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'Waiting for the owner',
                      style: theme.textTheme.titleSmall,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Your request status is ${booking.status.label.toLowerCase()}. '
                  'You will get a notification the moment the owner responds, and payment unlocks then.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.md),
                NeoButton(
                  label: 'Message the owner',
                  variant: NeoButtonVariant.secondary,
                  icon: Icons.chat_bubble_outline_rounded,
                  onPressed: _openChat,
                ),
              ],
            ),
          )
        else ...[
          Text('Amount due', style: theme.textTheme.titleSmall),
          const SizedBox(height: AppSpacing.xxs),
          Text(Money.format(booking.totalPrice), style: theme.textTheme.displayMedium),
          const SizedBox(height: AppSpacing.lg),
          Text('Pay with', style: theme.textTheme.titleSmall),
          const SizedBox(height: AppSpacing.xs),
          ...MobileMoneyProvider.values.map((MobileMoneyProvider p) {
            final bool selected = _provider == p;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: NeoCard(
                onTap: () => setState(() => _provider = p),
                border: !selected,
                child: Row(
                  children: [
                    _ProviderLogo(provider: p),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.label, style: theme.textTheme.titleSmall),
                          Text(
                            p.wire == MobileMoneyProvider.momo.wire
                                ? 'MTN Rwanda'
                                : 'Airtel Rwanda',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      selected
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_off_rounded,
                      size: 22,
                      color: selected
                          ? AppColors.accent
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: AppSpacing.sm),
          NeoField(
            label: 'Mobile money number',
            hint: '0780000000',
            controller: _phone,
            keyboardType: TextInputType.phone,
            prefixIcon: Icons.phone_iphone_rounded,
            validator: (String? v) =>
                _provider == null ? 'Choose a payment method' : null,
          ),
          if (_error != null) ...[
            const SizedBox(height: AppSpacing.md),
            NeoErrorBanner(message: _error!),
          ],
          const SizedBox(height: AppSpacing.lg),
          NeoButton(
            label: _provider == null
                ? 'Choose a payment method'
                : 'Pay ${Money.format(booking.totalPrice)}',
            icon: Icons.lock_rounded,
            loading: _busy,
            onPressed:
                _busy || _provider == null ? null : () => _pay(_provider!),
          ),
        ],
      ],
    );
  }

  // ----------------------------------------------------------------- footer

  Widget _footer(BuildContext context, bool isOwnListing) {
    final ThemeData theme = Theme.of(context);
    if (isOwnListing) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(top: BorderSide(color: theme.colorScheme.outline)),
        ),
        child: NeoButton(label: 'Close', onPressed: () => Navigator.of(context).pop()),
      );
    }

    final bool isLast = _step == _steps.length - 1;
    final bool canAdvance = _step < 2;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(top: BorderSide(color: theme.colorScheme.outline)),
      ),
      child: Row(
        children: [
          if (_step > 0) ...[
            NeoButton(
              label: 'Back',
              variant: NeoButtonVariant.secondary,
              expand: false,
              onPressed: () => _goTo(_step - 1),
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
          Expanded(
            child: NeoButton(
              label: canAdvance
                  ? 'Continue'
                  : (_booking == null ? 'Send booking request' : 'Continue to payment'),
              loading: _busy,
              icon: _booking != null && !canAdvance
                  ? Icons.arrow_forward_rounded
                  : (canAdvance ? null : Icons.send_rounded),
              onPressed: _busy
                  ? null
                  : () {
                      if (canAdvance) {
                        _goTo(_step + 1);
                      } else if (_booking == null) {
                        _createBooking();
                      } else {
                        _goTo(_step + 1);
                      }
                    },
            ),
          ),
        ],
      ),
    );
  }
}

class _FlowStep {
  const _FlowStep(this.title, this.subtitle);
  final String title;
  final String subtitle;
}

class _StepBar extends StatelessWidget {
  const _StepBar({required this.steps, required this.current});

  final List<_FlowStep> steps;
  final int current;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        0,
      ),
      child: Row(
        children: List<Widget>.generate(steps.length * 2 - 1, (int i) {
          if (i.isOdd) {
            final bool done = current > (i ~/ 2);
            return Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                color: done ? AppColors.accent : theme.colorScheme.outline,
              ),
            );
          }
          final int index = i ~/ 2;
          final bool active = index <= current;
          return Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: active ? AppColors.accent : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: active ? AppColors.accent : theme.colorScheme.outline,
                width: 1.6,
              ),
            ),
            child: Center(
              child: index < current
                  ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                  : Text(
                      '${index + 1}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: active ? Colors.white : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
            ),
          );
        }),
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Material(
      color: onPressed == null ? theme.colorScheme.surfaceContainerHigh : AppColors.accentSoft,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(9),
          child: Icon(
            icon,
            size: 20,
            color: onPressed == null
                ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4)
                : AppColors.accent,
          ),
        ),
      ),
    );
  }
}

/// Monogram tile standing in for the MTN / Airtel brand marks, drawn in the
/// app's own greys + accent so no third-party logo assets are required.
class _ProviderLogo extends StatelessWidget {
  const _ProviderLogo({required this.provider});

  final MobileMoneyProvider provider;

  @override
  Widget build(BuildContext context) {
    final bool momo = provider == MobileMoneyProvider.momo;
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: momo ? AppColors.accentSoft : AppColors.grey200,
        borderRadius: AppRadii.smAll,
      ),
      alignment: Alignment.center,
      child: Text(
        momo ? 'MoMo' : 'Airtel',
        style: AppTypography.labelSmall.copyWith(
          fontSize: 10,
          color: momo ? AppColors.accent : AppColors.grey800,
        ),
      ),
    );
  }
}