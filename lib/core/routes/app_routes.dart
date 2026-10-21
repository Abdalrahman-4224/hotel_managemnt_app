/// Route paths used across the app.
class AppRoutes {
  const AppRoutes._();

  static const login = '/login';

  // Bottom-nav tabs.
  static const home = '/home';
  static const profile = '/profile';
  static const finance = '/finance';
  static const staff = '/staff';

  // Sections opened from the home tab (bottom nav stays visible).
  static const rooms = '/home/rooms';
  static const bookings = '/home/bookings';
  static const campaigns = '/home/campaigns';
  static const tasks = '/home/tasks';
  static const inventory = '/home/inventory';

  // Full-screen flows (no bottom nav).
  static const addBooking = '/booking/new';
  static const invoice = '/invoice';
}
