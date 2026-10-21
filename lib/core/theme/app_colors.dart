import 'package:flutter/material.dart';

/// Nuzul design tokens (from the HTML design's `:root` variables).
class AppColors {
  const AppColors._();

  static const paper = Color(0xFFF4F3F1);
  static const paperWarm = Color(0xFFE9E6E1);
  static const card = Color(0xFFFFFFFF);
  static const sheet = Color(0xFFFBFAF8);
  static const inert = Color(0xFFECEAE7);

  static const ink = Color(0xFF1C1B19);
  static const ink3 = Color(0xFF3A3737);
  static const inkMuted = Color(0xFF615E5B);
  static const inkFaint = Color(0xFF7C7874);
  static const chevron = Color(0xFFBAB6B6);

  static const onInk = Color(0xFFF8F5F1);
  static const onInkMuted = Color(0xFFB3ADA5);

  static const gold = Color(0xFFB68235);
  static const goldDeep = Color(0xFF7D5411);
  static const goldDarkest = Color(0xFF5A3B0A);
  static const goldLight = Color(0xFFE3B06A);
  static const goldTint = Color(0xFFFDF4E6);
  static const amber = Color(0xFFF0A33A);

  static const danger = Color(0xFFA0281E);
  static const dangerBorder = Color(0x40A0281E);
  static const switchOff = Color(0xFFD9D5CF);

  /// rgba(28,27,25,.065)
  static const line = Color(0x111C1B19);

  /// rgba(28,27,25,.12)
  static const lineStrong = Color(0x1F1C1B19);

  /// rgba(28,27,25,.3)
  static const lineHeavy = Color(0x4D1C1B19);

  /// rgba(28,27,25,.18) – sheet grabber
  static const grabber = Color(0x2E1C1B19);

  /// rgba(182,130,53,.35)
  static const goldBorder = Color(0x59B68235);

  /// rgba(182,130,53,.28)
  static const goldBorderSoft = Color(0x47B68235);

  /// rgba(24,23,21,.46)
  static const scrim = Color(0x75181715);

  /// rgba(248,245,241,.12)
  static const onInkLine = Color(0x1FF8F5F1);

  /// rgba(248,245,241,.14)
  static const onInkTrack = Color(0x24F8F5F1);

  /// rgba(248,245,241,.22)
  static const onInkBorder = Color(0x38F8F5F1);
}

class AppShadows {
  const AppShadows._();

  static const card = [
    BoxShadow(color: Color(0x091C1B19), offset: Offset(0, 1), blurRadius: 2),
    BoxShadow(
      color: Color(0x241C1B19),
      offset: Offset(0, 6),
      blurRadius: 16,
      spreadRadius: -10,
    ),
  ];

  static const ink = [
    BoxShadow(color: Color(0x291C1B19), offset: Offset(0, 1), blurRadius: 2),
    BoxShadow(
      color: Color(0x6B1C1B19),
      offset: Offset(0, 10),
      blurRadius: 24,
      spreadRadius: -12,
    ),
  ];

  static const floating = [
    BoxShadow(
      color: Color(0x801C1B19),
      offset: Offset(0, 10),
      blurRadius: 26,
      spreadRadius: -12,
    ),
    BoxShadow(
      color: Color(0x991C1B19),
      offset: Offset(0, 30),
      blurRadius: 50,
      spreadRadius: -30,
    ),
  ];

  static const segment = [
    BoxShadow(color: Color(0x141C1B19), offset: Offset(0, 1), blurRadius: 2),
    BoxShadow(
      color: Color(0x401C1B19),
      offset: Offset(0, 4),
      blurRadius: 10,
      spreadRadius: -6,
    ),
  ];
}
