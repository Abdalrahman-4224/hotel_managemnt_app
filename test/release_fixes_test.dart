import 'package:flutter_test/flutter_test.dart';
import 'package:hotel_managemnt_app/core/errors/app_exception.dart';
import 'package:hotel_managemnt_app/features/bookings/data/data_sources/bookings_data_source.dart';
import 'package:hotel_managemnt_app/features/bookings/data/repositories/bookings_repository_impl.dart';
import 'package:hotel_managemnt_app/features/bookings/domain/entities/booking_quote.dart';
import 'package:hotel_managemnt_app/features/bookings/domain/entities/new_booking.dart';
import 'package:hotel_managemnt_app/features/bookings/domain/repositories/bookings_repository.dart';
import 'package:hotel_managemnt_app/features/bookings/presentation/controllers/add_booking_controller.dart';
import 'package:hotel_managemnt_app/features/rooms/domain/entities/room.dart';
import 'package:hotel_managemnt_app/features/tasks/data/models/task_model.dart';

/// Answers like the server, failing the request named in [failOn].
class _FakeServer implements BookingsDataSource {
  _FakeServer({this.failOn, this.failAfterRooms = 0});

  final String? failOn;
  final int failAfterRooms;
  var rooms = 0;
  var payments = 0;

  @override
  Future<Map<String, dynamic>> createCampaign(Map<String, dynamic> body) async {
    if (failOn == 'campaign') throw const AppException('رفض', statusCode: 400);
    return {'campaign_id': 7};
  }

  @override
  Future<Map<String, dynamic>> confirmBooking(Map<String, dynamic> body) async {
    if (failOn == 'room' && rooms >= failAfterRooms) {
      throw const AppException('الغرفة محجوزة', statusCode: 409);
    }
    rooms++;
    return {'booking_id': 100 + rooms};
  }

  @override
  Future<void> addPayment(Map<String, dynamic> body) async {
    if (failOn == 'payment') throw const AppException('ممنوع', statusCode: 403);
    payments++;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('${invocation.memberName}');
}

Room _room(int id) => Room(
  id: id,
  number: '$id',
  floorId: 1,
  roomTypeId: 1,
  status: RoomStatus.free,
  typeName: 'مفردة',
  capacity: 2,
);

NewBooking _booking({required int rooms, int receivedNow = 0}) => NewBooking(
  rooms: [for (var i = 1; i <= rooms; i++) _room(i)],
  isGroup: rooms > 1,
  groupName: 'وفد',
  guestName: 'عمر',
  phone: '',
  nationalId: 'A1',
  heads: rooms * 2,
  checkIn: DateTime(2026, 12, 1),
  checkOut: DateTime(2026, 12, 3),
  withBreakfast: true,
  total: 480,
  receivedNow: receivedNow,
  payByCard: false,
);

void main() {
  group('a booking is never left looking unsaved once part of it is saved', () {
    test('the first room failing is a plain error: nothing was saved', () {
      final server = _FakeServer(failOn: 'room');
      expect(
        BookingsRepositoryImpl(server).createBooking(_booking(rooms: 2)),
        throwsA(
          isA<AppException>().having(
            (e) => e is BookingPartlySaved,
            'partly saved',
            false,
          ),
        ),
      );
    });

    test('a later room failing says how much was saved', () async {
      final server = _FakeServer(failOn: 'room', failAfterRooms: 1);
      await expectLater(
        BookingsRepositoryImpl(server).createBooking(_booking(rooms: 3)),
        throwsA(isA<BookingPartlySaved>()),
      );
      expect(server.rooms, 1);
    });

    test('the payment failing after the booking is partly saved', () async {
      final server = _FakeServer(failOn: 'payment');
      await expectLater(
        BookingsRepositoryImpl(server)
            .createBooking(_booking(rooms: 1, receivedNow: 100)),
        throwsA(isA<BookingPartlySaved>()),
      );
      expect(server.rooms, 1);
    });

    test('nothing to collect: no payment request at all', () async {
      final server = _FakeServer(failOn: 'payment');
      await BookingsRepositoryImpl(server).createBooking(_booking(rooms: 1));
      expect(server.payments, 0);
    });
  });

  test('without FINANCE_CREATE the form takes no money now', () {
    final c = AddBookingController(
      floors: const [],
      repository: _FakeRepository(),
      canRecordPayment: false,
    );
    expect(c.timing, PaymentTiming.onCheckout);
    expect(c.quote.receivedNow, 0);
  });

  test('moving check-in past check-out keeps one night', () {
    final c = AddBookingController(
      floors: const [],
      repository: _FakeRepository(),
    );
    final later = c.checkOut.add(const Duration(days: 5));
    c.setDates(checkIn: later);
    expect(c.checkOut, later.add(const Duration(days: 1)));
  });

  test('errors from requests sent together keep the server message', () async {
    Future<int> ok() async => 1;
    Future<int> offline() async =>
        throw const AppException('تحقق من اتصالك بالإنترنت وحاول مرة أخرى');
    Object? caught;
    try {
      await (ok(), offline(), ok()).wait;
    } catch (error) {
      caught = error;
    }
    expect(caught, isA<ParallelWaitError>());
    expect(errorText(caught), 'تحقق من اتصالك بالإنترنت وحاول مرة أخرى');
  });

  test("a task from the website shows its own title", () {
    final fromWeb = TaskModel.fromJson({
      'task_id': 1,
      'title': 'تنظيف بعد الخروج',
      'description': 'مغادرة حجز #12 — عمر.',
      'status': 'Pending',
    });
    expect(fromWeb.title, 'تنظيف بعد الخروج');

    final fromApp = TaskModel.fromJson({
      'task_id': 2,
      'description': 'تغيير المصباح\nفي الحمّام',
      'status': 'Pending',
    });
    expect(fromApp.title, 'تغيير المصباح');
  });
}

class _FakeRepository implements BookingsRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('${invocation.memberName}');
}
