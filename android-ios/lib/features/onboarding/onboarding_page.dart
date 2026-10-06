import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/neo_widgets.dart';
import '../../data/providers.dart';
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

  static const List<_Slide> _slides = <_Slide>[
    _Slide(
      eyebrow: 'Rent anything',
      title: 'Every event starts\nwith equipment',
      body:
          'Chairs, tables, tents, sound, power and decor — from verified owners across Kigali and beyond.',
      glyph: Icons.event_seat_rounded,
    ),
    _Slide(
      eyebrow: 'Book with confidence',
      title: 'Clear prices.\nNo surprises.',
      body:
          'See the daily rate, the deposit and the exact total before you pay. Pay with MTN MoMo or Airtel Money.',
      glyph: Icons.payments_rounded,
    ),
    _Slide(
      eyebrow: 'Earn from your gear',
      title: 'Your idle chairs\nshould pay rent',
      body:
          'List your equipment in minutes, accept the bookings you want, and get paid straight to your mobile money.',
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
    final bool isLast = _index == _slides.length - 1;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _finish,
                child: const Text('Skip'),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (int i) => setState(() => _index = i),
                itemBuilder: (BuildContext context, int i) => _SlideView(
                  slide: _slides[i],
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
                    children: List<Widget>.generate(_slides.length, (int i) {
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
                    label: isLast ? 'Get started' : 'Continue',
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
                    'Free to browse · 10% platform fee only on completed rentals',
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

  static const List<(IconData, String)> _chips = <(IconData, String)>[
    (Icons.event_seat_rounded, 'Chairs'),
    (Icons.holiday_village_rounded, 'Tents'),
    (Icons.speaker_rounded, 'Sound'),
    (Icons.table_restaurant_rounded, 'Tables'),
    (Icons.electric_bolt_rounded, 'Power'),
    (Icons.auto_awesome_rounded, 'Decor'),
  ];

  @override
  Widget build(BuildContext context) {
    final (IconData chipIcon, String chipLabel) = _chips[index % _chips.length];
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
                colors: [AppColors.accent, Color(0xFF6FB8FF)],
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
                  Text('Top rated', style: AppTypography.labelMedium),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}