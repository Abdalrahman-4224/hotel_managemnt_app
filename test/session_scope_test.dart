import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotel_managemnt_app/features/authentication/domain/entities/auth_user.dart';
import 'package:hotel_managemnt_app/features/authentication/presentation/controllers/auth_controller.dart';
import 'package:hotel_managemnt_app/features/bookings/domain/entities/booking.dart';
import 'package:hotel_managemnt_app/features/bookings/domain/repositories/bookings_repository.dart';
import 'package:hotel_managemnt_app/features/bookings/data/repositories/bookings_repository_impl.dart';
import 'package:hotel_managemnt_app/features/bookings/presentation/controllers/bookings_controller.dart';
import 'package:hotel_managemnt_app/features/tasks/domain/entities/task_item.dart';
import 'package:hotel_managemnt_app/features/tasks/domain/repositories/tasks_repository.dart';
import 'package:hotel_managemnt_app/features/tasks/data/repositories/tasks_repository_impl.dart';
import 'package:hotel_managemnt_app/features/tasks/presentation/controllers/tasks_controller.dart';

AuthUser _user(int id) => AuthUser(
  id: id,
  hotelId: 3,
  roleId: 5,
  departmentId: 2,
  fullName: 'مستخدم $id',
  username: 'user$id',
  roleName: 'receptionist',
  phone: null,
  email: null,
);

/// Starts signed in as [start]; tests move it with [set].
class _Session extends AuthController {
  static AuthUser? start = _user(1);

  @override
  AuthState build() => start == null
      ? const AuthState(status: AuthStatus.loggedOut)
      : AuthState(status: AuthStatus.loggedIn, user: start);

  void set(AuthUser? user) => state = user == null
      ? const AuthState(status: AuthStatus.loggedOut)
      : AuthState(status: AuthStatus.loggedIn, user: user);
}

/// Hands out rows stamped with the user who was signed in when asked, and
/// counts the calls.
class _FakeBookings implements BookingsRepository {
  _FakeBookings(this.container);

  final ProviderContainer container;
  var calls = 0;

  @override
  Future<List<Booking>> getBookings() async {
    calls++;
    final id = container.read(authControllerProvider).user?.id;
    return [
      Booking(
        id: id ?? 0,
        bookingIds: [id ?? 0],
        campaignId: null,
        guest: 'نزيل المستخدم $id',
        rooms: '101',
        status: BookingStatus.staying,
        checkIn: DateTime(2026, 11, 1),
        checkOut: DateTime(2026, 11, 2),
        total: 100,
        paid: 0,
      ),
    ];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('not used by this test');
}

class _FakeTasks implements TasksRepository {
  var calls = 0;

  @override
  Future<List<TaskItem>> getTasks() async {
    calls++;
    return const [];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('not used by this test');
}

void main() {
  setUp(() => _Session.start = _user(1));

  test('signing out drops the rows the last user loaded', () async {
    late ProviderContainer container;
    late _FakeBookings bookings;
    container = ProviderContainer(
      overrides: [
        authControllerProvider.overrideWith(_Session.new),
        bookingsRepositoryProvider.overrideWith(
          (ref) => bookings = _FakeBookings(container),
        ),
      ],
    );
    addTearDown(container.dispose);
    container.listen(bookingsControllerProvider, (_, _) {});

    final first = await container.read(bookingsControllerProvider.future);
    expect(first.single.guest, 'نزيل المستخدم 1');
    expect(bookings.calls, 1);

    // Sign out: the list must empty itself without asking the server.
    (container.read(authControllerProvider.notifier) as _Session).set(null);
    expect(await container.read(bookingsControllerProvider.future), isEmpty);
    expect(bookings.calls, 1);

    // A different user gets their own rows, not the first user's.
    (container.read(authControllerProvider.notifier) as _Session).set(_user(2));
    final second = await container.read(bookingsControllerProvider.future);
    expect(second.single.guest, 'نزيل المستخدم 2');
    expect(bookings.calls, 2);
  });

  test('a signed-out app asks for nothing at all', () async {
    _Session.start = null;
    final tasks = _FakeTasks();
    final container = ProviderContainer(
      overrides: [
        authControllerProvider.overrideWith(_Session.new),
        tasksRepositoryProvider.overrideWith((ref) => tasks),
      ],
    );
    addTearDown(container.dispose);

    expect(await container.read(tasksControllerProvider.future), isEmpty);
    expect(tasks.calls, 0);
  });
}
