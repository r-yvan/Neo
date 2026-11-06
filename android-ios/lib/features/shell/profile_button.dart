import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/neo_widgets.dart';
import '../../data/models/models.dart';
import '../../data/providers.dart';
import '../profile/profile_page.dart';

/// Opens the profile screen on top of the shell.
void openProfile(BuildContext context) => Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (BuildContext _) => const ProfilePage()),
    );

/// The signed-in user's avatar, shown at the top-right of every main tab.
/// Profile is no longer a tab, so this is how every role reaches it.
class ProfileAvatarButton extends ConsumerWidget {
  const ProfileAvatarButton({super.key, this.size = 44});

  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppUser? user = ref.watch(sessionProvider).user;
    final ThemeData theme = Theme.of(context);
    return Tooltip(
      message: L10n.i.navProfile,
      child: Semantics(
        button: true,
        label: L10n.i.navProfile,
        child: Material(
          color: theme.colorScheme.surface,
          shape: CircleBorder(
            side: BorderSide(color: theme.colorScheme.outline, width: 1.2),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => openProfile(context),
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  NeoAvatar(
                    initials: user?.initials ?? '?',
                    imageUrl: user?.profileImage,
                    size: size - 6,
                  ),
                  if (user?.isAdmin ?? false)
                    Positioned(
                      right: -1,
                      bottom: -1,
                      child: Container(
                        width: 13,
                        height: 13,
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: theme.colorScheme.surface, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
