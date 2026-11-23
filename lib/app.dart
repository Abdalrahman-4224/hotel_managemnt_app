import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/constants/app_constants.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'features/authentication/presentation/controllers/permissions_controller.dart';
import 'features/notifications/presentation/controllers/notifications_controller.dart';

/// Every size in the app is written for this screen and scaled from it with
/// `.r`, so this one Size decides what the other 300-odd call sites mean.
const _designSize = Size(390, 844);

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    // A superadmin can change a role's permissions while the app is open, and
    // notifications arrive while it is away, so both are re-read whenever the
    // app comes back to the foreground.
    _lifecycle = AppLifecycleListener(
      onResume: () {
        ref.read(permissionsEpochProvider.notifier).bump();
        ref.read(notificationsEpochProvider.notifier).bump();
      },
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Sizes in the code are written for a 390 x 844 phone screen.
    // ScreenUtil scales them up or down to fit the real screen.
    return ScreenUtilInit(
      designSize: _designSize,
      minTextAdapt: true,
      // On Android the first frame can arrive before the window has a size.
      // ScreenUtil then scales everything to 0, and const widgets built in
      // that frame keep their 0 widths for good. Wait for a real size first.
      ensureScreenSize: true,
      builder: (context, child) => MaterialApp.router(
        // Wraps every route, so no screen has to think about tablets.
        builder: (context, screen) => _DesignFrame(child: screen!),
        // Android shows this in the recent-apps list.
        title: AppConstants.appName,

        theme: AppTheme.light,
        routerConfig: ref.watch(appRouterProvider),
        // Arabic UI: sets right-to-left layout and Arabic Material strings.
        locale: const Locale('ar'),
        supportedLocales: const [Locale('ar')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
      ),
    );
  }
}

/// Keeps the app at the proportions it was drawn in, on any screen.
///
/// `.r` scales by the smaller of the width and height ratios, so on a screen
/// that is wider than the design - a tablet, a foldable, a desktop window -
/// everything is scaled by the height while the extra width just stretches
/// the layout: long lines of text, buttons the full 1024pt of an iPad.
///
/// So the content is given the widest box that still has the design's own
/// shape, and centred. The width and height ratios are then equal, `.r` is
/// one number again, and an iPad shows the same screen an iPhone does, only
/// larger. Phones are narrower than that box and pass straight through.
class _DesignFrame extends StatelessWidget {
  const _DesignFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final size = media.size;
    final frameWidth = size.height * (_designSize.width / _designSize.height);
    if (size.width <= frameWidth) return child;

    // ScreenUtilInit measured the whole window; point ScreenUtil at the box
    // the app actually gets instead. This is the same call ScreenUtilInit
    // makes, and it runs below it, so this is the one the screens read.
    final framed = media.copyWith(size: Size(frameWidth, size.height));
    ScreenUtil.configure(
      data: framed,
      designSize: _designSize,
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
