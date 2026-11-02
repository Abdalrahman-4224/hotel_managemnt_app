/// The permission codes the server checks, as sent by GET /auth/permissions.
///
/// The server is what actually enforces these; the app uses them only to hide
/// what the user can't do, so they don't tap a button that would fail.
class Permissions {
  const Permissions({required this.isSuperadmin, required this.codes});

  /// Nothing allowed. Used while the codes are still loading.
  const Permissions.none() : isSuperadmin = false, codes = const {};

  final bool isSuperadmin;
  final Set<String> codes;

  /// A superadmin is above the permission system and can do everything.
  bool can(String code) => isSuperadmin || codes.contains(code);

  /// True if any one of [anyOf] is allowed.
  bool canAny(List<String> anyOf) => anyOf.any(can);

  // Bookings
  static const bookingView = 'BOOKING_VIEW';
  static const bookingCreate = 'BOOKING_CREATE';
  static const bookingUpdate = 'BOOKING_UPDATE';
  static const bookingDelete = 'BOOKING_DELETE';
  static const bookingCheckIn = 'BOOKING_CHECKIN';
  static const bookingCancel = 'BOOKING_CANCEL';

  // Campaigns (group bookings)
  static const campaignView = 'CAMPAIGN_VIEW';
  static const campaignCreate = 'CAMPAIGN_CREATE';
  static const campaignUpdate = 'CAMPAIGN_UPDATE';
  static const campaignDelete = 'CAMPAIGN_DELETE';

  // Rooms
  static const roomView = 'ROOM_VIEW';
  static const roomCreate = 'ROOM_CREATE';
  static const roomUpdate = 'ROOM_UPDATE';
  static const roomDelete = 'ROOM_DELETE';

  // Tasks
  static const taskView = 'TASK_VIEW';
  static const taskCreate = 'TASK_CREATE';
  static const taskUpdate = 'TASK_UPDATE';
  static const taskDelete = 'TASK_DELETE';

  // Inventory
  static const inventoryView = 'INVENTORY_VIEW';
  static const inventoryCreate = 'INVENTORY_CREATE';
  static const inventoryUpdate = 'INVENTORY_UPDATE';
  static const inventoryDelete = 'INVENTORY_DELETE';

  // Money
  static const financeView = 'FINANCE_VIEW';
  static const financeCreate = 'FINANCE_CREATE';
  static const financeUpdate = 'FINANCE_UPDATE';
  static const financeDelete = 'FINANCE_DELETE';

  // Everything else
  static const dashboardView = 'DASHBOARD_VIEW';
  static const staffView = 'STAFF_VIEW';
  static const guestView = 'GUEST_VIEW';
}
