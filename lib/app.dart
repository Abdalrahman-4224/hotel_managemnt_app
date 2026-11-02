import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/authentication/presentation/controllers/permissions_controller.dart';

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
    // A superadmin can change a role's permissions while the app is open, so
    // reload them whenever the app comes back to the foreground.
    _lifecycle = AppLifecycleListener(
      onResume: () => ref.read(permissionsEpochProvider.notifier).bump(),
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
      designSize: const Size(390, 844),
      minTextAdapt: true,
      builder: (context, child) => MaterialApp.router(
        title: 'Hotel Management',
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
