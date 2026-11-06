import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/strings.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/neo_widgets.dart';
import '../../data/models/admin_models.dart';
import '../../data/models/models.dart';
import '../../data/providers.dart';
import '../../data/repositories/admin_repository.dart';
import '../common/paged_list_view.dart';
import '../equipment/widgets/equipment_card.dart' show equipmentCategoryIcon;
import '../payments/payment_history_page.dart' show TransactionTile;
import '../trust/dispute_page.dart' show CaseStatusBadge;
import '../trust/my_reports_page.dart' show ReportTile;

/// Runs an admin mutation with a snackbar on success/failure.
Future<bool> _act(BuildContext context, Future<void> Function() run) async {
  try {
    await run();
    if (context.mounted) {
      showNeoSnack(context, L10n.i.adminSaved, icon: Icons.check_rounded);
    }
    return true;
  } on ApiException catch (e) {
    if (context.mounted) showNeoSnack(context, e.message, isError: true);
    return false;
  }
}

/// Compact pill-shaped action used in moderation rows.
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.primary = false,
    this.danger = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool primary;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color fg = primary
        ? Colors.white
        : (danger ? AppColors.danger : theme.colorScheme.onSurface);
    final Color bg = primary
        ? AppColors.accent
        : (danger ? AppColors.dangerSoft : theme.colorScheme.surfaceContainerHighest);
    return Material(
      color: bg,
      borderRadius: AppRadii.pillAll,
      child: InkWell(
        borderRadius: AppRadii.pillAll,
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (icon != null) ...<Widget>[
                Icon(icon, size: 16, color: fg),
                const SizedBox(width: 6),
              ],
              Text(label, style: theme.textTheme.labelLarge?.copyWith(color: fg)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Segmented switch shown at the top of two-list tabs.
class _Segments extends StatelessWidget {
  const _Segments({required this.labels, required this.index, required this.onChanged});

  final List<String> labels;
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
      child: Row(
        children: <Widget>[
          for (int i = 0; i < labels.length; i++) ...<Widget>[
            NeoChip(label: labels[i], selected: i == index, onTap: () => onChanged(i)),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

String _empty() => L10n.i.adminEmpty;
String _emptyBody() => L10n.i.adminEmptyBody;

// ===================================================================== USERS

class AdminUsersTab extends ConsumerStatefulWidget {
  const AdminUsersTab({super.key});

  @override
  ConsumerState<AdminUsersTab> createState() => _AdminUsersTabState();
}

class _AdminUsersTabState extends ConsumerState<AdminUsersTab>
    with AutomaticKeepAliveClientMixin {
  final PagedListController<AppUser> _list = PagedListController<AppUser>();

  @override
  bool get wantKeepAlive => true;

  AdminRepository get _repo => ref.read(adminRepositoryProvider);

  Future<void> _verify(AppUser u) async {
    if (await _act(context, () => _repo.verifyUser(u.id))) _list.refresh();
  }

  Future<void> _toggleBan(AppUser u) async {
    final S s = L10n.i;
    if (!u.isBanned) {
      final bool ok = await confirmNeo(context,
          title: s.adminBanConfirmTitle,
          message: s.adminBanConfirmBody,
          confirmLabel: s.adminBan,
          destructive: true);
      if (!ok || !mounted) return;
    }
    final bool done = await _act(
        context, () => u.isBanned ? _repo.unbanUser(u.id) : _repo.banUser(u.id));
    if (done) _list.refresh();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final S s = L10n.i;
    final ThemeData theme = Theme.of(context);
    final String me = ref.watch(sessionProvider).user?.id ?? '';
    return PagedListView<AppUser>(
      controller: _list,
      fetch: (int page) => _repo.users(page: page),
      emptyIcon: Icons.people_alt_outlined,
      emptyTitle: _empty(),
      emptyMessage: _emptyBody(),
      skeletonHeight: 110,
      itemBuilder: (BuildContext context, AppUser u) => NeoCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                NeoAvatar(initials: u.initials, imageUrl: u.profileImage, size: 44),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(u.fullName,
                          style: theme.textTheme.titleSmall,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text(
                        <String>[
                          '+${u.phone}',
                          if (u.nationalId != null) 'ID ${u.nationalId}',
                        ].join(' · '),
                        style: theme.textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                for (final UserRole r in u.roles)
                  NeoBadge(
                    label: r.label,
                    tone: r == UserRole.admin ? BadgeTone.accent : BadgeTone.neutral,
                  ),
                if (u.isVerified)
                  NeoBadge(
                      label: s.adminVerified,
                      tone: BadgeTone.success,
                      icon: Icons.verified_rounded),
                if (u.isBanned)
                  NeoBadge(label: s.adminBanned, tone: BadgeTone.danger),
              ],
            ),
            if (u.id != me && !u.isAdmin) ...<Widget>[
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: <Widget>[
                  if (!u.isVerified)
                    _ActionButton(
                      label: s.adminVerify,
                      icon: Icons.verified_outlined,
                      primary: true,
                      onPressed: () => _verify(u),
                    ),
                  if (!u.isVerified) const SizedBox(width: 8),
                  _ActionButton(
                    label: u.isBanned ? s.adminUnban : s.adminBan,
                    icon: u.isBanned ? Icons.lock_open_rounded : Icons.block_rounded,
                    danger: !u.isBanned,
                    onPressed: () => _toggleBan(u),
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

// ================================================================== LISTINGS

class AdminListingsTab extends ConsumerStatefulWidget {
  const AdminListingsTab({super.key});

  @override
  ConsumerState<AdminListingsTab> createState() => _AdminListingsTabState();
}

class _AdminListingsTabState extends ConsumerState<AdminListingsTab>
    with AutomaticKeepAliveClientMixin {
  final PagedListController<AdminEquipment> _list =
      PagedListController<AdminEquipment>();

  @override
  bool get wantKeepAlive => true;

  AdminRepository get _repo => ref.read(adminRepositoryProvider);

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final S s = L10n.i;
    final ThemeData theme = Theme.of(context);
    return PagedListView<AdminEquipment>(
      controller: _list,
      fetch: (int page) => _repo.equipment(page: page),
      emptyIcon: Icons.inventory_2_outlined,
      emptyTitle: _empty(),
      emptyMessage: _emptyBody(),
      skeletonHeight: 120,
      itemBuilder: (BuildContext context, AdminEquipment item) {
        final Equipment e = item.equipment;
        return NeoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  EquipmentImage(
                    source: e.images.isEmpty ? '' : e.images.first,
                    width: 72,
                    height: 72,
                    radius: AppRadii.md,
                    fallbackIcon: equipmentCategoryIcon(e.category),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(e.title,
                            style: theme.textTheme.titleSmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text(
                          <String>[
                            e.category.label,
                            if (item.ownerName != null) s.adminBy(item.ownerName!),
                          ].join(' · '),
                          style: theme.textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text('${Money.format(e.pricePerDay)} ${s.perDay}',
                            style: theme.textTheme.labelLarge
                                ?.copyWith(color: AppColors.accent)),
                      ],
                    ),
                  ),
                  NeoBadge(
                    label: e.isApproved ? s.adminApproved : s.adminAwaitingApproval,
                    tone: e.isApproved ? BadgeTone.success : BadgeTone.warning,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: <Widget>[
                  if (!e.isApproved) ...<Widget>[
                    _ActionButton(
                      label: s.adminApprove,
                      icon: Icons.check_rounded,
                      primary: true,
                      onPressed: () async {
                        if (await _act(context, () => _repo.approveEquipment(e.id))) {
                          _list.refresh();
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (e.isApproved)
                    _ActionButton(
                      label: s.adminReject,
                      icon: Icons.close_rounded,
                      danger: true,
                      onPressed: () async {
                        if (await _act(context, () => _repo.rejectEquipment(e.id))) {
                          _list.refresh();
                        }
                      },
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// ===================================================================== MONEY

class AdminMoneyTab extends ConsumerStatefulWidget {
  const AdminMoneyTab({super.key});

  @override
  ConsumerState<AdminMoneyTab> createState() => _AdminMoneyTabState();
}

class _AdminMoneyTabState extends ConsumerState<AdminMoneyTab>
    with AutomaticKeepAliveClientMixin {
  int _segment = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final S s = L10n.i;
    final ThemeData theme = Theme.of(context);
    final AdminRepository repo = ref.read(adminRepositoryProvider);
    return Column(
      children: <Widget>[
        _Segments(
          labels: <String>[s.adminTransactions, s.adminBookings],
          index: _segment,
          onChanged: (int i) => setState(() => _segment = i),
        ),
        Expanded(
          child: _segment == 0
              ? PagedListView<AdminTransaction>(
                  key: const ValueKey<String>('tx'),
                  fetch: (int page) => repo.transactions(page: page),
                  emptyIcon: Icons.account_balance_wallet_outlined,
                  emptyTitle: _empty(),
                  emptyMessage: _emptyBody(),
                  skeletonHeight: 76,
                  separator: 10,
                  itemBuilder: (BuildContext context, AdminTransaction t) =>
                      TransactionTile(
                    transaction: t.transaction,
                    openBooking: false,
                    subtitle: <String>[
                      if (t.userName != null) t.userName!,
                      if (t.equipmentTitle != null) t.equipmentTitle!,
                      if (t.transaction.createdAt != null)
                        Dates.relative(t.transaction.createdAt),
                    ].join(' · '),
                  ),
                )
              : PagedListView<Booking>(
                  key: const ValueKey<String>('bookings'),
                  fetch: (int page) => repo.bookings(page: page),
                  emptyIcon: Icons.receipt_long_outlined,
                  emptyTitle: _empty(),
                  emptyMessage: _emptyBody(),
                  skeletonHeight: 90,
                  separator: 10,
                  itemBuilder: (BuildContext context, Booking b) => NeoCard(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(b.equipment?.title ?? s.disputeForBooking,
                                  style: theme.textTheme.titleSmall,
                                  overflow: TextOverflow.ellipsis),
                            ),
                            NeoBadge(label: b.status.label),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${Dates.range(b.startDate, b.endDate)} · ${b.quantity}×',
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                '${s.adminRenter}: ${b.renter?.fullName ?? '—'}\n'
                                '${s.adminOwner}: ${b.owner?.fullName ?? '—'}',
                                style: theme.textTheme.bodySmall,
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                Text(Money.format(b.totalPrice),
                                    style: theme.textTheme.titleSmall),
                                Text('+${Money.format(b.commissionAmount)}',
                                    style: theme.textTheme.bodySmall
                                        ?.copyWith(color: AppColors.accent)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

// ===================================================================== TRUST

class AdminTrustTab extends ConsumerStatefulWidget {
  const AdminTrustTab({super.key});

  @override
  ConsumerState<AdminTrustTab> createState() => _AdminTrustTabState();
}

class _AdminTrustTabState extends ConsumerState<AdminTrustTab>
    with AutomaticKeepAliveClientMixin {
  int _segment = 0;
  final PagedListController<AdminReport> _reports = PagedListController<AdminReport>();
  final PagedListController<AdminDispute> _disputes =
      PagedListController<AdminDispute>();

  @override
  bool get wantKeepAlive => true;

  AdminRepository get _repo => ref.read(adminRepositoryProvider);

  /// Asks for a note/decision. Returns null when cancelled.
  Future<String?> _askNote({required String title, required bool required}) {
    final S s = L10n.i;
    final TextEditingController note = TextEditingController();
    return showNeoSheet<String>(
      context,
      child: StatefulBuilder(
        builder: (BuildContext ctx, StateSetter setLocal) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(title, style: Theme.of(ctx).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.md),
            NeoField(
              label: required ? s.adminDecisionField : s.adminNoteField,
              controller: note,
              maxLines: 4,
            ),
            const SizedBox(height: AppSpacing.md),
            NeoButton(
              label: s.commonConfirm,
              onPressed: () {
                if (required && note.text.trim().isEmpty) {
                  showNeoSnack(ctx, s.adminDecisionRequired, isError: true);
                  return;
                }
                Navigator.of(ctx).pop(note.text.trim());
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _resolveReport(AdminReport r, String status) async {
    final String? note = await _askNote(
      title: status == 'RESOLVED' ? L10n.i.adminResolve : L10n.i.adminDismiss,
      required: false,
    );
    if (note == null || !mounted) return;
    if (await _act(context,
        () => _repo.resolveReport(r.report.id, status: status, note: note))) {
      _reports.refresh();
    }
  }

  Future<void> _resolveDispute(AdminDispute d, String status) async {
    final String? decision = await _askNote(
      title: status == 'RESOLVED' ? L10n.i.adminResolve : L10n.i.adminCloseCase,
      required: true,
    );
    if (decision == null || !mounted) return;
    if (await _act(
        context,
        () => _repo.resolveDispute(d.dispute.id,
            status: status, resolution: decision))) {
      _disputes.refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final S s = L10n.i;
    final ThemeData theme = Theme.of(context);
    return Column(
      children: <Widget>[
        _Segments(
          labels: <String>[s.adminReports, s.adminDisputes],
          index: _segment,
          onChanged: (int i) => setState(() => _segment = i),
        ),
        Expanded(
          child: _segment == 0
              ? PagedListView<AdminReport>(
                  key: const ValueKey<String>('reports'),
                  controller: _reports,
                  fetch: (int page) => _repo.reports(page: page),
                  emptyIcon: Icons.flag_outlined,
                  emptyTitle: _empty(),
                  emptyMessage: _emptyBody(),
                  itemBuilder: (BuildContext context, AdminReport r) => ReportTile(
                    report: r.report,
                    byline: r.reporterName == null
                        ? null
                        : s.adminReportedBy(r.reporterName!),
                    footer: r.report.status != 'OPEN'
                        ? (r.note == null
                            ? null
                            : Text(r.note!, style: theme.textTheme.bodySmall))
                        : Row(
                            children: <Widget>[
                              _ActionButton(
                                label: s.adminResolve,
                                icon: Icons.task_alt_rounded,
                                primary: true,
                                onPressed: () => _resolveReport(r, 'RESOLVED'),
                              ),
                              const SizedBox(width: 8),
                              _ActionButton(
                                label: s.adminDismiss,
                                onPressed: () => _resolveReport(r, 'DISMISSED'),
                              ),
                            ],
                          ),
                  ),
                )
              : PagedListView<AdminDispute>(
                  key: const ValueKey<String>('disputes'),
                  controller: _disputes,
                  fetch: (int page) => _repo.disputes(page: page),
                  emptyIcon: Icons.gavel_rounded,
                  emptyTitle: _empty(),
                  emptyMessage: _emptyBody(),
                  skeletonHeight: 140,
                  itemBuilder: (BuildContext context, AdminDispute d) =>
                      _DisputeCard(
                    item: d,
                    onResolve: () => _resolveDispute(d, 'RESOLVED'),
                    onClose: () => _resolveDispute(d, 'CLOSED'),
                  ),
                ),
        ),
      ],
    );
  }
}

class _DisputeCard extends StatelessWidget {
  const _DisputeCard({required this.item, required this.onResolve, required this.onClose});

  final AdminDispute item;
  final VoidCallback onResolve;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final S s = L10n.i;
    final ThemeData theme = Theme.of(context);
    final Dispute d = item.dispute;
    Widget block(String label, String text) => Padding(
          padding: const EdgeInsets.only(top: AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(label.toUpperCase(),
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              const SizedBox(height: 2),
              Text(text, style: theme.textTheme.bodyMedium),
            ],
          ),
        );
    return NeoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(Icons.gavel_rounded, size: 18, color: AppColors.accent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  <String>[
                    if (item.renterName != null) item.renterName!,
                    if (item.ownerName != null) item.ownerName!,
                  ].join('  ⇄  '),
                  style: theme.textTheme.titleSmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              CaseStatusBadge(wire: d.status),
            ],
          ),
          if (item.openedByName != null || d.createdAt != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                <String>[
                  if (item.openedByName != null) s.adminOpenedBy(item.openedByName!),
                  if (d.createdAt != null) Dates.relative(d.createdAt),
                ].join(' · '),
                style: theme.textTheme.bodySmall,
              ),
            ),
          block(s.disputeReason, d.reason),
          if (d.response != null) block(s.disputeResponse, d.response!),
          if (d.resolution != null) block(s.disputeResolution, d.resolution!),
          if (!d.isDecided) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: <Widget>[
                _ActionButton(
                  label: s.adminResolve,
                  icon: Icons.task_alt_rounded,
                  primary: true,
                  onPressed: onResolve,
                ),
                const SizedBox(width: 8),
                _ActionButton(label: s.adminCloseCase, onPressed: onClose),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// =================================================================== REVIEWS

class AdminReviewsTab extends ConsumerStatefulWidget {
  const AdminReviewsTab({super.key});

  @override
  ConsumerState<AdminReviewsTab> createState() => _AdminReviewsTabState();
}

class _AdminReviewsTabState extends ConsumerState<AdminReviewsTab>
    with AutomaticKeepAliveClientMixin {
  final PagedListController<Review> _list = PagedListController<Review>();

  @override
  bool get wantKeepAlive => true;

  Future<void> _delete(Review r) async {
    final S s = L10n.i;
    final bool ok = await confirmNeo(context,
        title: s.adminDeleteReview,
        message: s.adminDeleteReviewBody,
        confirmLabel: s.commonDelete,
        destructive: true);
    if (!ok || !mounted) return;
    if (await _act(context, () => ref.read(adminRepositoryProvider).deleteReview(r.id))) {
      _list.removeWhere((Review x) => x.id == r.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final ThemeData theme = Theme.of(context);
    return PagedListView<Review>(
      controller: _list,
      fetch: (int page) => ref.read(adminRepositoryProvider).reviews(page: page),
      emptyIcon: Icons.reviews_outlined,
      emptyTitle: _empty(),
      emptyMessage: _emptyBody(),
      itemBuilder: (BuildContext context, Review r) => NeoCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                for (int i = 1; i <= 5; i++)
                  Icon(
                    i <= r.rating ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 16,
                    color: AppColors.star,
                  ),
                const Spacer(),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
                  tooltip: L10n.i.adminDeleteReview,
                  onPressed: () => _delete(r),
                ),
              ],
            ),
            if ((r.comment ?? '').isNotEmpty)
              Text(r.comment!, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 6),
            Text(
              <String>[
                '${r.fromUser?.fullName ?? '—'} → ${r.toUser?.fullName ?? '—'}',
                if (r.equipmentTitle != null) r.equipmentTitle!,
                if (r.createdAt != null) Dates.relative(r.createdAt),
              ].join(' · '),
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
