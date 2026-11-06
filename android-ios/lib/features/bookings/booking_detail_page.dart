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
import '../../data/repositories/social_repository.dart';
import '../chat/chat_page.dart';
import '../equipment/equipment_detail_page.dart';
import '../reviews/write_review_sheet.dart';
import 'my_bookings_page.dart';
import '../trust/dispute_page.dart';

/// Full booking view: pricing receipt, status timeline and the exact action
/// set permitted for the current user and status.
class BookingDetailPage extends ConsumerStatefulWidget {
  const BookingDetailPage({super.key, required this.bookingId});

  final String bookingId;

  @override
  ConsumerState<BookingDetailPage> createState() => _BookingDetailPageState();
}

class _BookingDetailPageState extends ConsumerState<BookingDetailPage> {
  Booking? _booking;
  List<BookingTimelineEntry> _timeline = const <BookingTimelineEntry>[];
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
      final BookingRepository repo = ref.read(bookingRepositoryProvider);
      final Booking booking = await repo.byId(widget.bookingId);
      final List<BookingTimelineEntry> timeline =
          await repo.timeline(widget.bookingId);
      if (mounted) {
        setState(() {
          _booking = booking;
          _timeline = timeline;
          _loading = false;
          _error = null;
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

  Future<void> _run(String action, {DateTime? newEnd}) async {
    final Booking? booking = _booking;
    if (booking == null) return;
    setState(() => _busy = true);
    final BookingRepository repo = ref.read(bookingRepositoryProvider);
    try {
      final Booking updated = switch (action) {
        'accept' => await repo.accept(booking.id),
        'reject' => await repo.reject(booking.id),
        'cancel' => await repo.cancel(booking.id),
        'start' => await repo.start(booking.id),
        'complete' => await repo.complete(booking.id),
        'dispute' => await repo.markDisputed(booking.id),
        _ => await repo.extend(booking.id, newEnd!),
      };
      if (!mounted) return;
      setState(() {
        _booking = updated;
        _busy = false;
      });
      await _load();
      if (mounted) {
        showNeoSnack(context, L10n.i.bdSnack(updated.status.label),
            icon: Icons.check_circle_outline_rounded);
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        showNeoSnack(context, e.message, isError: true);
      }
    }
  }

  Future<void> _pay() async {
    final Booking? booking = _booking;
    if (booking == null) return;
    final MobileMoneyProvider provider =
        MobileMoneyProvider.forPhone(
              ref.read(sessionProvider).user?.phone ?? '',
            ) ??
            MobileMoneyProvider.momo;
    setState(() => _busy = true);
    try {
      final PaymentsRepository repo = ref.read(paymentsRepositoryProvider);
      final PaymentIntent intent =
          await repo.initiate(bookingId: booking.id, provider: provider);
      await repo.confirm(intent.paymentRef);
      if (!mounted) return;
      setState(() => _busy = false);
      await _load();
      if (mounted) {
        showNeoSnack(context, L10n.i.bdPaymentConfirmed, icon: Icons.verified_rounded);
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        showNeoSnack(context, e.message, isError: true);
      }
    }
  }

  Future<void> _extend() async {
    final Booking? booking = _booking;
    if (booking == null) return;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: booking.endDate.add(const Duration(days: 1)),
      firstDate: booking.endDate.add(const Duration(days: 1)),
      lastDate: booking.endDate.add(const Duration(days: 90)),
      helpText: L10n.i.bdExtendHelp,
    );
    if (picked != null) await _run('extend', newEnd: picked);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    if (_loading) {
      return const Scaffold(body: NeoLoading());
    }
    if (_booking == null) {
      return Scaffold(
        appBar: AppBar(leading: const BackButton()),
        body: NeoErrorState(message: _error ?? L10n.i.bdNotFound, onRetry: _load),
      );
    }

    final Booking booking = _booking!;
    final String me = ref.watch(sessionProvider).user?.id ?? '';
    final bool asOwner = booking.isOwner(me);
    final UserRef? counterparty = asOwner ? booking.renter : booking.owner;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text(L10n.i.bdTitle, style: theme.textTheme.titleLarge),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: Center(child: BookingStatusBadge(status: booking.status)),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.xl,
          ),
          children: [
            if (booking.equipment != null) _equipmentCard(booking.equipment!),
            const SizedBox(height: AppSpacing.md),
            _detailsCard(booking, asOwner),
            const SizedBox(height: AppSpacing.md),
            _receipt(booking),
            const SizedBox(height: AppSpacing.lg),
            Text(L10n.i.bdTimeline, style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            _timelineView(),
            const SizedBox(height: AppSpacing.lg),
            _actions(booking, asOwner, counterparty),
          ],
        ),
      ),
    );
  }

  Widget _equipmentCard(Equipment item) {
    final ThemeData theme = Theme.of(context);
    return NeoCard(
      onTap: () => Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (BuildContext _) => EquipmentDetailPage(equipmentId: item.id),
        ),
      ),
      child: Row(
        children: [
          EquipmentImage(
            source: item.images.isEmpty ? '' : item.images.first,
            width: 70,
            height: 70,
            radius: AppRadii.md,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: theme.textTheme.titleSmall),
                const SizedBox(height: 2),
                Text('${item.location} · ${item.category.label}',
                    style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, size: 20),
        ],
      ),
    );
  }

  Widget _detailsCard(Booking booking, bool asOwner) {
    final ThemeData theme = Theme.of(context);
    return NeoCard(
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.accent),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  '${Dates.full(booking.startDate)} → ${Dates.full(booking.endDate)}',
                  style: theme.textTheme.titleSmall,
                ),
              ),
            ],
          ),
          const Divider(height: AppSpacing.lg),
          Row(
            children: [
              const Icon(Icons.inventory_2_outlined, size: 16),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '${L10n.i.flowUnitCount(booking.quantity)} · ${L10n.i.flowDayCount(booking.days)}',
                style: theme.textTheme.bodyMedium,
              ),
              const Spacer(),
              const Icon(Icons.payments_outlined, size: 16),
              const SizedBox(width: 6),
              NeoBadge(
                label: booking.paymentStatus.label,
                tone: booking.paymentStatus == PaymentStatus.paid
                    ? BadgeTone.success
                    : BadgeTone.warning,
              ),
            ],
          ),
          if (booking.notes != null && booking.notes!.isNotEmpty) ...[
            const Divider(height: AppSpacing.lg),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.sticky_note_2_outlined, size: 16),
                const SizedBox(width: AppSpacing.xs),
                Expanded(child: Text(booking.notes!, style: theme.textTheme.bodyMedium)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _receipt(Booking booking) {
    return NeoCard(
      child: Column(
        children: [
          DetailRow(
            label: L10n.i.bdTotal,
            value: Money.format(booking.totalPrice),
          ),
          DetailRow(
            label: L10n.i.flowPlatformFee,
            value: '− ${Money.format(booking.commissionAmount)}',
            valueColour: AppColors.accent,
          ),
          if (booking.depositAmount > 0)
            DetailRow(
              label: L10n.i.bdDepositRecorded,
              value: Money.format(booking.depositAmount),
            ),
          const Divider(height: AppSpacing.md),
          DetailRow(
            label: asOwnerOf(booking)
                ? L10n.i.bdYouReceive
                : L10n.i.bdOwnerReceives,
            value: Money.format(booking.ownerPayout),
            emphasis: true,
          ),
        ],
      ),
    );
  }

  bool asOwnerOf(Booking booking) =>
      booking.ownerId == ref.read(sessionProvider).user?.id;

  Widget _timelineView() {
    final ThemeData theme = Theme.of(context);
    if (_timeline.isEmpty) {
      return NeoEmptyState(
        compact: true,
        icon: Icons.timeline_rounded,
        title: L10n.i.bdNoActivityTitle,
        message: L10n.i.bdNoActivityBody,
      );
    }
    return Column(
      children: _timeline.asMap().entries.map((MapEntry<int, BookingTimelineEntry> e) {
        final BookingTimelineEntry entry = e.value;
        final bool last = e.key == _timeline.length - 1;
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 11,
                    height: 11,
                    decoration: BoxDecoration(
                      color: last ? AppColors.accent : AppColors.grey300,
                      shape: BoxShape.circle,
                    ),
                  ),
                  if (!last)
                    Expanded(
                      child: Container(width: 2, color: AppColors.grey200),
                    ),
                ],
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(entry.status.label, style: theme.textTheme.titleSmall),
                      if (entry.note != null)
                        Text(entry.note!, style: theme.textTheme.bodySmall),
                      Text(
                        '${entry.actor?.fullName ?? L10n.i.bdActorSystem} · ${Dates.relative(entry.createdAt)}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _actions(Booking booking, bool asOwner, UserRef? counterparty) {
    final List<Widget> buttons = <Widget>[];

    if (counterparty != null) {
      buttons.add(NeoButton(
        label: asOwner
            ? L10n.i.bdMessageRenter(L10n.i.roleRenter)
            : L10n.i.bdMessageOwner(L10n.i.roleOwner),
        variant: NeoButtonVariant.secondary,
        icon: Icons.chat_bubble_outline_rounded,
        onPressed: () => Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (BuildContext _) =>
                ChatPage(peer: counterparty, bookingId: booking.id),
          ),
        ),
      ));
    }

    if (!asOwner && booking.status == BookingStatus.accepted &&
        booking.paymentStatus == PaymentStatus.pending) {
      buttons.add(NeoButton(
        label: L10n.i.flowPayTotal(Money.format(booking.totalPrice)),
        icon: Icons.lock_rounded,
        loading: _busy,
        onPressed: _busy ? null : _pay,
      ));
    }

    if (asOwner && booking.status == BookingStatus.pending) {
      buttons
        ..add(NeoButton(
          label: L10n.i.bdAcceptRequest,
          loading: _busy,
          onPressed: _busy ? null : () => _run('accept'),
        ))
        ..add(NeoButton(
          label: L10n.i.bkDecline,
          variant: NeoButtonVariant.secondary,
          onPressed: _busy ? null : () => _run('reject'),
        ));
    }

    if (asOwner && booking.status == BookingStatus.accepted) {
      buttons.add(NeoButton(
        label: L10n.i.bdStart,
        loading: _busy,
        onPressed: _busy ? null : () => _run('start'),
      ));
    }

    if (booking.status == BookingStatus.accepted ||
        booking.status == BookingStatus.ongoing) {
      buttons.add(NeoButton(
        label: L10n.i.bdExtend,
        variant: NeoButtonVariant.secondary,
        icon: Icons.event_repeat_rounded,
        onPressed: _busy ? null : _extend,
      ));
    }

    if (booking.status == BookingStatus.ongoing) {
      buttons.add(NeoButton(
        label: L10n.i.bdComplete,
        loading: _busy,
        onPressed: _busy ? null : () => _run('complete'),
      ));
    }

    if (booking.status == BookingStatus.completed && !asOwner) {
      buttons.add(NeoButton(
        label: L10n.i.bdReview,
        icon: Icons.star_outline_rounded,
        onPressed: () async {
          final bool? done = await showWriteReviewSheet(context, booking);
          if (done == true) setState(() {});
        },
      ));
    }

    final String? disputeId = booking.disputeId;
    if (disputeId != null) {
      buttons.insert(
        0,
        NeoButton(
          label: L10n.i.disputeView,
          icon: Icons.gavel_rounded,
          variant: NeoButtonVariant.secondary,
          onPressed: () async {
            await Navigator.of(context).push<void>(MaterialPageRoute<void>(
                builder: (BuildContext _) =>
                    DisputePage(disputeId: disputeId)));
            if (mounted) _load();
          },
        ),
      );
    } else if (booking.status == BookingStatus.pending ||
        booking.status == BookingStatus.accepted ||
        booking.status == BookingStatus.ongoing ||
        booking.status == BookingStatus.completed) {
      buttons.add(NeoButton(
        label: L10n.i.bdReport,
        variant: NeoButtonVariant.ghost,
        icon: Icons.report_problem_outlined,
        onPressed: _busy ? null : () => _openDispute(),
      ));
    }

    if (booking.status == BookingStatus.pending ||
        booking.status == BookingStatus.accepted ||
        booking.status == BookingStatus.ongoing) {
      buttons.add(NeoButton(
        label: L10n.i.bdCancel,
        variant: NeoButtonVariant.ghost,
        onPressed: _busy
            ? null
            : () async {
                final bool ok = await confirmNeo(
                  context,
                  title: L10n.i.bdCancelTitle,
                  message:
                      L10n.i.bdCancelBody,
                  confirmLabel: L10n.i.bdCancel,
                  destructive: true,
                );
                if (ok) await _run('cancel');
              },
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (int i = 0; i < buttons.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.xs),
          buttons[i],
        ],
      ],
    );
  }

  Future<void> _openDispute() async {
    final Booking? booking = _booking;
    if (booking == null) return;
    final TextEditingController reason = TextEditingController();
    final bool? confirmed = await showNeoSheet<bool>(
      context,
      scrollable: true,
      child: StatefulBuilder(
        builder: (BuildContext ctx, StateSetter setSheet) => Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(L10n.i.bdReport,
                  style: Theme.of(ctx).textTheme.headlineMedium),
              const SizedBox(height: AppSpacing.xs),
              Text(
                L10n.i.bdDisputeBody,
                style: Theme.of(ctx).textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpacing.md),
              NeoField(
                label: L10n.i.bdDisputeField,
                controller: reason,
                maxLines: 4,
              ),
              const SizedBox(height: AppSpacing.lg),
              NeoButton(
                label: L10n.i.bdDisputeSubmit,
                variant: NeoButtonVariant.secondary,
                onPressed: () => Navigator.of(ctx).pop(true),
              ),
            ],
          ),
        ),
      ),
    );
    if (confirmed != true || reason.text.trim().isEmpty) return;
    try {
      final Dispute dispute =
          await ref.read(trustRepositoryProvider).openDispute(
                bookingId: booking.id,
                reason: reason.text.trim(),
              );
      await _load();
      if (mounted) {
        showNeoSnack(context, L10n.i.bdDisputeSnack,
            icon: Icons.gavel_rounded);
        await Navigator.of(context).push<void>(MaterialPageRoute<void>(
            builder: (BuildContext _) => DisputePage(disputeId: dispute.id)));
      }
    } on ApiException catch (e) {
      if (mounted) showNeoSnack(context, e.message, isError: true);
    }
  }
}