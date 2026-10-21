import 'package:flutter/animation.dart';

class AppMotion {
  const AppMotion._();

  /// `cubic-bezier(.16,1,.3,1)` – the design's ease-out used for sheets,
  /// pop-ins and the OTP ring.
  static const easeOut = Cubic(.16, 1, .3, 1);

  static const popIn = Duration(milliseconds: 340);
}
