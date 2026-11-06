part of 'neo_illustration.dart';

// ===================================================================== RENT
// A striped event marquee with twinkling string lights, a dressed table and
// two chairs bobbing gently, under drifting confetti.

void _paintRent(Canvas canvas, double t, _Palette p) {
  _blob(canvas, p, t, radius: 100);
  _blob(canvas, p, t,
      center: const Offset(250, 70),
      radius: 26,
      wobble: 0.12,
      phase: 0.4,
      color: _Palette.accent.withValues(alpha: p.dark ? 0.10 : 0.06));

  _confetti(canvas, t, behind: true);
  _groundShadow(canvas, const Offset(160, 210), 250, alpha: 0.10);

  // ----------------------------------------------------------- tent body
  final Rect wall = const Rect.fromLTRB(76, 108, 244, 206);
  canvas.drawRect(wall, _fill(p.raised));
  // Back-wall drape folds.
  for (int i = 1; i < 6; i++) {
    final double x = wall.left + wall.width * i / 6;
    canvas.drawLine(Offset(x, wall.top + 4), Offset(x, wall.bottom),
        _stroke(p.outline, 1.2));
  }

  // Posts.
  for (final double x in <double>[72, 248]) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(x - 3, 104, 6, 104), const Radius.circular(3)),
      _fill(p.inkSoft),
    );
  }

  // ----------------------------------------------------------- roof
  const Offset peak = Offset(160, 44);
  const double baseY = 110;
  const double left = 56;
  const double right = 264;
  const int stripes = 8;
  final Path roof = Path()
    ..moveTo(peak.dx, peak.dy)
    ..lineTo(right, baseY)
    ..lineTo(left, baseY)
    ..close();
  _shadow(canvas, roof, blur: 18, dy: 6, alpha: 0.10);
  for (int i = 0; i < stripes; i++) {
    final double x0 = left + (right - left) * i / stripes;
    final double x1 = left + (right - left) * (i + 1) / stripes;
    final Path stripe = Path()
      ..moveTo(peak.dx, peak.dy)
      ..lineTo(x1, baseY)
      ..lineTo(x0, baseY)
      ..close();
    canvas.drawPath(
        stripe, _fill(i.isEven ? _Palette.accent : p.surface));
  }
  canvas.drawPath(roof, _stroke(_Palette.accentDeep.withValues(alpha: 0.35), 1));

  // Flag on top, waving.
  final double flagWave = _wave(t, freq: 3) * 3;
  canvas.drawLine(peak, peak - const Offset(0, 18), _stroke(p.inkSoft, 2));
  final Path flag = Path()
    ..moveTo(peak.dx, peak.dy - 18)
    ..quadraticBezierTo(peak.dx + 9, peak.dy - 20 + flagWave,
        peak.dx + 18, peak.dy - 15 + flagWave * 0.6)
    ..lineTo(peak.dx, peak.dy - 10)
    ..close();
  canvas.drawPath(flag, _fill(_Palette.gold));

  // Scalloped valance.
  const int scallops = 9;
  const double sw = (right - left) / scallops;
  final Path valance = Path()..moveTo(left, baseY - 2);
  for (int i = 0; i < scallops; i++) {
    final double x = left + sw * i;
    valance.quadraticBezierTo(x + sw / 2, baseY + 18, x + sw, baseY - 2);
  }
  valance.close();
  canvas.drawPath(valance, _fill(_Palette.accent));
  for (int i = 0; i < scallops; i++) {
    canvas.drawCircle(
        Offset(left + sw * i + sw / 2, baseY + 5.5), 2, _fill(p.surface));
  }

  // ----------------------------------------------------------- string lights
  const Offset a = Offset(80, 128);
  const Offset b = Offset(240, 128);
  const Offset c = Offset(160, 152);
  final Path wire = Path()
    ..moveTo(a.dx, a.dy)
    ..quadraticBezierTo(c.dx, c.dy, b.dx, b.dy);
  canvas.drawPath(wire, _stroke(p.inkSoft.withValues(alpha: 0.6), 1.2));
  const int bulbs = 9;
  for (int i = 0; i < bulbs; i++) {
    final double u = (i + 0.5) / bulbs;
    final double inv = 1 - u;
    final Offset pt = a * inv * inv + c * 2 * inv * u + b * u * u;
    final double glow = 0.5 + 0.5 * _wave(t, freq: 3, phase: i * 0.19);
    final Color col = i % 3 == 0
        ? _Palette.gold
        : (i % 3 == 1 ? _Palette.accentLight : p.surface);
    canvas.drawCircle(
      pt + const Offset(0, 5),
      9,
      Paint()
        ..color = col.withValues(alpha: 0.35 * glow)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    canvas.drawLine(pt, pt + const Offset(0, 2), _stroke(p.inkSoft, 1.4));
    canvas.drawOval(
        Rect.fromCenter(center: pt + const Offset(0, 5.5), width: 6, height: 8),
        _fill(Color.lerp(col.withValues(alpha: 0.55), col, glow)!));
  }

  // ----------------------------------------------------------- table
  const Rect top = Rect.fromLTRB(124, 166, 196, 172);
  final Path cloth = Path()
    ..moveTo(top.left - 4, top.top)
    ..lineTo(top.right + 4, top.top)
    ..lineTo(top.right + 8, 202)
    ..quadraticBezierTo(top.right - 6, 206, top.center.dx + 18, 202)
    ..quadraticBezierTo(top.center.dx, 207, top.center.dx - 18, 202)
    ..quadraticBezierTo(top.left + 6, 206, top.left - 8, 202)
    ..close();
  canvas.drawPath(cloth, _fill(p.surface));
  canvas.drawPath(cloth, _stroke(p.outline, 1.2));
  canvas.drawLine(Offset(top.left - 4, 180), Offset(top.right + 4, 180),
      _stroke(_Palette.accent.withValues(alpha: 0.5), 2));

  // Centrepiece: vase + flowers that sway.
  final double sway = _wave(t, freq: 2) * 2.5;
  canvas.drawRRect(
    RRect.fromRectAndRadius(
        const Rect.fromLTWH(154, 150, 12, 16), const Radius.circular(4)),
    _fill(p.inkSoft),
  );
  for (int i = -1; i <= 1; i++) {
    final Offset stemTop = Offset(160 + i * 8 + sway, 134 + i.abs() * 4.0);
    canvas.drawLine(const Offset(160, 152), stemTop, _stroke(const Color(0xFF6B8F71), 1.6));
    canvas.drawCircle(stemTop, 5.5, _fill(i == 0 ? _Palette.accent : _Palette.accentLight));
    canvas.drawCircle(stemTop, 2, _fill(_Palette.gold));
  }

  // ----------------------------------------------------------- chairs
  _chair(canvas, p, Offset(104, 204 + _wave(t, freq: 2) * 1.6), mirror: false);
  _chair(canvas, p, Offset(216, 204 + _wave(t, freq: 2, phase: 0.5) * 1.6),
      mirror: true);

  _confetti(canvas, t, behind: false);
}

void _chair(Canvas canvas, _Palette p, Offset foot, {required bool mirror}) {
  canvas.save();
  canvas.translate(foot.dx, foot.dy);
  if (mirror) canvas.scale(-1, 1);
  final Paint leg = _stroke(p.ink, 2.6);
  // Back legs + back rest.
  canvas.drawLine(const Offset(-10, 0), const Offset(-10, -48), leg);
  canvas.drawRRect(
    RRect.fromRectAndRadius(
        const Rect.fromLTWH(-13, -50, 7, 26), const Radius.circular(3)),
    _fill(_Palette.accent),
  );
  // Seat.
  canvas.drawRRect(
    RRect.fromRectAndRadius(
        const Rect.fromLTWH(-13, -24, 28, 6), const Radius.circular(3)),
    _fill(p.ink),
  );
  canvas.drawRRect(
    RRect.fromRectAndRadius(
        const Rect.fromLTWH(-12, -27, 26, 5), const Radius.circular(3)),
    _fill(_Palette.accentLight),
  );
  // Front leg.
  canvas.drawLine(const Offset(12, -19), const Offset(12, 0), leg);
  canvas.restore();
}

void _confetti(Canvas canvas, double t, {required bool behind}) {
  const List<Color> colors = <Color>[
    _Palette.accent,
    _Palette.gold,
    _Palette.accentLight,
    Color(0xFFA3A3A3),
  ];
  for (int i = 0; i < 16; i++) {
    if ((i % 2 == 0) != behind) continue;
    final double seed = (i * 73 % 97) / 97;
    final int speed = 1 + i % 2;
    final double y = ((seed + t * speed) % 1) * 250 - 10;
    final double x = 24 + (i * 53 % 272) + _wave(t, freq: speed, phase: seed) * 8;
    final double alpha = y < 20 ? _clamp01(y / 20) : (y > 200 ? _clamp01((240 - y) / 40) : 1);
    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(_tau * (t * speed + seed));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(-3, -1.5, 6, 3), const Radius.circular(1)),
      _fill(colors[i % colors.length].withValues(alpha: 0.75 * alpha)),
    );
    canvas.restore();
  }
}

// ====================================================================== PAY
// A phone completes a MoMo payment: coins fly in, a check draws itself, a
// shield pulses to show the money is held safely until the rental ends.

void _paintPay(Canvas canvas, double t, _Palette p) {
  _blob(canvas, p, t, radius: 102, phase: 0.2);
  _groundShadow(canvas, const Offset(160, 222), 120);

  final Rect screen = _phone(canvas, p, const Rect.fromLTWH(114, 26, 92, 190));

  // Header pill.
  _text(canvas, 'MoMo Pay', Offset(screen.left + 10, screen.top + 22),
      size: 9, color: p.inkSoft, weight: FontWeight.w700);
  _text(canvas, '15,000', Offset(screen.left + 10, screen.top + 36),
      size: 17, color: p.ink, weight: FontWeight.w900);
  _text(canvas, 'RWF', Offset(screen.left + 10, screen.top + 56),
      size: 8, color: p.inkSoft, weight: FontWeight.w500);

  // Status ring + check: draws in, holds, resets.
  final double draw = _easeOut(_seg(t, 0.25, 0.5));
  final double pop = _easeOutBack(_seg(t, 0.2, 0.36));
  final double fade = 1 - _seg(t, 0.9, 1);
  final Offset cc = Offset(screen.center.dx, screen.top + 104);
  canvas.drawCircle(cc, 26, _fill(p.faint));
  if (pop > 0) {
    canvas.drawCircle(
        cc, 26 * pop, _fill(_Palette.accent.withValues(alpha: fade)));
    _check(canvas, cc, 22, draw, Colors.white.withValues(alpha: fade), width: 3.6);
  }
  // Amount summary lines.
  _line(canvas, Offset(screen.left + 10, screen.top + 146), 60, p.faint);
  _line(canvas, Offset(screen.left + 10, screen.top + 158), 42, p.faint);
  // Pay button.
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(screen.left + 8, screen.bottom - 26, screen.width - 16, 18),
      const Radius.circular(9),
    ),
    _fill(_Palette.accent),
  );
  _text(canvas, 'Paid', Offset(screen.center.dx, screen.bottom - 17),
      size: 8, color: Colors.white, center: true);

  // Coins flying into the phone (staggered).
  for (int i = 0; i < 3; i++) {
    final double u = (t * 1 + i / 3) % 1;
    final double k = _easeInOut(_clamp01(u / 0.7));
    final Offset start = Offset(52 + i * 6.0, 210);
    const Offset end = Offset(150, 110);
    final Offset ctrl = Offset(40 + i * 10.0, 90);
    final double inv = 1 - k;
    final Offset pos = start * inv * inv + ctrl * 2 * inv * k + end * k * k;
    final double alpha = u > 0.7 ? 0 : _clamp01(math.min(u / 0.1, (0.7 - u) / 0.15));
    if (alpha > 0) _coin(canvas, pos, 9 - k * 3, alpha: alpha);
  }

  // Escrow shield.
  final double pulse = 1 + 0.05 * _wave(t, freq: 2);
  canvas.save();
  canvas.translate(250, 96);
  canvas.scale(pulse);
  final Path shield = Path()
    ..moveTo(0, -26)
    ..cubicTo(12, -20, 20, -20, 24, -20)
    ..cubicTo(24, 2, 18, 18, 0, 28)
    ..cubicTo(-18, 18, -24, 2, -24, -20)
    ..cubicTo(-20, -20, -12, -20, 0, -26)
    ..close();
  _shadow(canvas, shield, blur: 12, dy: 6, alpha: 0.10);
  canvas.drawPath(shield, _fill(p.surface));
  canvas.drawPath(shield, _stroke(_Palette.accent, 2.4));
  _icon(canvas, Icons.lock_rounded, const Offset(0, 0), 18, _Palette.accent);
  canvas.restore();

  // Owner payout card bobbing on the left.
  final double bob = _wave(t, freq: 1, phase: 0.25) * 4;
  final RRect card = RRect.fromRectAndRadius(
      Rect.fromLTWH(18, 44 + bob, 96, 44), const Radius.circular(12));
  _shadow(canvas, Path()..addRRect(card), blur: 12, dy: 5, alpha: 0.10);
  canvas.drawRRect(card, _fill(p.surface));
  canvas.drawRRect(card, _stroke(p.outline, 1));
  canvas.drawCircle(Offset(34, 66 + bob), 9, _fill(_Palette.accent.withValues(alpha: 0.14)));
  _icon(canvas, Icons.person_rounded, Offset(34, 66 + bob), 12, _Palette.accent);
  _text(canvas, 'Owner gets', Offset(48, 56 + bob), size: 7.5, color: p.inkSoft, weight: FontWeight.w500);
  _text(canvas, '13,500', Offset(48, 67 + bob), size: 11, color: p.ink, weight: FontWeight.w900);

  _sparkles(canvas, t, const <Offset>[Offset(232, 40), Offset(286, 150), Offset(96, 176)]);
}

// ===================================================================== EARN
// A dashboard card: bars rise one by one, a trend line draws across them and
// an up-arrow badge bounces; a coin stack grows alongside.

void _paintEarn(Canvas canvas, double t, _Palette p) {
  _blob(canvas, p, t, radius: 104, phase: 0.6);
  _groundShadow(canvas, const Offset(160, 214), 220);

  final RRect panel = RRect.fromRectAndRadius(
      const Rect.fromLTWH(52, 46, 196, 158), const Radius.circular(18));
  _shadow(canvas, Path()..addRRect(panel), blur: 22, dy: 10, alpha: 0.12);
  canvas.drawRRect(panel, _fill(p.surface));
  canvas.drawRRect(panel, _stroke(p.outline, 1));

  _text(canvas, 'Earnings', const Offset(68, 62), size: 9, color: p.inkSoft, weight: FontWeight.w500);
  final double grow = _seg(t, 0.05, 0.55);
  final int amount = (162000 * _easeOut(grow)).round();
  _text(canvas, '${_thousands(amount)} RWF', const Offset(68, 75),
      size: 15, color: p.ink, weight: FontWeight.w900);

  // Grid.
  for (int i = 0; i < 3; i++) {
    final double y = 120 + i * 24.0;
    canvas.drawLine(Offset(68, y), Offset(232, y), _stroke(p.faint, 1));
  }

  const List<double> heights = <double>[30, 46, 38, 62, 80];
  const double baseY = 188;
  final double reset = 1 - _seg(t, 0.92, 1);
  final List<Offset> tops = <Offset>[];
  for (int i = 0; i < heights.length; i++) {
    final double local = _easeOutBack(_seg(t, 0.06 + i * 0.07, 0.3 + i * 0.07));
    final double h = heights[i] * local * reset;
    final double x = 76 + i * 32.0;
    final bool last = i == heights.length - 1;
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(x, baseY - h, 20, h),
        topLeft: const Radius.circular(6),
        topRight: const Radius.circular(6),
      ),
      _fill(last ? _Palette.accent : (p.dark ? AppColors.grey700 : AppColors.grey200)),
    );
    tops.add(Offset(x + 10, baseY - heights[i] - 10));
  }

  // Trend line.
  final Path trend = Path()..moveTo(tops.first.dx, tops.first.dy);
  for (int i = 1; i < tops.length; i++) {
    final Offset prev = tops[i - 1];
    final Offset cur = tops[i];
    final double mx = (prev.dx + cur.dx) / 2;
    trend.cubicTo(mx, prev.dy, mx, cur.dy, cur.dx, cur.dy);
  }
  final double lineProg = _easeInOut(_seg(t, 0.4, 0.75)) * reset;
  _drawPartial(canvas, trend, lineProg, _stroke(_Palette.accent, 2.6));
  if (lineProg >= 1) {
    canvas.drawCircle(tops.last, 5, _fill(p.surface));
    canvas.drawCircle(tops.last, 5, _stroke(_Palette.accent, 2.4));
  }

  // Up-arrow badge.
  final double bounce = -6 * _wave(t, freq: 2).abs();
  final RRect badge = RRect.fromRectAndRadius(
      Rect.fromLTWH(222, 30 + bounce, 40, 40), const Radius.circular(12));
  _shadow(canvas, Path()..addRRect(badge), blur: 14, dy: 6, alpha: 0.18);
  canvas.drawRRect(badge, _fill(_Palette.accent));
  _icon(canvas, Icons.trending_up_rounded, Offset(242, 50 + bounce), 24, Colors.white);

  // Coin stack.
  final int coins = 1 + (4 * _seg(t, 0.1, 0.6)).floor();
  for (int i = 0; i < coins; i++) {
    final Offset c = Offset(40, 200 - i * 7.0);
    canvas.drawOval(Rect.fromCenter(center: c + const Offset(0, 2), width: 34, height: 12),
        _fill(_Palette.goldDeep));
    canvas.drawOval(Rect.fromCenter(center: c, width: 34, height: 12), _fill(_Palette.gold));
  }

  _sparkles(canvas, t, const <Offset>[Offset(30, 60), Offset(286, 120), Offset(270, 196)]);
}

String _thousands(int v) {
  final String s = v.toString();
  final StringBuffer out = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) out.write(',');
    out.write(s[i]);
  }
  return out.toString();
}
