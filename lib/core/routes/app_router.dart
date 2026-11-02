import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/authentication/domain/entities/permissions.dart';
import '../../features/authentication/presentation/controllers/auth_controller.dart';
import '../../features/authentication/presentation/controllers/permissions_controller.dart';

import '../../features/authentication/presentation/screens/activation_screen.dart';
import '../../features/authentication/presentation/screens/login_screen.dart';
import '../../features/bookings/presentation/screens/add_booking_screen.dart';
import '../../features/bookings/presentation/screens/bookings_screen.dart';
import '../../features/campaigns/presentation/screens/campaigns_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/finance/presentation/screens/finance_screen.dart';
import '../../features/inventory/presentation/screens/inventory_screen.dart';
import '../../features/invoices/presentation/screens/invoice_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/rooms/presentation/screens/rooms_screen.dart';
import '../../features/staff/presentation/screens/staff_screen.dart';
import '../../features/tasks/presentation/screens/tasks_screen.dart';
import 'app_routes.dart';
import 'app_shell.dart';

/// The permission each screen needs before it can be opened. Screens not
/// listed here are open to any signed-in user.
const _routePermission = <String, String>{
  AppRoutes.rooms: Permissions.roomView,
  AppRoutes.bookings: Permissions.bookingView,
  AppRoutes.campaigns: Permissions.campaignView,
  AppRoutes.tasks: Permissions.taskView,
  AppRoutes.inventory: Permissions.inventoryView,
  AppRoutes.finance: Permissions.financeView,
  AppRoutes.staff: Permissions.staffView,
  AppRoutes.addBooking: Permissions.bookingCreate,
};

/// The app's route table. Paths come from [AppRoutes].
final appRouterProvider = Provider<GoRouter>((ref) {
  // GoRouter re-runs `redirect` every time this notifier changes.
  final authChanged = ValueNotifier(0);
  ref.onDispose(authChanged.dispose);

  ref.listen(authControllerProvider, (previous, next) {
    if (previous?.status != next.status) {
      authChanged.value++;
    }
  });

  // A permission change can close a screen the user is already on.
  ref.listen(permissionsProvider, (previous, next) => authChanged.value++);

  return GoRouter(
    initialLocation: AppRoutes.login,
    refreshListenable: authChanged,
    redirect: (context, state) {
      final status = ref.read(authControllerProvider).status;
      final isOnLogin = state.matchedLocation == AppRoutes.login;
      final isOnActivate = state.matchedLocation == AppRoutes.activate;

      // Still reading the saved session: don't move yet.
      if (status == AuthStatus.checking) return null;

      // Not logged in: always go to login (activation is open too).
      if (status == AuthStatus.loggedOut && !isOnLogin && !isOnActivate) {
        return AppRoutes.login;
      }

      // Logged in but on the login screen: go home.
      if (status == AuthStatus.loggedIn && isOnLogin) return AppRoutes.home;

      // Screens the user has no permission for send them home. Only once the
      // codes have actually loaded, so a slow first load doesn't bounce them
      // off a screen they are allowed to see.
      final permissions = ref.read(permissionsProvider);
      final needed = _routePermission[state.matchedLocation];
      if (needed != null &&
          permissions.hasValue &&
          !permissions.value!.can(needed)) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: _routes,
  );
});

final _routes = <RouteBase>[
  GoRoute(path: AppRoutes.login, builder: (_, _) => const LoginScreen()),
  GoRoute(
    path: AppRoutes.activate,
    builder: (_, _) => const ActivationScreen(),
  ),

  // Bottom-nav tabs. Branch order must match NzBottomNav.items.
  StatefulShellRoute.indexedStack(
    builder: (_, _, shell) => AppShell(navigationShell: shell),
    branches: [
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (_, _) => const DashboardScreen(),
            // Sections opened from home keep the bottom nav visible.
            routes: [
              GoRoute(path: 'rooms', builder: (_, _) => const RoomsScreen()),
              GoRoute(
                path: 'bookings',
                builder: (_, _) => const BookingsScreen(),
              ),
              GoRoute(
                path: 'campaigns',
                builder: (_, _) => const CampaignsScreen(),
              ),
              GoRoute(path: 'tasks', builder: (_, _) => const TasksScreen()),
              GoRoute(
                path: 'inventory',
                builder: (_, _) => const InventoryScreen(),
              ),
            ],
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.profile,
            builder: (_, _) => const ProfileScreen(),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.finance,
            builder: (_, _) => const FinanceScreen(),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.staff,
            builder: (_, _) => const StaffScreen(),
          ),
        ],
      ),
    ],
  ),

  // Full-screen flows (no bottom nav).
  GoRoute(
    path: AppRoutes.addBooking,
    builder: (_, _) => const AddBookingScreen(),
  ),
  GoRoute(
    path: AppRoutes.invoice,
    // extra: the booking id (int), or nothing.
    builder: (_, state) => InvoiceScreen(bookingId: state.extra as int?),
  ),
];
