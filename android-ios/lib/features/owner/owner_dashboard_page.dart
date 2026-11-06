import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/neo_widgets.dart';
import '../../data/models/models.dart';
import '../../data/providers.dart';
import '../../data/repositories/booking_repository.dart';
import '../../data/repositories/users_repository.dart';
import '../bookings/booking_detail_page.dart';
import '../equipment/equipment_form_page.dart';

/// Owner control room: earnings, listings (boost control), incoming requests
/// and MoMo withdrawals. Everything comes from the live API — no mocks.
class OwnerDashboardPage extends ConsumerStatefulWidget {
  const OwnerDashboardPage({super.key});

  @override
  ConsumerState<OwnerDashboardPage> createState() => _OwnerDashboardPageState();
}

class _OwnerDashboardPageState extends ConsumerState<OwnerDashboardPage> {
  double _earnings = 0;
  EarningsBreakdown? _breakdown;
  List<Booking> _requests = const <Booking>[];
  List<Withdrawal> _withdrawals = const <Withdrawal>[];
  List<Equipment> _listings = const <Equipment>[];

  bool _loading = true;
  bool _withdrawBusy = false;
  String? _error;

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
      final paymentsRepo = ref.read(paymentsRepositoryProvider);
      final results = await Future.wait(<Future<dynamic>>[
        paymentsRepo.earnings(),
        paymentsRepo.earningsBreakdown(),
        ref
            .read(bookingRepositoryProvider)
            .mine(role: BookingRole.owner, limit: 10),
        paymentsRepo.withdrawals(limit: 10),
        ref.read(equipmentRepositoryProvider).mine(limit: 50),
      ]);
      if (!mounted) return;
      setState(() {
        _earnings = results[0] as double;
        _breakdown = results[1] as EarningsBreakdown;
        final bookPage = results[2] as PaginatedList<Booking>;
        _requests = bookPage.items;
        final withdrawalsPage = results[3] as PaginatedList<Withdrawal>;
        _withdrawals = withdrawalsPage.items;
        final listingsPage = results[4] as PaginatedList<Equipment>;
        _listings = listingsPage.items;
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

  // ------------------------------------------------------------- booking ops

  Future<void> _decide(Booking booking, _OwnerDecision decision) async {
    setState(() => _requests = <Booking>[
          for (final Booking b in _requests)
            if (b.id == booking.id)
              b.copyWith(status: decision == _OwnerDecision.accept
                  ? BookingStatus.accepted
                  : BookingStatus.rejected)
            else
              b,
        ]);
    try {
      final repo = ref.read(bookingRepositoryProvider);
      if (decision == _OwnerDecision.accept) {
        await repo.accept(booking.id);
      } else {
        await repo.reject(booking.id);
      }
      showNeoSnack(
        context,
        decision == _OwnerDecision.accept
            ? 'Booking accepted'
            : 'Booking rejected',
        icon: Icons.check_circle_outline_rounded,
      );
      await _load();
    } on ApiException catch (e) {
      if (mounted) {
        showNeoSnack(context, e.message, isError: true);
        await _load();
      }
    }
  }

  Future<void> _startRental(Booking booking) async {
    try {
      await ref.read(bookingRepositoryProvider).start(booking.id);
      showNeoSnack(context, 'Rental started', icon: Icons.play_arrow_rounded);
      await _load();
    } on ApiException catch (e) {
      if (mounted) showNeoSnack(context, e.message, isError: true);
    }
  }

  Future<void> _completeRental(Booking booking) async {
    try {
      await ref.read(bookingRepositoryProvider).complete(booking.id);
      showNeoSnack(
          context, 'Rental completed — payout on its way',
          icon: Icons.verified_rounded);
      await _load();
    } on ApiException catch (e) {
      if (mounted) showNeoSnack(context, e.message, isError: true);
    }
  }

  // ------------------------------------------------------------ listing ops

  Future<void> _toggleAvailability(Equipment item) async {
    setState(() {
      _listings = <Equipment>[
        for (final Equipment e in _listings)
          if (e.id == item.id)
            e.copyWith(isAvailable: !item.isAvailable)
          else
            e,
      ];
    });
    try {
      await ref
          .read(equipmentRepositoryProvider)
          .setAvailability(item.id, isAvailable: !item.isAvailable);
    } on ApiException catch (e) {
      if (mounted) {
        showNeoSnack(context, e.message, isError: true);
        await _load();
      }
    }
  }

  Future<void> _boostDialog(Equipment item) async {
    final PlatformConfig config =
        ref.read(platformConfigProvider).valueOrNull ??
            const PlatformConfig.fallback();
    if (item.isBoosted) {
      final bool ok = await confirmNeo(
        context,
        title: 'Stop the boost?',
        message:
            '"${item.title}" is boosted until ${Dates.short(item.boostedUntil ?? DateTime.now())}. '
            'Ending it early does not refund the fee.',
        confirmLabel: 'Stop boost',
        destructive: true,
      );
      if (ok != true) return;
      try {
        await ref.read(equipmentRepositoryProvider).cancelBoost(item.id);
        showNeoSnack(context, 'Boost ended', icon: Icons.bolt_rounded);
      } on ApiException catch (e) {
        if (mounted) showNeoSnack(context, e.message, isError: true);
      }
      await _load();
      return;
    }

    final BoostTier? tier = await showNeoSheet<BoostTier>(
      context,
      scrollable: true,
      child: _BoostTierPicker(config: config),
    );
    if (tier == null) return;
    try {
      await ref
          .read(equipmentRepositoryProvider)
          .boost(item.id, days: tier.durationDays);
      showNeoSnack(
        context,
        'Boosted for ${tier.durationDays} days',
        icon: Icons.bolt_rounded,
      );
      await _load();
    } on ApiException catch (e) {
      if (mounted) showNeoSnack(context, e.message, isError: true);
    }
  }

  Future<void> _editListing(Equipment item) async {
    final bool? saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (BuildContext _) => EquipmentFormPage(existing: item),
      ),
    );
    if (saved == true) await _load();
  }

  Future<void> _deleteListing(Equipment item) async {
    final bool ok = await confirmNeo(
      context,
      title: 'Delete listing?',
      message: '"${item.title}" will disappear from search. '
          'This cannot be undone.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (ok != true) return;
    setState(
        () => _listings = _listings.where((Equipment e) => e.id != item.id).toList());
    try {
      await ref.read(equipmentRepositoryProvider).delete(item.id);
      showNeoSnack(context, 'Listing deleted');
    } on ApiException catch (e) {
      if (mounted) {
        showNeoSnack(context, e.message, isError: true);
        await _load();
      }
    }
  }

  // ------------------------------------------------------------- withdraw

  Future<void> _withdrawSheet() async {
    final AppUser? user = ref.read(sessionProvider).user;
    if (user == null) return;
    final MobileMoneyProvider provider =
        MobileMoneyProvider.forPhone(user.phone) ?? MobileMoneyProvider.momo;

    if (_earnings <= 0) {
      showNeoSnack(
          context, 'Nothing to withdraw yet — earnings appear after rentals.',
          isError: true);
      return;
    }

    final _WithdrawalInput? input = await showNeoSheet<_WithdrawalInput>(
      context,
      scrollable: true,
      child: _WithdrawForm(
        balance: _earnings,
        defaultPhone: user.phone,
        provider: provider,
      ),
    );

    if (input == null) return;
    setState(() => _withdrawBusy = true);
    try {
      final Withdrawal result = await ref
          .read(paymentsRepositoryProvider)
          .withdraw(
            amount: input.amount,
            phone: input.phone,
            provider: provider,
          );
      if (!mounted) return;
      setState(() {
        _withdrawals = <Withdrawal>[result, ..._withdrawals];
        _withdrawBusy = false;
        _earnings = (_earnings - input.amount).clamp(0, double.infinity);
      });
      showNeoSnack(
          context, 'Withdrawal requested', icon: Icons.account_balance_rounded);
      await _load();
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _withdrawBusy = false);
        showNeoSnack(context, e.message, isError: true);
      }
    }
  }

  // ------------------------------------------------------------------- view

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Owner dashboard'),
        actions: <Widget>[
          if (!_loading)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.md),
              child: TextButton.icon(
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Refresh'),
                onPressed: _load,
              ),
            ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.accent,
          onRefresh: _load,
          child: _loading && _listings.isEmpty
              ? ListView(
                  children: const <Widget>[
                    SkeletonCard(),
                    SkeletonCard(),
                    SkeletonCard(),
                  ],
                )
              : _error != null && _listings.isEmpty
                  ? ListView(
                      children: <Widget>[
                        const SizedBox(height: 60),
                        NeoErrorState(message: _error!, onRetry: _load),
                      ],
                    )
                  : _content(context),
        ),
      ),
    );
  }

  Widget _content(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SectionHeader(
                  title: 'Earnings',
                  subtitle: 'Net payouts after the platform commission.',
                ),
                const SizedBox(height: AppSpacing.sm),
                StatTile(
                  label: 'Available earnings',
                  value: Money.format(_earnings),
                  icon: Icons.account_balance_wallet_rounded,
                  caption: 'Lifetime net',
                ),
                if (_breakdown != null && _breakdown!.byMonth.isNotEmpty) ...<Widget>[
                  const SizedBox(height: AppSpacing.sm),
                  NeoCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Last months', style: theme.textTheme.labelLarge),
                        const SizedBox(height: AppSpacing.sm),
                        EarningsBars(entries: _breakdown!.orderedMonths),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.sm),
                NeoButton(
                  label: _withdrawBusy ? 'Submitting…' : 'Withdraw to mobile money',
                  icon: Icons.phonelink_ring_rounded,
                  variant: NeoButtonVariant.secondary,
                  loading: _withdrawBusy,
                  onPressed: _withdrawBusy ? null : _withdrawSheet,
                ),
              ],
            ),
          ),
        ),

        // -------------------------------------------------------- listings
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.xs,
            ),
            child: SectionHeader(
              title: 'My listings',
              subtitle: '${_listings.length} item${_listings.length == 1 ? '' : 's'}',
              actionLabel: 'New',
              onAction: () async {
                final bool? saved = await Navigator.of(context).push<bool>(
                  MaterialPageRoute<bool>(
                    builder: (BuildContext _) => const EquipmentFormPage(),
                  ),
                );
                if (saved == true) await _load();
              },
            ),
          ),
        ),
        if (_listings.isEmpty)
          const SliverToBoxAdapter(
            child: NeoEmptyState(
              icon: Icons.inventory_2_outlined,
              title: 'No listings yet',
              message: 'Add your first item and renters will find it in search.',
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) =>
                    _listingTile(context, _listings[index]),
                childCount: _listings.length,
              ),
            ),
          ),

        // ------------------------------------------------------- requests
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.xs,
            ),
            child: SectionHeader(
              title: 'Booking requests',
              subtitle: 'Accept, reject or manage rental progress.',
            ),
          ),
        ),
        if (_requests.isEmpty)
          const SliverToBoxAdapter(
            child: NeoEmptyState(
              icon: Icons.event_busy_rounded,
              title: 'No requests yet',
              message: 'When a renter books your item, accept or decline here.',
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) =>
                    _requestTile(context, _requests[index]),
                childCount: _requests.length,
              ),
            ),
          ),

        // ---------------------------------------------------- withdrawals
        if (_withdrawals.isNotEmpty)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.xs,
              ),
              child: SectionHeader(
                title: 'Withdrawals',
                subtitle: 'Requests land on your mobile money line.',
              ),
            ),
          ),
        if (_withdrawals.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.xxl,
            ),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  final Withdrawal w = _withdrawals[index];
                  return NeoCard(
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: AppColors.accentSoft,
                            borderRadius: AppRadii.smAll,
                          ),
                          child: const Icon(
                            Icons.phonelink_ring_rounded,
                            size: 20,
                            color: AppColors.accent,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                '${w.provider == 'AIRTEL' ? 'Airtel' : 'MTN'} • ${w.phone}',
                                style: theme.textTheme.titleSmall,
                              ),
                              Text(
                                Dates.short(w.createdAt ?? DateTime.now()),
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          Money.format(w.amount),
                          style: theme.textTheme.titleMedium,
                        ),
                      ],
                    ),
                  );
                },
                childCount: _withdrawals.length,
              ),
            ),
          )
        else
          const SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.xxl),
          ),
      ],
    );
  }

  Widget _listingTile(BuildContext context, Equipment item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: NeoCard(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                EquipmentImage(
                    source: item.images.isNotEmpty ? item.images.first : '',
                    width: 56,
                    height: 56),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              item.title,
                              style: Theme.of(context).textTheme.titleSmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (item.isBoosted)
                            const NeoBadge(
                              label: 'Boosted',
                              tone: BadgeTone.accent,
                              icon: Icons.bolt_rounded,
                            ),
                          if (!item.isAvailable) ...<Widget>[
                            const SizedBox(width: 6),
                            const NeoBadge(
                              label: 'Paused',
                              tone: BadgeTone.warning,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${Money.format(item.pricePerDay)}/day • ${item.location}',
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: <Widget>[
                Expanded(
                  child: NeoButton(
                    label: item.isBoosted ? 'Stop boost' : 'Boost',
                    icon: Icons.bolt_rounded,
                    variant: NeoButtonVariant.ghost,
                    expand: false,
                    onPressed: () => _boostDialog(item),
                  ),
                ),
                Expanded(
                  child: NeoButton(
                    label: item.isAvailable ? 'Pause' : 'Resume',
                    icon: item.isAvailable
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    variant: NeoButtonVariant.ghost,
                    expand: false,
                    onPressed: () => _toggleAvailability(item),
                  ),
                ),
                Expanded(
                  child: NeoButton(
                    label: 'Edit',
                    icon: Icons.edit_outlined,
                    variant: NeoButtonVariant.ghost,
                    expand: false,
                    onPressed: () => _editListing(item),
                  ),
                ),
                NeoIconButton(
                  icon: Icons.delete_outline_rounded,
                  tooltip: 'Delete',
                  onPressed: () => _deleteListing(item),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _requestTile(BuildContext context, Booking booking) {
    final ThemeData theme = Theme.of(context);
    final String title = booking.equipment?.title ?? 'Equipment';

    final Widget actions = switch (booking.status) {
      BookingStatus.pending => Row(
          children: <Widget>[
            Expanded(
              child: NeoButton(
                label: 'Accept',
                variant: NeoButtonVariant.primary,
                expand: false,
                onPressed: () => _decide(booking, _OwnerDecision.accept),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: NeoButton(
                label: 'Reject',
                variant: NeoButtonVariant.secondary,
                expand: false,
                onPressed: () => _decide(booking, _OwnerDecision.reject),
              ),
            ),
          ],
        ),
      BookingStatus.accepted => NeoButton(
          label: 'Rental picked up',
          icon: Icons.play_arrow_rounded,
          onPressed: () => _startRental(booking),
        ),
      BookingStatus.ongoing => NeoButton(
          label: 'Mark completed',
          icon: Icons.check_circle_outline_rounded,
          onPressed: () => _completeRental(booking),
        ),
      _ => const SizedBox.shrink(),
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: NeoCard(
        onTap: () => Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (BuildContext _) =>
                BookingDetailPage(bookingId: booking.id),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(title, style: theme.textTheme.titleSmall),
                      Text(
                        '${booking.renter?.fullName ?? 'Renter'} • '
                        '${Dates.short(booking.startDate)} – ${Dates.short(booking.endDate)} • '
                        '×${booking.quantity}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  Money.format(booking.totalPrice),
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            actions,
          ],
        ),
      ),
    );
  }
}

enum _OwnerDecision { accept, reject }

// ------------------------------------------------------------------- sheets

class _WithdrawalInput {
  const _WithdrawalInput({required this.amount, required this.phone});

  final double amount;
  final String phone;
}

class _WithdrawForm extends StatefulWidget {
  const _WithdrawForm({
    required this.balance,
    required this.defaultPhone,
    required this.provider,
  });

  final double balance;
  final String defaultPhone;
  final MobileMoneyProvider provider;

  @override
  State<_WithdrawForm> createState() => _WithdrawFormState();
}

class _WithdrawFormState extends State<_WithdrawForm> {
  final TextEditingController _amount = TextEditingController();
  late final TextEditingController _phone =
      TextEditingController(text: widget.defaultPhone);
  String? _error;

  @override
  void dispose() {
    _amount.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _submit() {
    final double? amount = double.tryParse(_amount.text.trim());
    if (amount == null || amount <= 0) {
      setState(() => _error = 'Enter a valid amount');
      return;
    }
    if (amount > widget.balance) {
      setState(() => _error = 'Amount exceeds your balance');
      return;
    }
    final String phone = _phone.text.trim();
    if (phone.length < 10) {
      setState(() => _error = 'Enter the full mobile money number');
      return;
    }
    Navigator.of(context).pop(
      _WithdrawalInput(amount: amount, phone: phone),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text('Withdraw to ${widget.provider.label}',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Available balance: ${Money.format(widget.balance)}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          NeoField(
            label: 'Amount (RWF)',
            controller: _amount,
            keyboardType: TextInputType.number,
          ),
          if (_error != null) ...<Widget>[
            const SizedBox(height: AppSpacing.xs),
            Text(_error!, style: Theme.of(context).textTheme.labelSmall!.copyWith(color: AppColors.danger)),
          ],
          const SizedBox(height: AppSpacing.sm),
          NeoField(
            label: 'Mobile money number',
            controller: _phone,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: AppSpacing.md),
          NeoButton(label: 'Request withdrawal', onPressed: _submit),
        ],
      ),
    );
  }
}

class _BoostTierPicker extends StatelessWidget {
  const _BoostTierPicker({required this.config});

  final PlatformConfig config;

  @override
  Widget build(BuildContext context) {
    final List<BoostTier> tiers = config.boostTiers;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text('Boost this listing', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Boosted listings appear first in Explore.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          if (tiers.isEmpty)
            NeoButton(
              label: 'Boost (standard fee)',
              icon: Icons.bolt_rounded,
              onPressed: () => Navigator.of(context).pop(
                const BoostTier(durationDays: 7, price: 3000, label: '7 days'),
              ),
            )
          else
            ...tiers.map(
              (BoostTier tier) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: NeoCard(
                  onTap: () => Navigator.of(context).pop(tier),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: AppColors.accentSoft,
                          borderRadius: AppRadii.smAll,
                        ),
                        child: const Icon(
                          Icons.bolt_rounded,
                          size: 20,
                          color: AppColors.accent,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(tier.label,
                            style: Theme.of(context).textTheme.titleSmall),
                      ),
                      Text(
                        Money.format(tier.price),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
