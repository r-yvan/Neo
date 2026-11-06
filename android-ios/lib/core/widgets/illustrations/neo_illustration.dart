/// Animated vector illustrations used on onboarding and auth screens.
///
/// Everything is drawn with [CustomPainter] — no image or Lottie assets — so
/// the scenes stay crisp at any density, follow light/dark theme, weigh
/// nothing in the bundle and use only the brand palette (one accent + greys).
///
/// Each scene is designed on a 320×240 artboard and scaled to fit. All motion
/// is driven by one looping controller value `t ∈ [0, 1)`; every periodic term
/// uses an integer frequency so the loop is seamless.
library;

import 'dart:math' as math;
import 'dart:ui' show Tangent;

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

part 'scenes_onboarding.dart';
part 'scenes_auth.dart';

enum IllustrationKind {
  /// Onboarding 1 — a decorated event tent with chairs and string lights.
  rent,

  /// Onboarding 2 — mobile-money payment protected by escrow.
  pay,

  /// Onboarding 3 — owners' earnings growing.
  earn,

  /// Sign in — a phone unlocking with floating category chips.
  signIn,

  /// Register — an ID card being filled in and verified.
  register,

  /// OTP — an SMS code flying to the phone.
  otp,

  /// Forgot / reset password — a key opening a padlock.
  reset,
}

class NeoIllustration extends StatefulWidget {
  const NeoIllustration({
    super.key,
    required this.kind,
    this.height = 240,
  });

  final IllustrationKind kind;
  final double height;

  @override
  State<NeoIllustration> createState() => _NeoIllustrationState();
}

class _NeoIllustrationState extends State<NeoIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: _durationFor(widget.kind));

  static Duration _durationFor(IllustrationKind kind) => switch (kind) {
        IllustrationKind.rent => const Duration(seconds: 6),
        IllustrationKind.pay => const Duration(milliseconds: 4200),
        IllustrationKind.earn => const Duration(seconds: 5),
        IllustrationKind.signIn => const Duration(milliseconds: 4800),
        IllustrationKind.register => const Duration(milliseconds: 4800),
        IllustrationKind.otp => const Duration(milliseconds: 4200),
        IllustrationKind.reset => const Duration(milliseconds: 4600),
      };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Honour the OS "reduce motion" setting with a pleasant still frame.
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      _controller
        ..stop()
        ..value = 0.55;
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant NeoIllustration oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.kind != widget.kind) {
      _controller.duration = _durationFor(widget.kind);
      if (_controller.isAnimating) _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _Palette palette = _Palette.of(Theme.of(context));
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (BuildContext context, Widget? _) => CustomPaint(
            painter: _ScenePainter(widget.kind, _controller.value, palette),
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------ palette

@immutable
class _Palette {
  const _Palette({
    required this.dark,
    required this.surface,
    required this.raised,
    required this.outline,
    required this.ink,
    required this.inkSoft,
    required this.muted,
    required this.faint,
    required this.blob,
  });

  factory _Palette.of(ThemeData theme) {
    final bool dark = theme.brightness == Brightness.dark;
    return _Palette(
      dark: dark,
      surface: dark ? AppColors.darkSurface : Colors.white,
      raised: dark ? AppColors.darkSurfaceRaised : AppColors.grey50,
      outline: dark ? AppColors.darkBorder : AppColors.grey200,
      ink: dark ? AppColors.grey100 : AppColors.grey900,
      inkSoft: dark ? AppColors.grey300 : AppColors.grey700,
      muted: dark ? AppColors.grey600 : AppColors.grey300,
      faint: dark ? AppColors.grey800 : AppColors.grey150,
      blob: AppColors.accent.withValues(alpha: dark ? 0.12 : 0.08),
    );
  }

  final bool dark;
  final Color surface;
  final Color raised;
  final Color outline;
  final Color ink;
  final Color inkSoft;
  final Color muted;
  final Color faint;
  final Color blob;

  static const Color accent = AppColors.accent;
  static const Color accentLight = Color(0xFFFF9C8A);
  static const Color accentDeep = AppColors.accentPressed;
  static const Color gold = Color(0xFFF5B83D);
  static const Color goldDeep = Color(0xFFD9962A);

  @override
  bool operator ==(Object other) =>
      other is _Palette && other.dark == dark;

  @override
  int get hashCode => dark.hashCode;
}

// ------------------------------------------------------------------ painter

class _ScenePainter extends CustomPainter {
  _ScenePainter(this.kind, this.t, this.p);

  final IllustrationKind kind;
  final double t;
  final _Palette p;

  static const Size artboard = Size(320, 240);

  @override
  void paint(Canvas canvas, Size size) {
    final double scale = math.min(
      size.width / artboard.width,
      size.height / artboard.height,
    );
    canvas
      ..save()
      ..translate(
        (size.width - artboard.width * scale) / 2,
        (size.height - artboard.height * scale) / 2,
      )
      ..scale(scale);

    switch (kind) {
      case IllustrationKind.rent:
        _paintRent(canvas, t, p);
      case IllustrationKind.pay:
        _paintPay(canvas, t, p);
      case IllustrationKind.earn:
        _paintEarn(canvas, t, p);
      case IllustrationKind.signIn:
        _paintSignIn(canvas, t, p);
      case IllustrationKind.register:
        _paintRegister(canvas, t, p);
      case IllustrationKind.otp:
        _paintOtp(canvas, t, p);
      case IllustrationKind.reset:
        _paintReset(canvas, t, p);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ScenePainter old) =>
      old.t != t || old.kind != kind || old.p != p;
}

// ------------------------------------------------------------ shared helpers

const double _tau = math.pi * 2;

/// Seamless periodic wave in [-1, 1].
double _wave(double t, {int freq = 1, double phase = 0}) =>
    math.sin(_tau * (t * freq + phase));

double _clamp01(double v) => v < 0 ? 0 : (v > 1 ? 1 : v);

/// Maps `t` within [start, end] to [0, 1].
double _seg(double t, double start, double end) =>
    _clamp01((t - start) / (end - start));

double _easeOut(double v) => 1 - math.pow(1 - v, 3).toDouble();
double _easeInOut(double v) =>
    v < 0.5 ? 4 * v * v * v : 1 - math.pow(-2 * v + 2, 3).toDouble() / 2;
double _easeOutBack(double v) {
  const double c1 = 1.70158;
  const double c3 = c1 + 1;
  return 1 + c3 * math.pow(v - 1, 3) + c1 * math.pow(v - 1, 2);
}

Paint _fill(Color c) => Paint()
  ..color = c
  ..isAntiAlias = true;

Paint _stroke(Color c, double w, {StrokeCap cap = StrokeCap.round}) => Paint()
  ..color = c
  ..style = PaintingStyle.stroke
  ..strokeWidth = w
  ..strokeCap = cap
  ..strokeJoin = StrokeJoin.round
  ..isAntiAlias = true;

/// Soft drop shadow under a shape.
void _shadow(Canvas canvas, Path path, {double blur = 14, double dy = 8, double alpha = 0.10}) {
  canvas.drawPath(
    path.shift(Offset(0, dy)),
    Paint()
      ..color = Colors.black.withValues(alpha: alpha)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur / 2),
  );
}

void _groundShadow(Canvas canvas, Offset c, double w, {double alpha = 0.08}) {
  canvas.drawOval(
    Rect.fromCenter(center: c, width: w, height: w * 0.08),
    Paint()
      ..color = Colors.black.withValues(alpha: alpha)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
  );
}

/// An organic, slowly breathing backdrop shape — the replacement for the old
/// concentric circles.
void _blob(Canvas canvas, _Palette p, double t,
    {Offset center = const Offset(160, 122),
    double radius = 104,
    double wobble = 0.07,
    Color? color,
    double phase = 0}) {
  const int n = 7;
  final List<Offset> pts = <Offset>[];
  for (int i = 0; i < n; i++) {
    final double a = _tau * i / n + 0.3;
    final double r = radius *
        (1 + wobble * math.sin(_tau * (t + phase) + i * 1.9) +
            0.05 * math.cos(i * 2.3));
    pts.add(center + Offset(math.cos(a) * r * 1.18, math.sin(a) * r * 0.92));
  }
  canvas.drawPath(_smoothClosed(pts), _fill(color ?? p.blob));
}

/// Catmull–Rom spline through closed points.
Path _smoothClosed(List<Offset> pts) {
  final Path path = Path()..moveTo(pts[0].dx, pts[0].dy);
  final int n = pts.length;
  for (int i = 0; i < n; i++) {
    final Offset p0 = pts[(i - 1 + n) % n];
    final Offset p1 = pts[i];
    final Offset p2 = pts[(i + 1) % n];
    final Offset p3 = pts[(i + 2) % n];
    final Offset c1 = p1 + (p2 - p0) / 6;
    final Offset c2 = p2 - (p3 - p1) / 6;
    path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p2.dx, p2.dy);
  }
  return path..close();
}

/// Four-point twinkle star.
void _sparkle(Canvas canvas, Offset c, double size, Color color) {
  if (size <= 0.2) return;
  final double s = size;
  final double k = s * 0.22;
  final Path path = Path()
    ..moveTo(c.dx, c.dy - s)
    ..quadraticBezierTo(c.dx + k, c.dy - k, c.dx + s, c.dy)
    ..quadraticBezierTo(c.dx + k, c.dy + k, c.dx, c.dy + s)
    ..quadraticBezierTo(c.dx - k, c.dy + k, c.dx - s, c.dy)
    ..quadraticBezierTo(c.dx - k, c.dy - k, c.dx, c.dy - s)
    ..close();
  canvas.drawPath(path, _fill(color));
}

void _sparkles(Canvas canvas, double t, List<Offset> at,
    {double size = 6, Color color = _Palette.accent}) {
  for (int i = 0; i < at.length; i++) {
    final double v = 0.5 + 0.5 * _wave(t, freq: 2, phase: i * 0.27);
    _sparkle(canvas, at[i], size * (0.35 + 0.65 * v),
        color.withValues(alpha: 0.35 + 0.65 * v));
  }
}

/// Draws the first `progress` fraction of `path`.
void _drawPartial(Canvas canvas, Path path, double progress, Paint paint) {
  if (progress <= 0) return;
  if (progress >= 1) {
    canvas.drawPath(path, paint);
    return;
  }
  for (final metric in path.computeMetrics()) {
    canvas.drawPath(metric.extractPath(0, metric.length * progress), paint);
  }
}

void _text(
  Canvas canvas,
  String text,
  Offset at, {
  double size = 10,
  FontWeight weight = FontWeight.w700,
  Color color = Colors.black,
  bool center = false,
}) {
  final TextPainter tp = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        fontFamily: kFontFamily,
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: 1,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  tp.paint(canvas, center ? at - Offset(tp.width / 2, tp.height / 2) : at);
}

void _icon(Canvas canvas, IconData icon, Offset center, double size, Color color) {
  final TextPainter tp = TextPainter(
    text: TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(
        fontFamily: icon.fontFamily,
        package: icon.fontPackage,
        fontSize: size,
        color: color,
        height: 1,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
}

/// A floating rounded chip with an icon and label (product-UI flavour).
void _chip(Canvas canvas, _Palette p, Offset topLeft, IconData icon,
    String label, {double width = 92}) {
  final RRect r = RRect.fromRectAndRadius(
      Rect.fromLTWH(topLeft.dx, topLeft.dy, width, 30),
      const Radius.circular(10));
  _shadow(canvas, Path()..addRRect(r), blur: 12, dy: 5, alpha: 0.10);
  canvas.drawRRect(r, _fill(p.surface));
  canvas.drawRRect(r, _stroke(p.outline, 1));
  final Offset ic = topLeft + const Offset(16, 15);
  canvas.drawCircle(ic, 10, _fill(_Palette.accent.withValues(alpha: 0.12)));
  _icon(canvas, icon, ic, 13, _Palette.accent);
  _text(canvas, label, topLeft + const Offset(31, 10),
      size: 10, color: p.ink, weight: FontWeight.w700);
}

/// A smartphone body; returns the screen rect.
Rect _phone(Canvas canvas, _Palette p, Rect body, {double radius = 20}) {
  final RRect outer = RRect.fromRectAndRadius(body, Radius.circular(radius));
  _shadow(canvas, Path()..addRRect(outer), blur: 22, dy: 12, alpha: 0.16);
  canvas.drawRRect(outer, _fill(p.dark ? AppColors.grey700 : AppColors.grey900));
  final Rect screen = body.deflate(6);
  canvas.drawRRect(
    RRect.fromRectAndRadius(screen, Radius.circular(radius - 5)),
    _fill(p.surface),
  );
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromCenter(
          center: Offset(body.center.dx, screen.top + 8), width: 30, height: 7),
      const Radius.circular(4),
    ),
    _fill(p.dark ? AppColors.grey700 : AppColors.grey900),
  );
  return screen;
}

void _line(Canvas canvas, Offset a, double w, Color c, {double h = 6}) {
  if (w <= 0) return;
  canvas.drawRRect(
    RRect.fromRectAndRadius(Rect.fromLTWH(a.dx, a.dy, w, h), Radius.circular(h / 2)),
    _fill(c),
  );
}

void _check(Canvas canvas, Offset c, double size, double progress, Color color,
    {double width = 3}) {
  final Path path = Path()
    ..moveTo(c.dx - size * 0.5, c.dy + size * 0.02)
    ..lineTo(c.dx - size * 0.12, c.dy + size * 0.38)
    ..lineTo(c.dx + size * 0.55, c.dy - size * 0.36);
  _drawPartial(canvas, path, progress, _stroke(color, width));
}

void _coin(Canvas canvas, Offset c, double r, {double alpha = 1}) {
  canvas.drawCircle(c, r, _fill(_Palette.goldDeep.withValues(alpha: alpha)));
  canvas.drawCircle(c - Offset(0, r * 0.12), r * 0.92,
      _fill(_Palette.gold.withValues(alpha: alpha)));
  canvas.drawCircle(c - Offset(0, r * 0.12), r * 0.6,
      _stroke(_Palette.goldDeep.withValues(alpha: alpha * 0.7), r * 0.12));
  canvas.drawCircle(c + Offset(-r * 0.35, -r * 0.5), r * 0.16,
      _fill(Colors.white.withValues(alpha: alpha * 0.7)));
}

/// Scalloped verification rosette.
void _rosette(Canvas canvas, Offset c, double r, Color color) {
  const int bumps = 12;
  final Path path = Path();
  for (int i = 0; i <= bumps * 2; i++) {
    final double a = _tau * i / (bumps * 2) - math.pi / 2;
    final double rr = i.isEven ? r : r * 0.86;
    final Offset pt = c + Offset(math.cos(a) * rr, math.sin(a) * rr);
    if (i == 0) {
      path.moveTo(pt.dx, pt.dy);
    } else {
      path.lineTo(pt.dx, pt.dy);
    }
  }
  path.close();
  canvas.drawPath(path, _fill(color));
}
