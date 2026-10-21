import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// The design's three type families:
/// * display – Noto Naskh Arabic (titles)
/// * body    – IBM Plex Sans Arabic (UI text)
/// * num     – Lora (numbers, amounts, codes)
class AppText {
  const AppText._();

  static TextStyle display(
    double size, {
    FontWeight weight = FontWeight.w600,
    Color color = AppColors.ink,
    double height = 1.3,
  }) => GoogleFonts.notoNaskhArabic(
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
  );

  static TextStyle body(
    double size, {
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.ink,
    double? height,
    TextDecoration? decoration,
  }) => GoogleFonts.ibmPlexSansArabic(
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
    decoration: decoration,
    decorationColor: color,
  );

  static TextStyle num(
    double size, {
    FontWeight weight = FontWeight.w600,
    Color color = AppColors.ink,
    double? height,
    double? letterSpacing,
  }) => GoogleFonts.lora(
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
    letterSpacing: letterSpacing,
  );
}
