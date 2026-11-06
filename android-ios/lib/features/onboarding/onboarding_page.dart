import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/illustrations/neo_illustration.dart';
import '../../core/widgets/neo_widgets.dart';
import '../../data/providers.dart';
import '../common/language_picker.dart';

/// Three-screen value proposition shown once on first launch.
///
/// Each slide pairs an animated vector scene with one concrete promise:
/// rent for your event, pay safely with mobile money, earn from your gear.
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
          art: IllustrationKind.rent,
        ),
        _Slide(
          eyebrow: s.onbTrustEyebrow,
          title: s.onbTrustTitle,
          body: s.onbTrustBody,
          art: IllustrationKind.pay,
        ),
        _Slide(
          eyebrow: s.onbEarnEyebrow,
          title: s.onbEarnTitle,
          body: s.onbEarnBody,
          art: IllustrationKind.earn,
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
    required this.art,
  });

  final String eyebrow;
  final String title;
  final String body;
  final IllustrationKind art;
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
          const SizedBox(height: AppSpacing.md),
          Expanded(
            flex: 6,
            child: NeoIllustration(kind: slide.art, height: double.infinity),
          ),
          const SizedBox(height: AppSpacing.lg),
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
