import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/neo_widgets.dart';
import '../../data/models/models.dart';
import '../../data/providers.dart';

/// Per-category alert preferences persisted through
/// `GET/PATCH /notifications/settings`.
class NotificationSettingsPage extends ConsumerStatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  ConsumerState<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends ConsumerState<NotificationSettingsPage> {
  NotificationSettings _settings = const NotificationSettings.defaults();
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_load);
  }

  Future<void> _load() async {
    try {
      final NotificationSettings value =
          await ref.read(notificationsRepositoryProvider).settings();
      if (mounted) {
        setState(() {
          _settings = value;
          _loading = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        showNeoSnack(context, e.message, isError: true);
      }
    }
  }

  Future<void> _update(NotificationSettings next) async {
    final NotificationSettings previous = _settings;
    setState(() => _settings = next);
    setState(() => _saving = true);
    try {
      final NotificationSettings saved =
          await ref.read(notificationsRepositoryProvider).updateSettings(next);
      if (mounted) setState(() => _settings = saved);
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _settings = previous);
        showNeoSnack(context, e.message, isError: true);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text('Notification preferences', style: theme.textTheme.titleLarge),
      ),
      body: _loading
          ? const NeoLoading()
          : SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  Text('What you want to hear about',
                      style: theme.textTheme.headlineMedium),
                  const SizedBox(height: 2),
                  Text(
                    'You can turn these off at any time. Critical payment receipts always stay on.',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _toggle(
                    icon: Icons.event_note_rounded,
                    title: 'Booking updates',
                    body: 'Requests, acceptances, cancellations and completions',
                    value: _settings.bookingAlerts,
                    onChanged: (bool v) => _update(
                      _settings.copyWith(bookingAlerts: v),
                    ),
                  ),
                  _toggle(
                    icon: Icons.payments_rounded,
                    title: 'Payment activity',
                    body: 'Receipts, payouts and withdrawal updates',
                    value: _settings.paymentAlerts,
                    onChanged: (bool v) => _update(
                      _settings.copyWith(paymentAlerts: v),
                    ),
                  ),
                  _toggle(
                    icon: Icons.chat_bubble_rounded,
                    title: 'New messages',
                    body: 'Replies from owners and renters',
                    value: _settings.chatAlerts,
                    onChanged: (bool v) => _update(
                      _settings.copyWith(chatAlerts: v),
                    ),
                  ),
                  _toggle(
                    icon: Icons.campaign_rounded,
                    title: 'Tips and offers',
                    body: 'Occasional advice on listing and pricing',
                    value: _settings.marketingAlerts,
                    onChanged: (bool v) => _update(
                      _settings.copyWith(marketingAlerts: v),
                    ),
                  ),
                  if (_saving)
                    const Padding(
                      padding: EdgeInsets.only(top: AppSpacing.lg),
                      child: Center(child: ListFooterLoader(loading: true)),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _toggle({
    required IconData icon,
    required String title,
    required String body,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: NeoCard(
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.accentSoft,
                borderRadius: AppRadii.smAll,
              ),
              child: Icon(icon, size: 20, color: AppColors.accent),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleSmall),
                  const SizedBox(height: 2),
                  Text(body, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            Switch(value: value, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}