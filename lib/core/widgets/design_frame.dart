import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';

/// Every size in the app is written for this screen and scaled from it with
/// `.r`, so this one Size decides what the other 300-odd call sites mean.
const designSize = Size(390, 844);

/// Keeps the app at the proportions it was drawn in, on any screen.
///
/// `.r` scales by the smaller of the width and height ratios, so on a screen
/// that is wider than the design - a tablet, a foldable, an iPad turned on
/// its side - everything is scaled by the height while the extra width just
/// stretches the layout: long lines of text, buttons the full 1024pt of an
/// iPad.
///
/// So the content is given the widest box that still has the design's own
/// shape, and centred. The width and height ratios are then equal, `.r` is
/// one number again, and an iPad shows the same screen an iPhone does, only
/// larger (upright) or a little smaller (on its side). Phones are narrower
/// than that box and pass straight through.
///
/// It is rebuilt on every size change, so turning an iPad re-measures it.
class DesignFrame extends StatelessWidget {
  const DesignFrame({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final size = media.size;
    final frameWidth = size.height * (designSize.width / designSize.height);
    if (size.width <= frameWidth) return child;

    // ScreenUtilInit measured the whole window; point ScreenUtil at the box
    // the app actually gets instead. This is the same call ScreenUtilInit
    // makes, and it runs below it, so this is the one the screens read.
    final framed = media.copyWith(size: Size(frameWidth, size.height));
    ScreenUtil.configure(
      data: framed,
      designSize: designSize,
      minTextAdapt: true,
    );

    return ColoredBox(
      // The bands either side of the app. Screens set their own background -
      // most take the theme's paper, the sign-in screens paperWarm - so there
      // is no one colour that disappears against all of them. The warmer of
      // the two is used deliberately: against paper it reads as a frame, and
      // against the sign-in screens it is invisible.
      color: AppColors.paperWarm,
      child: Center(
        child: SizedBox(
          width: frameWidth,
          child: MediaQuery(data: framed, child: child),
        ),
      ),
    );
  }
}
