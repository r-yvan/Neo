import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_config.dart';
import '../../core/l10n/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/neo_widgets.dart';
import '../../data/models/models.dart';
import '../../data/providers.dart';
import '../bookings/my_bookings_page.dart';
import '../chat/conversations_page.dart';
import '../home/explore_page.dart';
import '../owner/owner_dashboard_page.dart';
import 'profile_button.dart';

/// Tab state survives tab switches via [IndexedStack].
///
/// The tab index is lifted into a provider so a deep action (e.g. "open my
/// bookings" from a notification or the profile screen) can drive navigation.
final StateProvider<int> shellTabProvider = StateProvider<int>((Ref ref) => 0);

/// Switches the shell to a tab. Safe to call from anywhere, including a page
/// pushed on top of the shell (pop back to the shell first).
void openShellTab(BuildContext context, int index) {
  ProviderScope.containerOf(context, listen: false)
      .read(shellTabProvider.notifier)
      .state = index;
}

/// The four tabs, identical for every role (renter, owner, admin).
/// Profile lives behind the avatar at the top of each tab; Saved lives inside
/// Profile; the admin console is reached from Profile.
abstract final class ShellTab {
  static const int explore = 0;
  static const int bookings = 1;
  static const int messages = 2;
  static const int owner = 3;
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

  /// Unread chat count for the Chat tab. Failures are silent: a badge is a
  /// hint, never a blocker.
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
      if (next != _index && next >= 0 && next <= ShellTab.owner) {
        setState(() => _index = next);
      }
    });

    final bool hasOwnerRole =
        ref.watch(sessionProvider).user?.isOwner ?? false;

    final List<Widget> pages = <Widget>[
      const ExplorePage(),
      const MyBookingsPage(),
      const ConversationsPage(),
      hasOwnerRole ? const OwnerDashboardPage() : const BecomeOwnerPrompt(),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: _FloatingNavBar(
        index: _index,
        onSelected: (int i) {
          if (i != _index) HapticFeedback.selectionClick();
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

/// Suspended, fully rounded tab bar that floats above the content and the
/// system gesture area.
class _FloatingNavBar extends StatelessWidget {
  const _FloatingNavBar({
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
    final bool dark = theme.brightness == Brightness.dark;
    final S s = L10n.i;

    final List<_NavSpec> items = <_NavSpec>[
      _NavSpec(Icons.explore_outlined, Icons.explore_rounded, s.navExplore),
      _NavSpec(Icons.receipt_long_outlined, Icons.receipt_long_rounded,
          s.navBookings),
      _NavSpec(Icons.chat_bubble_outline_rounded, Icons.chat_bubble_rounded,
          s.navMessages),
      _NavSpec(
        ownerTab ? Icons.storefront_outlined : Icons.add_business_outlined,
        ownerTab ? Icons.storefront_rounded : Icons.add_business_rounded,
        ownerTab ? s.navMyGear : s.navListGear,
      ),
    ];

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
        child: Container(
          height: 68,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: dark ? AppColors.darkSurfaceRaised : Colors.white,
            borderRadius: AppRadii.pillAll,
            border: Border.all(
              color: dark
                  ? AppColors.darkBorder
                  : theme.colorScheme.outline.withValues(alpha: 0.7),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: dark ? 0.45 : 0.12),
                blurRadius: 28,
                offset: const Offset(0, 12),
                spreadRadius: -8,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: dark ? 0.3 : 0.05),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: <Widget>[
              for (int i = 0; i < items.length; i++)
                Expanded(
                  child: _NavItem(
                    spec: items[i],
                    selected: i == index,
                    badge: badges[i] ?? 0,
                    onTap: () => onSelected(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavSpec {
  const _NavSpec(this.icon, this.activeIcon, this.label);

  final IconData icon;
  final IconData activeIcon;
  final String label;
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.spec,
    required this.selected,
    required this.badge,
    required this.onTap,
  });

  final _NavSpec spec;
  final bool selected;
  final int badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color fg =
        selected ? Colors.white : theme.colorScheme.onSurfaceVariant;

    Widget icon = Icon(selected ? spec.activeIcon : spec.icon, size: 22, color: fg);
    if (badge > 0) {
      icon = Badge(
        label: Text(badge > 99 ? '99+' : '$badge'),
        backgroundColor: selected ? Colors.white : AppColors.accent,
        textColor: selected ? AppColors.accent : Colors.white,
        child: icon,
      );
    }

    return Semantics(
      selected: selected,
      button: true,
      label: spec.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: selected ? AppColors.accent : Colors.transparent,
            borderRadius: AppRadii.pillAll,
            boxShadow: selected ? AppShadows.accent : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              icon,
              const SizedBox(height: 3),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    spec.label,
                    maxLines: 1,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: fg,
                      fontSize: 11,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      height: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.xl),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Text(s.ownerPromptTitle,
                      style: theme.textTheme.displayMedium),
                ),
                const SizedBox(width: AppSpacing.sm),
                const ProfileAvatarButton(),
              ],
            ),
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