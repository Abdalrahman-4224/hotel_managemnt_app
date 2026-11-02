import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/authentication/domain/entities/permissions.dart';
import '../../features/authentication/presentation/controllers/permissions_controller.dart';
import '../widgets/widgets.dart';

/// Hosts the bottom-nav tabs. [navigationShell] is the active tab's
/// navigator, so each tab keeps its own back stack.
///
/// Tabs the user has no permission for are left out of the bar. The router's
/// branches stay fixed, so [_visibleBranches] maps a tapped tab back to its
/// branch index.
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  /// Branch index -> the permission needed to see that tab.
  /// Home and the user's own profile are always available.
  static const _tabPermission = <int, String?>{
    0: null, // الرئيسية
    1: null, // حسابي
    2: Permissions.financeView, // المالية
    3: Permissions.staffView, // الموظفون
  };

  List<int> _visibleBranches(Permissions can) {
    return [
      for (final entry in _tabPermission.entries)
        if (entry.value == null || can.can(entry.value!)) entry.key,
    ];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final can = ref.watch(canProvider);
    final branches = _visibleBranches(can);

    // The user may be on a tab they just lost access to; fall back to home.
    final current = branches.indexOf(navigationShell.currentIndex);

    return Scaffold(
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: NzBottomNav(
        items: [for (final b in branches) NzBottomNav.allItems[b]],
        currentIndex: current < 0 ? 0 : current,
        // Tapping the active tab again pops it back to its first screen.
        onTap: (i) => navigationShell.goBranch(
          branches[i],
          initialLocation: branches[i] == navigationShell.currentIndex,
        ),
      ),
    );
  }
}
