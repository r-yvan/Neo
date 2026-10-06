import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Shown for the single frame while the stored session is validated.
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey900,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BrandMark(size: 64),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'NEO',
              style: AppTypography.displayMedium.copyWith(
                color: Colors.white,
                letterSpacing: 6,
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              'Event equipment, ready when you are',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.grey400),
            ),
          ],
        ),
      ),
    );
  }
}

/// The Neo glyph: three stacked rounded bars inside an accent-tinted tile.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 48});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.accent, Color(0xFF5AB0FF)],
        ),
        borderRadius: BorderRadius.circular(size * 0.3),
        boxShadow: AppShadows.accent,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _bar(size * 0.42, size * 0.075),
            SizedBox(height: size * 0.075),
            _bar(size * 0.30, size * 0.075),
            SizedBox(height: size * 0.075),
            _bar(size * 0.18, size * 0.075),
          ],
        ),
      ),
    );
  }

  Widget _bar(double width, double height) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(height),
        ),
      );
}