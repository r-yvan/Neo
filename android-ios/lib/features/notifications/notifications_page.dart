import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/neo_widgets.dart';
import '../../data/models/models.dart';
import '../../data/providers.dart';
import '../bookings/booking_detail_page.dart';
import 'notification_settings_page.dart';

/// Notification centre, grouped by type with a mark-all-read action.
class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key, this.unreadOnly = false});

  final bool unreadOnly;

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  List<AppNotification> _items = const <AppNotification>[];
  int _page = 1;
  bool _hasMore = true;
  bool _loading = true;
  bool _loadingMore = false;
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
      final NotificationsRepository repo =
          ref.read(notificationsRepositoryProvider);
      final PaginatedList<AppNotification> page = widget.unreadOnly
          ? await repo.unread()
          : await repo.list();
      if (!mounted) return;
      setState(() {
        _items = page.items;
        _page = 1;
        _hasMore = page.hasMore;
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

  Future<void> _loadMore() async {
    if (_loadingMore || !_hasMore) return;
    setState(() => _loadingMore = true);
    try {
      final NotificationsRepository repo =
          ref.read(notificationsRepositoryProvider);
      final PaginatedList<AppNotification> page = widget.unreadOnly
          ? await repo.unread(page: _page + 1)
          : await repo.list(page: _page + 1);
      if (!mounted) return;
      setState(() {
        _items = <AppNotification>[..._items, ...page.items];
        _page = _page + 1;
        _hasMore = page.hasMore;
        _loadingMore = false;
      });
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message;
          _loadingMore = false;
        });
      }
    }
  }

  Future<void> _markAll() async {
    try {
      await ref.read(notificationsRepositoryProvider).markAllRead();
      if (!mounted) return;
      setState(() {
        _items = _items
            .map((AppNotification n) => AppNotification(
                  id: n.id,
                  title: n.title,
                  body: n.body,
                  type: n.type,
                  isRead: true,
                  data: n.data,
                  createdAt: n.createdAt,
                ))
            .toList();
      });
    } on ApiException catch (e) {
      if (mounted) showNeoSnack(context, e.message, isError: true);
    }
  }

  Future<void> _open(AppNotification item) async {
    if (!item.isRead) {
      try {
        await ref.read(notificationsRepositoryProvider).markRead(item.id);
        if (mounted) {
          setState(() {
            _items = _items
                .map((AppNotification n) => n.id == item.id
                    ? AppNotification(
                        id: n.id,
                        title: n.title,
                        body: n.body,
                        type: n.type,
                        isRead: true,
                        data: n.data,
                        createdAt: n.createdAt,
                      )
                    : n)
                .toList();
          });
        }
      } catch (_) {
        // Read state is cosmetic.
      }
    }
    final String? bookingId = item.bookingId;
    if (bookingId == null || !mounted) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (BuildContext _) => BookingDetailPage(bookingId: bookingId),
      ),
    );
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final int unread = _items.where((AppNotification n) => !n.isRead).length;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text(widget.unreadOnly ? 'Unread' : 'Notifications',
            style: theme.textTheme.titleLarge),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded, size: 21),
            tooltip: 'Preferences',
            onPressed: () => Navigator.of(context).push<void>(
              MaterialPageRoute<void>(
                builder: (BuildContext _) => const NotificationSettingsPage(),
              ),
            ),
          ),
          if (unread > 0)
            TextButton(onPressed: _markAll, child: const Text('Read all')),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.accent,
          onRefresh: _load,
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification n) {
              if (n.metrics.pixels > n.metrics.maxScrollExtent - 400) _loadMore();
              return false;
            },
            child: _loading && _items.isEmpty
                ? const NeoLoading()
                : _error != null && _items.isEmpty
                    ? NeoErrorState(message: _error!, onRetry: _load)
                    : _items.isEmpty
                        ? const NeoEmptyState(
                            icon: Icons.notifications_none_rounded,
                            title: 'All caught up',
                            message:
                                'Booking updates, payments and messages will show up here.',
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            itemCount: _items.length,
                            itemBuilder: (BuildContext context, int index) =>
                                _NotificationTile(
                              item: _items[index],
                              onTap: () => _open(_items[index]),
                            ),
                          ),
          ),
        ),
      ),
      bottomNavigationBar: _loadingMore
          ? const Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.lg),
              child: ListFooterLoader(loading: true),
            )
          : null,
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.item, required this.onTap});

  final AppNotification item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final (IconData icon, BadgeTone tone) = switch (item.type) {
      NotificationType.booking => (Icons.event_note_rounded, BadgeTone.accent),
      NotificationType.payment => (Icons.payments_rounded, BadgeTone.success),
      NotificationType.chat => (Icons.chat_bubble_rounded, BadgeTone.accent),
      NotificationType.review => (Icons.star_rounded, BadgeTone.warning),
      NotificationType.dispute => (Icons.gavel_rounded, BadgeTone.danger),
      NotificationType.system => (Icons.info_outline_rounded, BadgeTone.neutral),
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: NeoCard(
        onTap: onTap,
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: tone == BadgeTone.accent
                    ? AppColors.accentSoft
                    : theme.colorScheme.surfaceContainerHigh,
                borderRadius: AppRadii.smAll,
              ),
              child: Icon(
                icon,
                size: 19,
                color: tone == BadgeTone.accent
                    ? AppColors.accent
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: item.isRead
                                ? AppFontWeight.medium
                                : AppFontWeight.bold,
                          ),
                        ),
                      ),
                      if (!item.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(item.body, style: theme.textTheme.bodySmall),
                  const SizedBox(height: 4),
                  Text(Dates.relative(item.createdAt), style: theme.textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
