import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_locale.dart';
import '../../core/l10n/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/neo_widgets.dart';
import '../../data/providers.dart';

/// Display name of a language choice, always shown in its own language.
String languageName(AppLocaleChoice choice, S s) => switch (choice) {
      AppLocaleChoice.system => s.languageSystem,
      AppLocaleChoice.english => 'English',
      AppLocaleChoice.kinyarwanda => 'Kinyarwanda',
    };

/// Bottom sheet for choosing the app language.
///
/// Writes through [languageProvider] — the MaterialApp (and therefore every
/// screen) repaints on change because the provider is watched in [NeoApp].
Future<void> showLanguageSheet(BuildContext context, WidgetRef ref) {
  return showNeoSheet<void>(
    context,
    child: Consumer(
      builder: (BuildContext context, WidgetRef sheetRef, _) {
        final AppLocaleChoice selected = sheetRef.watch(languageProvider);
        final S s = L10n.i;
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
              Text(s.languageSheetTitle,
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: AppSpacing.xs),
              Text(
                s.languageNavHint,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpacing.md),
              for (final AppLocaleChoice choice in AppLocaleChoice.values) ...<Widget>[
                NeoButton(
                  label: languageName(choice, s),
                  variant: choice == selected
                      ? NeoButtonVariant.primary
                      : NeoButtonVariant.secondary,
                  onPressed: () {
                    sheetRef.read(languageProvider.notifier).set(choice);
                  },
                  icon: switch (choice) {
                    AppLocaleChoice.system => Icons.brightness_auto_rounded,
                    AppLocaleChoice.english => Icons.language_rounded,
                    AppLocaleChoice.kinyarwanda => Icons.translate_rounded,
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
            ],
          ),
        );
      },
    ),
  );
}

/// Small pill that opens the language sheet — used on onboarding.
class LanguagePill extends ConsumerWidget {
  const LanguagePill({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocaleChoice choice = ref.watch(languageProvider);
    final S s = L10n.i;
    return ActionChip(
      avatar: const Icon(Icons.translate_rounded, size: 16,
          color: AppColors.accent),
      label: Text(
        switch (choice) {
          AppLocaleChoice.system => s.languageSystem,
          AppLocaleChoice.english => 'English',
          AppLocaleChoice.kinyarwanda => 'Kinyarwanda',
        },
        style: AppTypography.labelLarge,
      ),
      side: BorderSide(color: Theme.of(context).colorScheme.outline),
      backgroundColor: Theme.of(context).colorScheme.surface,
      onPressed: () => showLanguageSheet(context, ref),
    );
  }
}
