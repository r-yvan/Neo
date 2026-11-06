import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_config.dart';
import '../../core/l10n/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/neo_widgets.dart';
import '../../data/models/models.dart';
import '../../data/providers.dart';
import '../bookings/my_bookings_page.dart';
import '../chat/conversations_page.dart';
import '../favorites/favorites_page.dart';
import '../home/explore_page.dart';
import '../owner/owner_dashboard_page.dart';
import '../profile/profile_page.dart';

/// Tab state survives tab switches via [IndexedStack].
///
/// The tab index is lifted into a provider so a deep action (e.g. "open my
/// bookings" from a notification) can drive navigation.
final StateProvider<int> shellTabProvider = StateProvider<int>((Ref ref) => 0);

/// Opens the shell on a given tab. Safe to call from anywhere.
void openShellTab(BuildContext context, int index) {
  ProviderScope.containerOf(context, listen: false)
      .read(shellTabProvider.notifier)
      .state = index;
}

/// Tabs in display order.
abstract final class ShellTab {
  static const int explore = 0;
  static const int bookings = 1;
  static const int saved = 2;
  static const int messages = 3;
  static const int owner = 4;
  static const int profile = 5;
}

class RootShell extends ConsumerStatefulWidget {
  const RootShell({super.key, this.initialTab = ShellTab.explore});

  final int initialTab;

  @override
  ConsumerState<RootShell> createState() => _RootShellState();
}

class _RootShellState extends ConsumerState<RootShell> {
  late int _index = widget.initialTab;
  final Map<int, int> _badgeCounts = <int, int>{};

  Timer? _badgeTimer;

  @override
  void initState() {
    super.initState();
    _index = widget.initialTab;
    // Keep the provider in sync so deep actions start from the right tab.
    Future<void>.microtask(
        () => ref.read(shellTabProvider.notifier).state = _index);
    _refreshBadges();
    _badgeTimer =
        Timer.periodic(AppConfig.badgePollInterval, (_) => _refreshBadges());
  }

  @override
  void dispose() {
    _badgeTimer?.cancel();
    super.dispose();
  }

  /// Unread chat count for the Messages tab. Failures are silent — a badge
  /// is a hint, never a blocker.
  Future<void> _refreshBadges() async {
    try {
      final int unread = await ref.read(chatRepositoryProvider).unreadCount();
      if (mounted && _badgeCounts[ShellTab.messages] != unread) {
        setState(() => _badgeCounts[ShellTab.messages] = unread);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int>(shellTabProvider, (int? _, int next) {
      if (next != _index) setState(() => _index = next);
    });

    final bool hasOwnerRole =
        ref.watch(sessionProvider).user?.isOwner ?? false;

    final List<Widget> pages = <Widget>[
      const ExplorePage(),
      const MyBookingsPage(),
      const FavoritesPage(),
      const ConversationsPage(),
      hasOwnerRole
          ? const OwnerDashboardPage()
          : const BecomeOwnerPrompt(),
      const ProfilePage(embedded: true),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: _NeoNavBar(
        index: _index,
        onSelected: (int i) {
          setState(() => _index = i);
          if (i == ShellTab.messages) _refreshBadges();
          ref.read(shellTabProvider.notifier).state = i;
        },
        badges: _badgeCounts,
        ownerTab: hasOwnerRole,
      ),
    );
  }
}

class _NeoNavBar extends StatelessWidget {
  const _NeoNavBar({
    required this.index,
    required this.onSelected,
    required this.badges,
    required this.ownerTab,
  });

  final int index;
  final ValueChanged<int> onSelected;
  final Map<int, int> badges;
  final bool ownerTab;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final S s = L10n.i;

    Widget destination({
      required IconData icon,
      required IconData active,
      required String label,
      required int value,
    }) =>
        NavigationDestination(
          icon: icon == active
              ? Icon(icon)
              : _Badged(icon: icon, count: badges[value] ?? 0),
          selectedIcon: Icon(active),
          label: label,
        );

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: theme.colorScheme.outline)),
      ),
      child: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: onSelected,
        destinations: <Widget>[
          destination(
            icon: Icons.explore_outlined,
            active: Icons.explore_rounded,
            label: s.navExplore,
            value: ShellTab.explore,
          ),
          destination(
            icon: Icons.receipt_long_outlined,
            active: Icons.receipt_long_rounded,
            label: s.navBookings,
            value: ShellTab.bookings,
          ),
          destination(
            icon: Icons.favorite_border_rounded,
            active: Icons.favorite_rounded,
            label: s.navSaved,
            value: ShellTab.saved,
          ),
          destination(
            icon: Icons.chat_bubble_outline_rounded,
            active: Icons.chat_bubble_rounded,
            label: s.navMessages,
            value: ShellTab.messages,
          ),
          destination(
            icon: ownerTab
                ? Icons.storefront_outlined
                : Icons.add_business_outlined,
            active: ownerTab
                ? Icons.storefront_rounded
                : Icons.add_business_rounded,
            label: ownerTab ? s.navMyGear : s.navListGear,
            value: ShellTab.owner,
          ),
          destination(
            icon: Icons.person_outline_rounded,
            active: Icons.person_rounded,
            label: s.navProfile,
            value: ShellTab.profile,
          ),
        ],
      ),
    );
  }
}

class _Badged extends StatelessWidget {
  const _Badged({required this.icon, required this.count});

  final IconData icon;
  final int count;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return Icon(icon);
    return Badge(
      label: Text(count > 99 ? '99+' : '$count'),
      backgroundColor: AppColors.accent,
      textColor: Colors.white,
      child: Icon(icon),
    );
  }
}

/// Shown on the "My gear" tab until the user opts into the OWNER role, which
/// is what unlocks listing creation on the backend.
class BecomeOwnerPrompt extends ConsumerWidget {
  const BecomeOwnerPrompt({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final S s = L10n.i;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            const SizedBox(height: AppSpacing.md),
            Text(s.ownerPromptTitle, style: theme.textTheme.displayMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(
              s.ownerPromptBody,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xl),
            _Benefit(
              icon: Icons.add_photo_alternate_outlined,
              title: s.ownerBenefit1Title,
              body: s.ownerBenefit1Body,
            ),
            _Benefit(
              icon: Icons.calendar_month_rounded,
              title: s.ownerBenefit2Title,
              body: s.ownerBenefit2Body,
            ),
            _Benefit(
              icon: Icons.payments_outlined,
              title: s.ownerBenefit3Title,
              body: s.ownerBenefit3Body,
            ),
            _Benefit(
              icon: Icons.bolt_rounded,
              title: s.ownerBenefit4Title,
              body: s.ownerBenefit4Body,
            ),
            const SizedBox(height: AppSpacing.xl),
            NeoButton(
              label: s.ownerBecomeCta,
              icon: Icons.storefront_rounded,
              onPressed: () async {
                await ref
                    .read(usersRepositoryProvider)
                    .addRole(UserRole.owner);
                await ref.read(sessionProvider.notifier).refreshUser();
                if (context.mounted) {
                  showNeoSnack(context, s.ownerGrantedSnack,
                      icon: Icons.check_circle_outline_rounded);
                }
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              s.ownerFootnote,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _Benefit extends StatelessWidget {
  const _Benefit({required this.icon, required this.title, required this.body});

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: NeoCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
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
          ],
        ),
      ),
    );
  }
}