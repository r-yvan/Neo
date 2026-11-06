import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/neo_widgets.dart';
import '../../data/models/models.dart';
import '../../data/providers.dart';
import '../common/paged_list_view.dart';
import 'dispute_page.dart';

/// Reports the signed-in user has filed (`GET /reports/my`).
class MyReportsPage extends ConsumerWidget {
  const MyReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S s = L10n.i;
    return NeoScaffold(
      title: s.reportsTitle,
      showBack: true,
      padded: false,
      body: PagedListView<Report>(
        fetch: (int page) =>
            ref.read(trustRepositoryProvider).myReports(page: page),
        emptyIcon: Icons.flag_outlined,
        emptyTitle: s.reportsEmptyTitle,
        emptyMessage: s.reportsEmptyBody,
        skeletonHeight: 92,
        itemBuilder: (BuildContext context, Report r) => ReportTile(report: r),
      ),
    );
  }
}

class ReportTile extends StatelessWidget {
  const ReportTile({super.key, required this.report, this.footer, this.byline});

  final Report report;
  final String? byline;
  final Widget? footer;

  IconData get _icon => switch (report.targetType) {
        'USER' => Icons.person_outline_rounded,
        'REVIEW' => Icons.rate_review_outlined,
        'MESSAGE' => Icons.chat_bubble_outline_rounded,
        _ => Icons.inventory_2_outlined,
      };

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final S s = L10n.i;
    return NeoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.accentSoft,
                  borderRadius: AppRadii.mdAll,
                ),
                child: Icon(_icon, size: 20, color: AppColors.accent),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(report.reason,
                        style: theme.textTheme.titleSmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(
                      <String>[
                        s.reportTarget(report.targetType),
                        if (byline != null) byline!,
                        if (report.createdAt != null)
                          Dates.relative(report.createdAt),
                      ].join(' · '),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              CaseStatusBadge(wire: report.status),
            ],
          ),
          if ((report.details ?? '').isNotEmpty) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            Text(report.details!, style: theme.textTheme.bodyMedium),
          ],
          if (footer != null) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            footer!,
          ],
        ],
      ),
    );
  }
}
