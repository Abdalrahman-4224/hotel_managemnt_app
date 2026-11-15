import 'package:flutter_screenutil/flutter_screenutil.dart';

// Responsive sizes. Every value is a design pixel (on the 390 × 844 design)
// scaled to the screen with flutter_screenutil's `.r` - the same scale the
// text uses, so the whole layout keeps its proportions on any screen.
//
// They are getters, not consts, because the scale depends on the screen,
// which can change while the app runs (rotation, a foldable opening).
//
// How to size things:
//   * spacing and corners  -> these tokens:  EdgeInsets.all(AppSpacing.s16)
//   * a one-off dimension  -> `.r` inline:   SizedBox(height: 54.r)
//   * text                 -> AppText, which takes design units:  AppText.body(14)
//   * our own widgets take pixels, so pass tokens or `.r`:
//       NzCard(radius: AppRadius.r16), NzPrimaryButton(height: 48.r)

/// Padding, margins and gaps.
class AppSpacing {
  const AppSpacing._();

  static double get s2 => 2.r;
  static double get s3 => 3.r;
  static double get s4 => 4.r;
  static double get s6 => 6.r;
  static double get s8 => 8.r;
  static double get s10 => 10.r;
  static double get s12 => 12.r;
  static double get s14 => 14.r;
  static double get s16 => 16.r;
  static double get s18 => 18.r;
  static double get s20 => 20.r;
  static double get s24 => 24.r;
  static double get s32 => 32.r;
}

/// Corner radii.
class AppRadius {
  const AppRadius._();

  static double get r8 => 8.r;
  static double get r10 => 10.r;
  static double get r12 => 12.r;
  static double get r14 => 14.r;
  static double get r16 => 16.r;
  static double get r18 => 18.r;
  static double get r20 => 20.r;
  static double get r22 => 22.r;
  static double get r24 => 24.r;
  static double get r28 => 28.r;

  /// Fully rounded ends, for pills and chips.
  static double get full => 99.r;
}
