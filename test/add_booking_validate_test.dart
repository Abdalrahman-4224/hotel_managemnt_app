import 'package:flutter_test/flutter_test.dart';
import 'package:hotel_managemnt_app/features/bookings/domain/entities/booking_quote.dart';
import 'package:hotel_managemnt_app/features/bookings/domain/repositories/bookings_repository.dart';
import 'package:hotel_managemnt_app/features/bookings/presentation/controllers/add_booking_controller.dart';
import 'package:hotel_managemnt_app/features/rooms/domain/entities/floors.dart';
import 'package:hotel_managemnt_app/features/rooms/domain/entities/room.dart';

/// validate() never reaches the server, so the repository is never called.
class _UnusedRepository implements BookingsRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('validate() must not call the server');
}

AddBookingController _controller() {
  Room room(int id, String number) => Room(
    id: id,
    number: number,
    floorId: 1,
    roomTypeId: 1,
    status: RoomStatus.free,
    typeName: 'مفردة',
    capacity: 2,
  );
  final c = AddBookingController(
    floors: [
      Floor(
        id: 1,
        name: 'الطابق الأول',
        rooms: [room(1, '101'), room(2, '102')],
      ),
    ],
    repository: _UnusedRepository(),
  );
  // A form that is ready to send; each test spoils one thing.
  c.selected.add('101');
  c.guestName.text = 'عمر خالد';
  c.nationalId.text = 'A1234567';
  return c;
}

void main() {
  test('a filled form passes', () {
    expect(_controller().validate(), isNull);
  });

  test('the guest and the id are required', () {
    final noName = _controller()..guestName.text = '  ';
    expect(noName.validate(), isNotNull);

    final noId = _controller()..nationalId.text = '';
    expect(noId.validate(), isNotNull);
  });

  test('a group needs its name', () {
    final c = _controller()..isGroup = true;
    expect(c.validate(), 'اكتب اسم الحملة.');
    c.groupName.text = 'وفد بغداد';
    expect(c.validate(), isNull);
  });

  test('check-out must be after check-in', () {
    final c = _controller()..checkOut = _controller().checkIn;
    expect(c.validate(), 'تاريخ الخروج بعد تاريخ الدخول.');
  });

  // Clearing the price box parses as 0; the server would store the booking
  // with a total of 0 without complaining.
  test('the nightly price must be more than nothing', () {
    final perRoom = _controller()..setRate(0);
    expect(perRoom.validate(), 'اكتب سعر الليلة.');

    final perPerson = _controller()
      ..basis = PriceBasis.perPerson
      ..setRate(0);
    expect(perPerson.validate(), 'اكتب سعر الليلة.');
  });

  test('at least one room', () {
    final c = _controller()..selected.clear();
    expect(c.validate(), 'اختر غرفة واحدة على الأقل.');
  });
}
