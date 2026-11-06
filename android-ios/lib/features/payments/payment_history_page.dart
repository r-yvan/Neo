import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/neo_widgets.dart';
import '../../data/models/models.dart';
import '../../data/providers.dart';
import '../bookings/booking_detail_page.dart';
import '../common/paged_list_view.dart';

/// Every money movement on the account (`GET /payments/history`).
class PaymentHistoryPage extends ConsumerWidget {
  const PaymentHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S s = L10n.i;
    return NeoScaffold(
      title: s.payHistoryTitle,
      subtitle: s.payHistorySubtitle,
      showBack: true,
      padded: false,
      body: PagedListView<Transaction>(
        fetch: (int page) =>
            ref.read(paymentsRepositoryProvider).history(page: page),
        emptyIcon: Icons.account_balance_wallet_outlined,
        emptyTitle: s.payHistoryEmptyTitle,
        emptyMessage: s.payHistoryEmptyBody,
        skeletonHeight: 76,
        separator: 10,
        header: (BuildContext context, List<Transaction> items) =>
            items.isEmpty ? const SizedBox.shrink() : _Summary(items: items),
        itemBuilder: (BuildContext context, Transaction tx) =>
            TransactionTile(transaction: tx),
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.items});

  final List<Transaction> items;

  @override
  Widget build(BuildContext context) {
    final S s = L10n.i;
    double paid = 0;
    double pending = 0;
    for (final Transaction t in items) {
      if (t.status == PaymentStatus.paid) paid += t.amount;
      if (t.status == PaymentStatus.pending) pending += t.amount;
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: <Widget>[
          Expanded(
            child: StatTile(
              label: s.payTotalPaid,
              value: Money.compact(paid),
              icon: Icons.check_circle_outline_rounded,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: StatTile(
              label: s.payTotalPending,
              value: Money.compact(pending),
              icon: Icons.schedule_rounded,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: StatTile(
              label: s.payTxCount,
              value: '${items.length}',
              icon: Icons.receipt_long_outlined,
            ),
          ),
        ],
      ),
    );
  }
}

/// One ledger row. Also used by the admin console.
class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.transaction,
    this.subtitle,
    this.openBooking = true,
  });

  final Transaction transaction;
  final String? subtitle;
  final bool openBooking;

  IconData get _icon => switch (transaction.type) {
        TransactionType.rental => Icons.event_seat_outlined,
        TransactionType.payout => Icons.south_west_rounded,
        TransactionType.commission => Icons.percent_rounded,
        TransactionType.boost => Icons.rocket_launch_outlined,
        TransactionType.withdrawal => Icons.north_east_rounded,
        TransactionType.refund => Icons.undo_rounded,
      };

  BadgeTone get _tone => switch (transaction.status) {
        PaymentStatus.paid => BadgeTone.success,
        PaymentStatus.pending => BadgeTone.warning,
        PaymentStatus.failed => BadgeTone.danger,
        PaymentStatus.refunded => BadgeTone.neutral,
      };

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Transaction tx = transaction;
    final bool incoming = tx.type.isIncoming;
    final String? title = tx.equipmentTitle;
    final String? bookingId = tx.bookingId;
    return NeoCard(
      padding: const EdgeInsets.all(14),
      onTap: openBooking && bookingId != null
          ? () => Navigator.of(context).push<void>(MaterialPageRoute<void>(
              builder: (_) => BookingDetailPage(bookingId: bookingId)))
          : null,
      child: Row(
        children: <Widget>[
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: incoming ? AppColors.successSoft : AppColors.accentSoft,
              borderRadius: AppRadii.mdAll,
            ),
            child: Icon(_icon,
                size: 20,
                color: incoming ? AppColors.success : AppColors.accent),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(tx.type.label,
                    style: theme.textTheme.titleSmall,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(
                  subtitle ??
                      <String>[
                        if (title != null) title,
                        if (tx.createdAt != null) Dates.relative(tx.createdAt),
                      ].join(' · '),
                  style: theme.textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                '${incoming ? '+' : ''}${Money.format(tx.amount)}',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: incoming ? AppColors.success : null,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              NeoBadge(label: tx.status.label, tone: _tone),
            ],
          ),
        ],
      ),
    );
  }
}
