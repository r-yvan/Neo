part of 'neo_illustration.dart';

// ================================================================== SIGN IN
// A phone shows a profile card while a padlock beside it unlocks; category
// chips float around it like the catalogue waiting behind the sign-in.

void _paintSignIn(Canvas canvas, double t, _Palette p) {
  _blob(canvas, p, t, radius: 100, phase: 0.1);
  _groundShadow(canvas, const Offset(160, 222), 120);

  final Rect screen = _phone(canvas, p, const Rect.fromLTWH(118, 24, 86, 186));

  // Profile header.
  final Offset avatar = Offset(screen.center.dx, screen.top + 44);
  canvas.drawCircle(avatar, 17, _fill(_Palette.accent.withValues(alpha: 0.14)));
  canvas.drawCircle(avatar - const Offset(0, 4), 6, _fill(_Palette.accent));
  final Path shoulders = Path()
    ..addArc(Rect.fromCenter(center: avatar + const Offset(0, 12), width: 22, height: 16),
        math.pi, math.pi);
  canvas.drawPath(shoulders, _fill(_Palette.accent));
  _line(canvas, Offset(screen.center.dx - 26, screen.top + 70), 52, p.faint);
  _line(canvas, Offset(screen.center.dx - 18, screen.top + 82), 36, p.faint, h: 5);

  // Input fields with a typing caret.
  for (int i = 0; i < 2; i++) {
    final Rect field = Rect.fromLTWH(
        screen.left + 8, screen.top + 98 + i * 24.0, screen.width - 16, 17);
    canvas.drawRRect(RRect.fromRectAndRadius(field, const Radius.circular(6)),
        _stroke(i == 1 ? _Palette.accent : p.outline, 1.2));
    final double typed = _seg(t, 0.1 + i * 0.25, 0.3 + i * 0.25) *
        (1 - _seg(t, 0.92, 1));
    final int dots = (6 * typed).round();
    for (int d = 0; d < dots; d++) {
      canvas.drawCircle(
          Offset(field.left + 8 + d * 7.0, field.center.dy), 2, _fill(p.ink));
    }
  }
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(screen.left + 8, screen.bottom - 28, screen.width - 16, 18),
      const Radius.circular(9),
    ),
    _fill(_Palette.accent),
  );

  // Padlock that opens once both fields are typed, then closes again.
  final double open = _easeOutBack(_seg(t, 0.62, 0.74)) * (1 - _easeInOut(_seg(t, 0.88, 0.98)));
  _padlock(canvas, p, const Offset(236, 150), 1, open: open);

  // Floating chips.
  _chip(canvas, p, Offset(16, 54 + _wave(t, phase: 0.1) * 5),
      Icons.event_seat_rounded, 'Chairs', width: 84);
  _chip(canvas, p, Offset(22, 138 + _wave(t, phase: 0.55) * 5),
      Icons.speaker_rounded, 'Sound', width: 80);
  _chip(canvas, p, Offset(216, 40 + _wave(t, phase: 0.8) * 5),
      Icons.holiday_village_rounded, 'Tents', width: 80);

  _sparkles(canvas, t, const <Offset>[Offset(108, 18), Offset(290, 110), Offset(100, 206)]);
}

/// Padlock centred on `c`. `open` lifts the shackle (0 closed → 1 open).
void _padlock(Canvas canvas, _Palette p, Offset c, double scale, {double open = 0}) {
  canvas.save();
  canvas.translate(c.dx, c.dy);
  canvas.scale(scale);
  final double lift = 12 * open;
  // Shackle.
  final Path shackle = Path()
    ..moveTo(-13, -4)
    ..lineTo(-13, -18 - lift)
    ..arcToPoint(Offset(13, -18 - lift), radius: const Radius.circular(13))
    ..lineTo(13, -4 - lift * 0.6);
  canvas.save();
  if (open > 0) {
    canvas.translate(13, -4);
    canvas.rotate(-0.35 * open);
    canvas.translate(-13, 4);
  }
  canvas.drawPath(shackle, _stroke(p.inkSoft, 6, cap: StrokeCap.butt));
  canvas.restore();
  // Body.
  final RRect body = RRect.fromRectAndRadius(
      const Rect.fromLTWH(-24, -6, 48, 40), const Radius.circular(10));
  _shadow(canvas, Path()..addRRect(body), blur: 14, dy: 6, alpha: 0.16);
  canvas.drawRRect(body, _fill(_Palette.accent));
  canvas.drawRRect(
    RRect.fromRectAndRadius(
        const Rect.fromLTWH(-24, -6, 48, 10), const Radius.circular(10)),
    _fill(_Palette.accentLight.withValues(alpha: 0.35)),
  );
  // Keyhole.
  canvas.drawCircle(const Offset(0, 10), 5, _fill(_Palette.accentDeep));
  canvas.drawRRect(
    RRect.fromRectAndRadius(
        const Rect.fromLTWH(-2, 11, 4, 11), const Radius.circular(2)),
    _fill(_Palette.accentDeep),
  );
  canvas.restore();
}

// ================================================================ REGISTER
// An ID card fills itself in line by line, then a verified rosette pops.

void _paintRegister(Canvas canvas, double t, _Palette p) {
  _blob(canvas, p, t, radius: 102, phase: 0.35);
  _groundShadow(canvas, const Offset(160, 206), 210);

  final double float = _wave(t, freq: 1) * 3;
  canvas.save();
  canvas.translate(0, float);

  final RRect card = RRect.fromRectAndRadius(
      const Rect.fromLTWH(56, 60, 208, 128), const Radius.circular(18));
  _shadow(canvas, Path()..addRRect(card), blur: 22, dy: 12, alpha: 0.14);
  canvas.drawRRect(card, _fill(p.surface));
  canvas.save();
  canvas.clipRRect(card);
  canvas.drawRect(const Rect.fromLTWH(56, 60, 208, 30), _fill(_Palette.accent));
  // Subtle wave pattern on the header.
  final Path wave = Path()..moveTo(56, 84);
  for (double x = 56; x <= 264; x += 4) {
    wave.lineTo(x, 84 + math.sin((x / 26) + _tau * t) * 3);
  }
  wave
    ..lineTo(264, 90)
    ..lineTo(56, 90)
    ..close();
  canvas.drawPath(wave, _fill(_Palette.accentLight.withValues(alpha: 0.45)));
  canvas.restore();
  canvas.drawRRect(card, _stroke(p.outline, 1));
  _text(canvas, 'NEO  ·  ID', const Offset(72, 70), size: 9, color: Colors.white);

  // Photo.
  final RRect photo = RRect.fromRectAndRadius(
      const Rect.fromLTWH(72, 102, 54, 66), const Radius.circular(10));
  canvas.drawRRect(photo, _fill(p.faint));
  canvas.save();
  canvas.clipRRect(photo);
  canvas.drawCircle(const Offset(99, 126), 11, _fill(p.muted));
  canvas.drawOval(const Rect.fromLTWH(78, 140, 42, 34), _fill(p.muted));
  canvas.restore();

  // Lines typing in.
  final double reset = 1 - _seg(t, 0.92, 1);
  const List<double> widths = <double>[96, 74, 86, 52];
  for (int i = 0; i < widths.length; i++) {
    final double y = 106 + i * 15.0;
    _line(canvas, Offset(140, y), widths[i], p.faint, h: 7);
    final double prog = _easeOut(_seg(t, 0.08 + i * 0.1, 0.24 + i * 0.1)) * reset;
    _line(canvas, Offset(140, y), widths[i] * prog,
        i == 0 ? p.ink : p.inkSoft.withValues(alpha: 0.7), h: 7);
  }
  canvas.restore();

  // Verified rosette.
  final double pop = _easeOutBack(_seg(t, 0.52, 0.66)) * reset;
  if (pop > 0) {
    canvas.save();
    canvas.translate(256, 66 + float);
    canvas.scale(pop);
    canvas.rotate(_wave(t, freq: 1) * 0.08);
    _shadow(canvas, Path()..addOval(Rect.fromCircle(center: Offset.zero, radius: 20)),
        blur: 12, dy: 5, alpha: 0.18);
    _rosette(canvas, Offset.zero, 22, _Palette.accent);
    _check(canvas, Offset.zero, 18, _seg(t, 0.6, 0.72), Colors.white, width: 3.4);
    canvas.restore();
  }

  // Pen gliding along the bottom.
  final double penX = 150 + 70 * _easeInOut(_seg(t, 0.08, 0.5)) * reset;
  canvas.save();
  canvas.translate(penX, 206 + float);
  canvas.rotate(-0.7);
  canvas.drawRRect(
    RRect.fromRectAndRadius(const Rect.fromLTWH(-4, -34, 8, 30), const Radius.circular(3)),
    _fill(p.ink),
  );
  final Path nib = Path()
    ..moveTo(-4, -4)
    ..lineTo(4, -4)
    ..lineTo(0, 4)
    ..close();
  canvas.drawPath(nib, _fill(_Palette.accent));
  canvas.restore();

  _sparkles(canvas, t, const <Offset>[Offset(40, 52), Offset(292, 150), Offset(46, 186)]);
}

// ===================================================================== OTP
// A paper plane carries the code along a dashed arc; the SMS bubble pops and
// the six digits fill in one by one.

void _paintOtp(Canvas canvas, double t, _Palette p) {
  _blob(canvas, p, t, radius: 100, phase: 0.75);
  _groundShadow(canvas, const Offset(196, 222), 110);

  final Rect screen = _phone(canvas, p, const Rect.fromLTWH(156, 36, 80, 176));
  _line(canvas, Offset(screen.left + 8, screen.top + 26), 40, p.faint);
  for (int i = 0; i < 3; i++) {
    _line(canvas, Offset(screen.left + 8, screen.top + 120 + i * 12.0),
        screen.width - 16 - i * 10, p.faint, h: 5);
  }

  // Dashed flight path.
  final Path flight = Path()
    ..moveTo(22, 176)
    ..cubicTo(40, 60, 130, 40, 176, 96);
  final Paint dash = _stroke(p.muted, 1.6);
  for (final metric in flight.computeMetrics()) {
    for (double d = 0; d < metric.length; d += 9) {
      canvas.drawPath(metric.extractPath(d, d + 4), dash);
    }
  }

  // Plane along the path (first 45% of the loop).
  final double fly = _easeInOut(_seg(t, 0.0, 0.42));
  if (fly < 1) {
    final metric = flight.computeMetrics().first;
    final Tangent? tan = metric.getTangentForOffset(metric.length * fly);
    if (tan != null) {
      canvas.save();
      canvas.translate(tan.position.dx, tan.position.dy);
      canvas.rotate(-tan.angle);
      final Path plane = Path()
        ..moveTo(14, 0)
        ..lineTo(-12, -10)
        ..lineTo(-6, 0)
        ..lineTo(-12, 10)
        ..close();
      _shadow(canvas, plane, blur: 6, dy: 3, alpha: 0.12);
      canvas.drawPath(plane, _fill(_Palette.accent));
      canvas.drawLine(const Offset(-6, 0), const Offset(14, 0),
          _stroke(_Palette.accentDeep, 1.2));
      canvas.restore();
    }
  }

  // SMS bubble.
  final double pop = _easeOutBack(_seg(t, 0.4, 0.52)) * (1 - _seg(t, 0.94, 1));
  if (pop > 0) {
    canvas.save();
    canvas.translate(150, 96);
    canvas.scale(pop);
    final RRect bubble = RRect.fromRectAndRadius(
        const Rect.fromLTWH(-110, -26, 128, 52), const Radius.circular(14));
    final Path tail = Path()
      ..moveTo(4, 20)
      ..lineTo(22, 34)
      ..lineTo(14, 16)
      ..close();
    final Path shape = Path()
      ..addRRect(bubble)
      ..addPath(tail, Offset.zero);
    _shadow(canvas, shape, blur: 16, dy: 8, alpha: 0.14);
    canvas.drawPath(shape, _fill(p.surface));
    canvas.drawRRect(bubble, _stroke(p.outline, 1));
    _text(canvas, 'Neo code', const Offset(-100, -18), size: 8, color: p.inkSoft, weight: FontWeight.w500);
    const String digits = '482913';
    for (int i = 0; i < 6; i++) {
      final double show = _seg(t, 0.52 + i * 0.05, 0.56 + i * 0.05);
      final Rect box = Rect.fromLTWH(-100 + i * 19.0, -4, 15, 20);
      canvas.drawRRect(RRect.fromRectAndRadius(box, const Radius.circular(5)),
          _fill(show > 0 ? _Palette.accent.withValues(alpha: 0.12) : p.faint));
      if (show > 0) {
        _text(canvas, digits[i], box.center, size: 11 * (0.6 + 0.4 * _easeOutBack(show)),
            color: _Palette.accent, weight: FontWeight.w900, center: true);
      }
    }
    canvas.restore();
  }

  _sparkles(canvas, t, const <Offset>[Offset(60, 40), Offset(276, 60), Offset(270, 190)]);
}

// =================================================================== RESET
// A key slides in, turns, and the padlock springs open.

void _paintReset(Canvas canvas, double t, _Palette p) {
  _blob(canvas, p, t, radius: 98, phase: 0.5);
  _groundShadow(canvas, const Offset(160, 214), 120);

  final double slide = _easeInOut(_seg(t, 0.05, 0.35));
  final double turn = _easeInOut(_seg(t, 0.38, 0.5));
  final double open = _easeOutBack(_seg(t, 0.5, 0.62));
  final double back = _easeInOut(_seg(t, 0.86, 1));

  _padlock(canvas, p, const Offset(160, 128), 1.6, open: open * (1 - back));

  // Key: travels from the right into the keyhole, rotates, then withdraws.
  final double keyX = 296 - (296 - 166) * slide * (1 - back);
  canvas.save();
  canvas.translate(keyX, 144);
  // Fake 3D turn by squashing vertically.
  canvas.scale(1, 1 - 0.6 * turn * (1 - back));
  final Paint keyPaint = _fill(_Palette.gold);
  canvas.drawCircle(const Offset(34, 0), 14, keyPaint);
  canvas.drawCircle(const Offset(34, 0), 5.5, _fill(p.surface));
  canvas.drawRRect(
    RRect.fromRectAndRadius(const Rect.fromLTWH(-6, -3.5, 30, 7), const Radius.circular(3)),
    keyPaint,
  );
  canvas.drawRect(const Rect.fromLTWH(0, 3, 4, 6), keyPaint);
  canvas.drawRect(const Rect.fromLTWH(8, 3, 4, 4), keyPaint);
  canvas.restore();

  // Burst when it opens.
  final double burst = _seg(t, 0.52, 0.72);
  if (burst > 0 && burst < 1) {
    for (int i = 0; i < 8; i++) {
      final double a = _tau * i / 8;
      final Offset dir = Offset(math.cos(a), math.sin(a));
      const Offset c = Offset(160, 62);
      canvas.drawLine(
        c + dir * (18 + 16 * burst),
        c + dir * (24 + 24 * burst),
        _stroke(_Palette.accent.withValues(alpha: 1 - burst), 2.4),
      );
    }
  }

  // Dotted progress arc behind: "securing".
  final Paint dots = _fill(p.muted);
  for (int i = 0; i < 18; i++) {
    final double a = -math.pi * 0.9 + (math.pi * 1.8) * i / 17;
    final bool lit = i / 17 <= _seg(t, 0.0, 0.5) * (1 - back);
    canvas.drawCircle(
      const Offset(160, 124) + Offset(math.cos(a), math.sin(a)) * 96,
      lit ? 2.6 : 1.8,
      lit ? _fill(_Palette.accent) : dots,
    );
  }

  _sparkles(canvas, t, const <Offset>[Offset(52, 60), Offset(268, 52), Offset(60, 190)]);
}
