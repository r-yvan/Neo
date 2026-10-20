import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_locale.dart';
import '../../core/l10n/strings.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/neo_widgets.dart';
import '../../data/models/models.dart';
import '../../data/providers.dart';
import '../common/language_picker.dart';
import '../notifications/notification_settings_page.dart';
import '../reviews/reviews_page.dart';
import '../shell/root_shell.dart';

/// Account hub shown both as a shell tab and as `/home/profile`.
///
/// Everything writes through the API: avatar URL, profile fields, password,
/// national-ID verification and the OWNER role opt-in.
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key, this.embedded = false});

  /// When rendered inside the shell the app bar is owned by [RootShell].
  final bool embedded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SessionState session = ref.watch(sessionProvider);
    final AppUser? user = session.user;
    final S s = L10n.i;
    final ThemeData theme = Theme.of(context);

    if (session.stage == SessionStage.loading) {
      return const Center(child: NeoLoading());
    }
    if (user == null) {
      return Center(
        child: NeoErrorState(message: s.profileNotSignedIn, onRetry: null),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: embedded ? null : AppBar(title: Text(s.profileTitle)),
      body: RefreshIndicator(
        color: AppColors.accent,
        onRefresh: () async {
          try {
            await ref.read(sessionProvider.notifier).refreshUser();
          } on ApiException catch (e) {
            if (context.mounted) showNeoSnack(context, e.message, isError: true);
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            AppSpacing.lg,
            embedded ? AppSpacing.md : 0,
            AppSpacing.lg,
            AppSpacing.xxl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _Header(user: user),
              const SizedBox(height: AppSpacing.lg),
              _AccountCard(user: user),
              const SizedBox(height: AppSpacing.lg),
              const _ActivityCard(),
              const SizedBox(height: AppSpacing.lg),
              const _PreferencesCard(),
              const SizedBox(height: AppSpacing.lg),
              const _SupportCard(),
            ],
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------- header

class _Header extends ConsumerWidget {
  const _Header({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final S s = L10n.i;
    final bool verified = user.isVerified;
    final bool pending = !verified &&
        user.nationalId != null &&
        user.nationalId!.isNotEmpty;
    final bool owner = user.isOwner;

    return NeoCard(
      child: Row(
        children: <Widget>[
          Stack(
            children: <Widget>[
              NeoAvatar(
                initials: user.initials,
                imageUrl: user.profileImage,
                size: 64,
              ),
              Positioned(
                right: -4,
                bottom: -4,
                child: Material(
                  color: AppColors.accent,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => _editAvatar(context, ref),
                    child: const Padding(
                      padding: EdgeInsets.all(5),
                      child: Icon(
                        Icons.camera_alt_outlined,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(user.fullName, style: theme.textTheme.titleLarge),
                Text(user.phone, style: theme.textTheme.bodySmall),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: <Widget>[
                    RatingRow(
                        rating: user.averageRating, reviewCount: 0,
                        showCount: false),
                    const SizedBox(width: AppSpacing.xs),
                    if (verified)
                      NeoBadge(
                        label: s.badgeVerified,
                        tone: BadgeTone.success,
                        icon: Icons.verified_rounded,
                      )
                    else if (pending)
                      NeoBadge(
                        label: s.badgePendingReview,
                        tone: BadgeTone.warning,
                      )
                    else
                      NeoBadge(
                        label: s.badgeUnverified,
                        tone: BadgeTone.warning,
                      ),
                    if (owner) ...<Widget>[
                      const SizedBox(width: 6),
                      NeoBadge(label: s.badgeOwner, tone: BadgeTone.accent),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _editAvatar(BuildContext context, WidgetRef ref) async {
  final S s = L10n.i;
  final TextEditingController url = TextEditingController();
  final String? value = await showNeoSheet<String>(
    context,
    child: Padding(
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
          Text(s.profilePhotoSheetTitle,
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.xs),
          Text(s.profilePhotoSheetHint,
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: AppSpacing.md),
          NeoField(
            label: s.imageFieldLabel,
            controller: url,
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: <Widget>[
              Expanded(
                child: NeoButton(
                  label: s.commonRemove,
                  variant: NeoButtonVariant.ghost,
                  expand: false,
                  onPressed: () => Navigator.of(context).pop('__remove__'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: NeoButton(
                  label: s.commonSave,
                  onPressed: () => Navigator.of(context).pop(url.text.trim()),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
  if (value == null) return;
  final repo = ref.read(usersRepositoryProvider);
  try {
    final AppUser updated =
        value == '__remove__' ? await repo.removeAvatar() : await repo.setAvatar(value);
    ref.read(sessionProvider.notifier).applyUser(updated);
    if (context.mounted) {
      showNeoSnack(context, L10n.i.profilePhotoUpdated, icon: Icons.check_rounded);
    }
  } on ApiException catch (e) {
    if (context.mounted) showNeoSnack(context, e.message, isError: true);
  }
}

// ------------------------------------------------------------- account card

class _AccountCard extends ConsumerWidget {
  const _AccountCard({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S s = L10n.i;
    final bool idVerified =
        user.isVerified || (user.nationalId != null && user.nationalId!.isNotEmpty);
    final String idSubtitle =
        user.isVerified ? s.accountIdVerified : idVerified ? s.accountIdPending : s.accountIdUnlock;

    return NeoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(s.accountTitle, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: AppSpacing.sm),
          _Row(
            icon: Icons.person_outline_rounded,
            title: s.accountEditProfile,
            subtitle: s.accountEditSubtitle,
            onTap: () => _editProfile(context, ref),
          ),
          _Divider(),
          _Row(
            icon: Icons.lock_outline_rounded,
            title: s.accountChangePassword,
            onTap: () => _changePassword(context, ref),
          ),
          const _Divider(),
          _Row(
            icon: idVerified
                ? Icons.verified_rounded
                : Icons.badge_outlined,
            title: s.accountNationalId,
            subtitle: idSubtitle,
            onTap: () => _verifyId(context, ref),
          ),
          if (!user.isOwner) ...<Widget>[
            const _Divider(),
            _Row(
              icon: Icons.storefront_outlined,
              title: s.accountBecomeOwner,
              subtitle: s.accountBecomeOwnerSub,
              onTap: () async {
                try {
                  await ref.read(usersRepositoryProvider).addRole(UserRole.owner);
                  await ref.read(sessionProvider.notifier).refreshUser();
                  if (context.mounted) {
                    showNeoSnack(context, L10n.i.accountOwnerGranted,
                        icon: Icons.check_circle_outline_rounded);
                  }
                } on ApiException catch (e) {
                  if (context.mounted) {
                    showNeoSnack(context, e.message, isError: true);
                  }
                }
              },
            ),
          ],
          const _Divider(),
          _Row(
            icon: Icons.logout_rounded,
            title: s.accountSignOut,
            subtitle: user.phone,
            destructive: true,
            onTap: () async {
              final bool? ok = await confirmNeo(
                context,
                title: s.signOutTitle,
                message: s.signOutMessage,
                confirmLabel: s.accountSignOut,
                destructive: true,
              );
              if (ok != true) return;
              await ref.read(sessionProvider.notifier).signOut();
            },
          ),
        ],
      ),
    );
  }
}

Future<void> _editProfile(BuildContext context, WidgetRef ref) async {
  final S s = L10n.i;
  final AppUser user = ref.read(sessionProvider).user!;
  final TextEditingController name = TextEditingController(text: user.fullName);
  final TextEditingController email =
      TextEditingController(text: user.email ?? '');
  final String? value = await showNeoSheet<String>(
    context,
    child: Padding(
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
          Text(s.editProfileSheetTitle,
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.md),
          NeoField(label: s.fieldFullName, controller: name),
          const SizedBox(height: AppSpacing.sm),
          NeoField(
            label: s.fieldEmailOptional,
            controller: email,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: AppSpacing.md),
          NeoButton(
            label: s.commonSave,
            onPressed: () => Navigator.of(context).pop(true.toString()),
          ),
        ],
      ),
    ),
  );
  if (value == null) return;
  try {
    final AppUser updated = await ref
        .read(usersRepositoryProvider)
        .updateProfile(fullName: name.text.trim(), email: email.text.trim());
    ref.read(sessionProvider.notifier).applyUser(updated);
    if (context.mounted) {
      showNeoSnack(context, L10n.i.profileSavedSnack, icon: Icons.check_rounded);
    }
  } on ApiException catch (e) {
    if (context.mounted) showNeoSnack(context, e.message, isError: true);
  }
}

class _PasswordForm extends ConsumerStatefulWidget {
  @override
  ConsumerState<_PasswordForm> createState() => _PasswordFormState();
}

class _PasswordFormState extends ConsumerState<_PasswordForm> {
  final TextEditingController _current = TextEditingController();
  final TextEditingController _next = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_current.text.isEmpty || _next.text.length < 8) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(usersRepositoryProvider)
          .changePassword(
            currentPassword: _current.text,
            newPassword: _next.text,
          );
      if (mounted) Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        showNeoSnack(context, e.message, isError: true);
      }
    }
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
          Text(L10n.i.passwordSheetTitle,
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.md),
          NeoField(
            label: L10n.i.fieldCurrentPassword,
            controller: _current,
            obscure: true,
          ),
          const SizedBox(height: AppSpacing.sm),
          NeoField(
            label: L10n.i.fieldNewPassword,
            controller: _next,
            obscure: true,
          ),
          const SizedBox(height: AppSpacing.md),
          NeoButton(
            label: _busy ? L10n.i.commonSaving : L10n.i.commonSave,
            loading: _busy,
            onPressed: _busy ? null : _submit,
          ),
        ],
      ),
    );
  }
}

Future<void> _changePassword(BuildContext context, WidgetRef ref) async {
  final bool? done = await showNeoSheet<bool>(
    context,
    scrollable: true,
    child: _PasswordForm(),
  );
  if (done != true) return;
  if (context.mounted) {
    showNeoSnack(context, L10n.i.passwordUpdatedSnack, icon: Icons.lock_rounded);
  }
}

Future<void> _verifyId(BuildContext context, WidgetRef ref) async {
  final S s = L10n.i;
  final AppUser user = ref.read(sessionProvider).user!;
  if (user.isVerified) {
    showNeoSnack(context, s.idVerifiedSnack, icon: Icons.verified_rounded);
    return;
  }
  if (user.nationalId != null && user.nationalId!.isNotEmpty) {
    showNeoSnack(context, s.idWaitingSnack,
        icon: Icons.hourglass_top_rounded);
    return;
  }
  final TextEditingController id =
      TextEditingController(text: user.nationalId ?? '');
  final String? value = await showNeoSheet<String>(
    context,
    child: Padding(
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
          Text(s.idSheetTitle,
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.xs),
          Text(s.idSheetHint,
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: AppSpacing.md),
          NeoField(
            label: s.fieldNationalId,
            controller: id,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: AppSpacing.md),
          NeoButton(
            label: s.commonSubmit,
            onPressed: () => Navigator.of(context).pop(id.text.trim()),
          ),
        ],
      ),
    ),
  );
  if (value == null || value.isEmpty) return;
  try {
    final AppUser updated = await ref.read(usersRepositoryProvider).submitNationalId(value);
    ref.read(sessionProvider.notifier).applyUser(updated);
    if (context.mounted) {
      showNeoSnack(context, L10n.i.idSubmittedSnack,
          icon: Icons.hourglass_top_rounded);
    }
  } on ApiException catch (e) {
    if (context.mounted) showNeoSnack(context, e.message, isError: true);
  }
}

// ------------------------------------------------------------ activity card

class _ActivityCard extends StatelessWidget {
  const _ActivityCard();

  @override
  Widget build(BuildContext context) {
    final S s = L10n.i;
    final shell = context;
    return NeoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(s.actSectionTitle, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: AppSpacing.sm),
          _Row(
            icon: Icons.receipt_long_outlined,
            title: s.actMyBookings,
            onTap: () => openShellTab(shell, ShellTab.bookings),
          ),
          const _Divider(),
          _Row(
            icon: Icons.favorite_outline_rounded,
            title: s.actSavedListings,
            onTap: () => openShellTab(shell, ShellTab.saved),
          ),
          const _Divider(),
          _Row(
            icon: Icons.storefront_outlined,
            title: s.actOwnerDashboard,
            onTap: () => openShellTab(shell, ShellTab.owner),
          ),
          const _Divider(),
          _Row(
            icon: Icons.reviews_rounded,
            title: s.actMyReviews,
            onTap: () => Navigator.of(context).push<void>(
              MaterialPageRoute<void>(
                builder: (BuildContext _) => const ReviewsPage(mine: true),
              ),
            ),
          ),
          const _Divider(),
          _Row(
            icon: Icons.notifications_none_rounded,
            title: s.actNotifications,
            onTap: () async {
              await Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (BuildContext _) => const NotificationSettingsPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------- preferences card

class _PreferencesCard extends ConsumerWidget {
  const _PreferencesCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S s = L10n.i;
    final ThemeMode mode = ref.watch(themeModeProvider);
    final AppLocaleChoice language = ref.watch(languageProvider);
    final String label = switch (mode) {
      ThemeMode.light => s.prefsAppearanceLight,
      ThemeMode.dark => s.prefsAppearanceDark,
      ThemeMode.system => s.prefsFollowSystem,
    };

    return NeoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(s.prefsSectionTitle,
              style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: AppSpacing.sm),
          _Row(
            icon: Icons.contrast_rounded,
            title: s.prefsAppearance,
            subtitle: label,
            onTap: () async {
              final ThemeMode? picked = await showNeoSheet<ThemeMode>(
                context,
                child: Padding(
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
                      Text(s.prefsAppearance,
                          style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: AppSpacing.md),
                      for (final ThemeMode m in ThemeMode.values) ...<Widget>[
                        NeoButton(
                          label: switch (m) {
                            ThemeMode.light => s.prefsAppearanceLight,
                            ThemeMode.dark => s.prefsAppearanceDark,
                            ThemeMode.system => s.prefsFollowSystem,
                          },
                          variant: m == mode
                              ? NeoButtonVariant.primary
                              : NeoButtonVariant.secondary,
                          onPressed: () => Navigator.of(context).pop(m),
                          icon: m == ThemeMode.dark
                              ? Icons.dark_mode_rounded
                              : m == ThemeMode.light
                                  ? Icons.light_mode_rounded
                                  : Icons.brightness_auto_rounded,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                      ],
                    ],
                  ),
                ),
              );
              if (picked != null) {
                ref.read(themeModeProvider.notifier).set(picked);
              }
            },
          ),
          _Divider(),
          _Row(
            icon: Icons.translate_rounded,
            title: s.prefsLanguage,
            subtitle: languageName(language, s),
            onTap: () => showLanguageSheet(context, ref),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------- support card

class _SupportCard extends ConsumerWidget {
  const _SupportCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PlatformConfig config = ref.watch(platformConfigProvider).valueOrNull ??
        const PlatformConfig.fallback();
    final S s = L10n.i;
    final ThemeData theme = Theme.of(context);

    return NeoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(s.supportSectionTitle, style: theme.textTheme.titleSmall),
          const SizedBox(height: AppSpacing.xs),
          Text(
            s.supportIntro,
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          if (config.supportPhone != null)
            _Row(
              icon: Icons.call_outlined,
              title: s.supportCall,
              subtitle: config.supportPhone,
              onTap: () => showNeoSnack(
                  context, s.supportDial(config.supportPhone!),
                  icon: Icons.call_rounded),
            ),
          const _Divider(),
          if (config.supportEmail != null)
            _Row(
              icon: Icons.mail_outline_rounded,
              title: s.supportEmail,
              subtitle: config.supportEmail,
              onTap: () => showNeoSnack(
                  context, s.supportWrite(config.supportEmail!),
                  icon: Icons.mail_rounded),
            ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------------- shared

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color? color = destructive ? AppColors.danger : null;

    return InkWell(
      borderRadius: AppRadii.smAll,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: <Widget>[
            Icon(icon, size: 20, color: color ?? theme.colorScheme.onSurface),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge!
                        .copyWith(color: color, fontWeight: FontWeight.w600),
                  ),
                  if (subtitle != null) Text(subtitle!, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 20, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Divider(height: 1, color: Theme.of(context).colorScheme.outline);
  }
}
