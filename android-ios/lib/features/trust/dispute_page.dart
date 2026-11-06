import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/strings.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/neo_widgets.dart';
import '../../data/models/models.dart';
import '../../data/providers.dart';

/// One dispute: what was reported, the other party's response and Neo's
/// decision, shown as a three-step timeline. The party who did not open the
/// dispute can respond while it is OPEN.
class DisputePage extends ConsumerStatefulWidget {
  const DisputePage({super.key, required this.disputeId});

  final String disputeId;

  @override
  ConsumerState<DisputePage> createState() => _DisputePageState();
}

class _DisputePageState extends ConsumerState<DisputePage> {
  Dispute? _dispute;
  String? _error;
  bool _sending = false;
  final TextEditingController _response = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _response.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final Dispute d =
          await ref.read(trustRepositoryProvider).dispute(widget.disputeId);
      if (mounted) setState(() => _dispute = d);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  Future<void> _respond() async {
    final String text = _response.text.trim();
    if (text.length < 10) {
      showNeoSnack(context, L10n.i.disputeRespondHint, isError: true);
      return;
    }
    setState(() => _sending = true);
    try {
      await ref.read(trustRepositoryProvider).respond(widget.disputeId, text);
      _response.clear();
      await _load();
      if (mounted) {
        showNeoSnack(context, L10n.i.disputeResponded,
            icon: Icons.check_circle_outline_rounded);
      }
    } on ApiException catch (e) {
      if (mounted) showNeoSnack(context, e.message, isError: true);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final S s = L10n.i;
    final Dispute? d = _dispute;
    return NeoScaffold(
      title: s.disputeTitle,
      subtitle: d?.bookingEquipmentTitle,
      showBack: true,
      padded: false,
      body: d == null
          ? (_error != null
              ? Center(child: NeoErrorState(message: _error!, onRetry: _load))
              : const NeoLoading())
          : RefreshIndicator(
              color: AppColors.accent,
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                children: _content(context, d),
              ),
            ),
    );
  }

  List<Widget> _content(BuildContext context, Dispute d) {
    final S s = L10n.i;
    final ThemeData theme = Theme.of(context);
    final String me = ref.watch(sessionProvider).user?.id ?? '';
    final bool canRespond =
        d.isOpen && d.response == null && d.openedById != null && d.openedById != me;

    return <Widget>[
      NeoCard(
        child: Row(
          children: <Widget>[
            Container(
              width: 46,
              height: 46,
              decoration: const BoxDecoration(
                color: AppColors.accentSoft,
                borderRadius: AppRadii.mdAll,
              ),
              child: const Icon(Icons.gavel_rounded, color: AppColors.accent),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(d.bookingEquipmentTitle ?? s.disputeForBooking,
                      style: theme.textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(
                    <String>[
                      if (d.openedByName != null) s.adminOpenedBy(d.openedByName!),
                      if (d.createdAt != null) Dates.relative(d.createdAt),
                    ].join(' · '),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            CaseStatusBadge(wire: d.status),
          ],
        ),
      ),
      const SizedBox(height: AppSpacing.lg),
      _Step(
        done: true,
        isLast: false,
        title: s.disputeStepOpened,
        when: d.createdAt,
        child: _Quote(label: s.disputeReason, text: d.reason),
      ),
      _Step(
        done: d.response != null,
        active: d.isOpen,
        isLast: false,
        title: s.disputeStepResponse,
        child: d.response != null
            ? _Quote(label: s.disputeResponse, text: d.response!)
            : canRespond
                ? _RespondForm(
                    controller: _response,
                    sending: _sending,
                    onSubmit: _respond,
                  )
                : Text(s.disputeNoResponse, style: theme.textTheme.bodySmall),
      ),
      _Step(
        done: d.isDecided,
        active: !d.isOpen && !d.isDecided,
        isLast: true,
        title: s.disputeStepDecision,
        when: d.isDecided ? d.updatedAt : null,
        child: d.resolution != null
            ? _Quote(
                label: s.disputeResolution,
                text: d.resolution!,
                highlight: true,
              )
            : Text(s.disputeAwaitingDecision, style: theme.textTheme.bodySmall),
      ),
    ];
  }
}

class _Step extends StatelessWidget {
  const _Step({
    required this.done,
    required this.isLast,
    required this.title,
    required this.child,
    this.active = false,
    this.when,
  });

  final bool done;
  final bool active;
  final bool isLast;
  final String title;
  final Widget child;
  final DateTime? when;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color dot = done
        ? AppColors.accent
        : (active ? AppColors.accent.withValues(alpha: 0.4) : theme.colorScheme.outline);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(
            width: 28,
            child: Column(
              children: <Widget>[
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: done ? AppColors.accent : theme.colorScheme.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: dot, width: 2),
                  ),
                  child: done
                      ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                      : null,
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: done ? AppColors.accent : theme.colorScheme.outline,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(child: Text(title, style: theme.textTheme.titleSmall)),
                      if (when != null)
                        Text(Dates.relative(when), style: theme.textTheme.bodySmall),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  child,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Quote extends StatelessWidget {
  const _Quote({required this.label, required this.text, this.highlight = false});

  final String label;
  final String text;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: highlight ? AppColors.accentSofter : theme.colorScheme.surface,
        borderRadius: AppRadii.mdAll,
        border: Border.all(
          color: highlight ? AppColors.accent.withValues(alpha: 0.3) : theme.colorScheme.outline,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                  color: highlight ? AppColors.accent : theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 6),
          Text(text, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _RespondForm extends StatelessWidget {
  const _RespondForm({
    required this.controller,
    required this.sending,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final bool sending;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final S s = L10n.i;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(s.disputeRespondHint, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: AppSpacing.sm),
        NeoField(
          label: s.disputeRespondField,
          controller: controller,
          maxLines: 5,
        ),
        const SizedBox(height: AppSpacing.sm),
        NeoButton(
          label: s.disputeRespondSubmit,
          icon: Icons.send_rounded,
          loading: sending,
          onPressed: sending ? null : onSubmit,
        ),
      ],
    );
  }
}

/// Status pill shared by reports and disputes.
class CaseStatusBadge extends StatelessWidget {
  const CaseStatusBadge({super.key, required this.wire});

  final String wire;

  @override
  Widget build(BuildContext context) {
    final BadgeTone tone = switch (wire) {
      'RESOLVED' => BadgeTone.success,
      'IN_REVIEW' => BadgeTone.warning,
      'DISMISSED' || 'CLOSED' => BadgeTone.neutral,
      _ => BadgeTone.accent,
    };
    return NeoBadge(label: L10n.i.caseStatus(wire), tone: tone);
  }
}

