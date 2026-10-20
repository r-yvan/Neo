import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/neo_widgets.dart';
import '../../data/providers.dart';
import '../common/language_picker.dart';
import '../splash/splash_page.dart';

/// Three-screen value proposition shown once on first launch.
///
/// Each slide pairs an illustrative gradient panel with one concrete promise,
/// ending on the category preview so the value of the catalogue is obvious
/// before the user even signs in.
class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final PageController _controller = PageController();
  int _index = 0;

  List<_Slide> _slides(S s) => <_Slide>[
        _Slide(
          eyebrow: s.onbRentEyebrow,
          title: s.onbRentTitle,
          body: s.onbRentBody,
          glyph: Icons.event_seat_rounded,
        ),
        _Slide(
          eyebrow: s.onbTrustEyebrow,
          title: s.onbTrustTitle,
          body: s.onbTrustBody,
          glyph: Icons.payments_rounded,
        ),
        _Slide(
          eyebrow: s.onbEarnEyebrow,
          title: s.onbEarnTitle,
          body: s.onbEarnBody,
          glyph: Icons.trending_up_rounded,
        ),
      ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await ref.read(sessionProvider.notifier).completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final S s = L10n.i;
    final List<_Slide> slides = _slides(s);
    final bool isLast = _index == slides.length - 1;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Row(
                children: [
                  const LanguagePill(),
                  const Spacer(),
                  TextButton(
                    onPressed: _finish,
                    child: Text(s.commonSkip),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: slides.length,
                onPageChanged: (int i) => setState(() => _index = i),
                itemBuilder: (BuildContext context, int i) => _SlideView(
                  slide: slides[i],
                  index: i,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.xl,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List<Widget>.generate(slides.length, (int i) {
                      final bool active = i == _index;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 240),
                        curve: Curves.easeOut,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: active ? 26 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: active
                              ? AppColors.accent
                              : theme.colorScheme.outline,
                          borderRadius: AppRadii.pillAll,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  NeoButton(
                    label: isLast ? s.onbGetStarted : s.commonContinue,
                    icon: isLast ? null : Icons.arrow_forward_rounded,
                    onPressed: () {
                      if (isLast) {
                        _finish();
                      } else {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 320),
                          curve: Curves.easeOutCubic,
                        );
                      }
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    s.onbFootnote,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Slide {
  const _Slide({
    required this.eyebrow,
    required this.title,
    required this.body,
    required this.glyph,
  });

  final String eyebrow;
  final String title;
  final String body;
  final IconData glyph;
}

class _SlideView extends StatelessWidget {
  const _SlideView({required this.slide, required this.index});

  final _Slide slide;
  final int index;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(flex: 2),
          _Illustration(glyph: slide.glyph, index: index),
          const Spacer(flex: 2),
          NeoBadge(label: slide.eyebrow.toUpperCase(), tone: BadgeTone.accent),
          const SizedBox(height: AppSpacing.sm),
          Text(slide.title, style: theme.textTheme.displayMedium),
          const SizedBox(height: AppSpacing.sm),
          Text(slide.body, style: theme.textTheme.bodyLarge),
          const Spacer(),
        ],
      ),
    );
  }
}

/// Abstract artwork: concentric accent rings with the slide glyph in the
/// middle and a floating category chip, so the panel reads as product UI
/// rather than stock photography.
class _Illustration extends StatelessWidget {
  const _Illustration({required this.glyph, required this.index});

  final IconData glyph;
  final int index;

  List<(IconData, String)> _chips(S s) => <(IconData, String)>[
        (Icons.event_seat_rounded, s.chipChairs),
        (Icons.holiday_village_rounded, s.chipTents),
        (Icons.speaker_rounded, s.chipSound),
        (Icons.table_restaurant_rounded, s.chipTables),
        (Icons.electric_bolt_rounded, s.chipPower),
        (Icons.auto_awesome_rounded, s.chipDecor),
      ];

  @override
  Widget build(BuildContext context) {
    final S s = L10n.i;
    final (IconData chipIcon, String chipLabel) = _chips(s)[index % 6];
    return SizedBox(
      height: 260,
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (final double factor in <double>[1.0, 0.76, 0.52])
            Container(
              width: 240 * factor,
              height: 240 * factor,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent.withValues(alpha: 0.05 + 0.03 * factor),
              ),
            ),
          Container(
            width: 108,
            height: 108,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.accent, Color(0xFFFF9C8A)],
              ),
              shape: BoxShape.circle,
              boxShadow: AppShadows.accent,
            ),
            child: Icon(glyph, size: 46, color: Colors.white),
          ),
          Positioned(
            right: 8,
            top: 26,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: AppRadii.mdAll,
                border: Border.all(color: Theme.of(context).colorScheme.outline),
                boxShadow: AppShadows.card,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(chipIcon, size: 16, color: AppColors.accent),
                  const SizedBox(width: 6),
                  Text(chipLabel, style: AppTypography.labelMedium),
                ],
              ),
            ),
          ),
          Positioned(
            left: 4,
            bottom: 34,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: AppRadii.mdAll,
                border: Border.all(color: Theme.of(context).colorScheme.outline),
                boxShadow: AppShadows.card,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.bolt_rounded, size: 16, color: AppColors.accent),
                  const SizedBox(width: 6),
                  Text(s.chipTopRated, style: AppTypography.labelMedium),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}