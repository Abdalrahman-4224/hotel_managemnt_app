import 'package:go_router/go_router.dart';

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

/// The app's route table. Paths come from [AppRoutes].
final appRouter = GoRouter(
  initialLocation: AppRoutes.login,
  routes: [
    GoRoute(
      path: AppRoutes.login,
      builder: (_, _) => const LoginScreen(),
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
                GoRoute(
                  path: 'rooms',
                  builder: (_, _) => const RoomsScreen(),
                ),
                GoRoute(
                  path: 'bookings',
                  builder: (_, _) => const BookingsScreen(),
                ),
                GoRoute(
                  path: 'campaigns',
                  builder: (_, _) => const CampaignsScreen(),
                ),
                GoRoute(
                  path: 'tasks',
                  builder: (_, _) => const TasksScreen(),
                ),
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
      builder: (_, _) => const InvoiceScreen(),
    ),
  ],
);
