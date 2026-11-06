import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// Pin size; markers are anchored so the tail tip sits on the coordinate.
const double kPinWidth = 50;
const double kPinHeight = 60;

/// Teardrop pin. Lenders are coral (the brand accent); borrowers are graphite
/// so the two layers read apart at a glance without a second colour.
class MapPin extends StatelessWidget {
  const MapPin({
    super.key,
    required this.lender,
    required this.selected,
    this.count = 0,
  });

  final bool lender;
  final bool selected;

  /// Listing count badge (lenders with more than one listing).
  final int count;

  @override
  Widget build(BuildContext context) {
    final Color fill = lender ? AppColors.accent : AppColors.grey800;
    return AnimatedScale(
      scale: selected ? 1.18 : 1,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutBack,
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        width: kPinWidth,
        height: kPinHeight,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: <Widget>[
            Positioned(
              top: 2,
              child: CustomPaint(
                size: const Size(40, 54),
                painter: _TeardropPainter(
                  fill: fill,
                  ring: selected ? fill : Colors.white,
                  halo: selected,
                ),
              ),
            ),
            Positioned(
              top: 10,
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: selected ? Colors.white : Colors.white.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  lender ? Icons.storefront_rounded : Icons.person_search_rounded,
                  size: 16,
                  color: selected ? fill : Colors.white,
                ),
              ),
            ),
            if (count > 1)
              Positioned(
                top: -2,
                right: 2,
                child: Container(
                  constraints: const BoxConstraints(minWidth: 19),
                  height: 19,
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppRadii.pillAll,
                    border: Border.all(color: fill, width: 1.5),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontFamily: kFontFamily,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: fill,
                      height: 1,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TeardropPainter extends CustomPainter {
  _TeardropPainter({required this.fill, required this.ring, required this.halo});

  final Color fill;
  final Color ring;
  final bool halo;

  @override
  void paint(Canvas canvas, Size size) {
    final double r = size.width / 2;
    final Offset c = Offset(r, r);
    final Path path = Path()
      ..moveTo(r, size.height - 4)
      ..cubicTo(r - 4, size.height - 14, 0, r + 12, 0, r)
      ..arcToPoint(Offset(size.width, r), radius: Radius.circular(r))
      ..cubicTo(size.width, r + 12, r + 4, size.height - 14, r, size.height - 4)
      ..close();

    // Ground shadow + drop shadow.
    canvas.drawOval(
      Rect.fromCenter(center: Offset(r, size.height - 2), width: 14, height: 5),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
    canvas.drawPath(
      path.shift(const Offset(0, 2)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    if (halo) {
      canvas.drawCircle(c, r + 6, Paint()..color = fill.withValues(alpha: 0.22));
    }
    canvas.drawPath(path, Paint()..color = fill);
    canvas.drawPath(
      path,
      Paint()
        ..color = ring
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
  }

  @override
  bool shouldRepaint(covariant _TeardropPainter old) =>
      old.fill != fill || old.ring != ring || old.halo != halo;
}

/// Pulsing "you are here" dot.
class MeMarker extends StatefulWidget {
  const MeMarker({super.key});

  @override
  State<MeMarker> createState() => _MeMarkerState();
}

class _MeMarkerState extends State<MeMarker> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))
        ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (BuildContext context, Widget? _) {
        final double v = Curves.easeOut.transform(_c.value);
        return Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Container(
              width: 18 + 34 * v,
              height: 18 + 34 * v,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent.withValues(alpha: 0.28 * (1 - v)),
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: const <BoxShadow>[
                  BoxShadow(color: Color(0x40000000), blurRadius: 6, offset: Offset(0, 2)),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
