import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../../../rooms/data/data_sources/rooms_local_data_source.dart';
import '../../../rooms/domain/entities/room.dart';
import '../../domain/entities/booking_quote.dart';

class DiscountOption {
  const DiscountOption(this.label, this.type, this.defaultValue);

  final String label;
  final DiscountType type;
  final int defaultValue;
}

/// State of the add-booking flow (room picking + booking details).
class AddBookingController extends ChangeNotifier {
  AddBookingController({
    RoomsLocalDataSource source = const RoomsLocalDataSource(),
  }) : floors = source.getFloors();

  final List<Floor> floors;

  var isGroup = false;
  var floor = 0;
  final selected = <String>[];

  DateTime checkIn = DateTime(2026, 10, 10);
  DateTime checkOut = DateTime(2026, 10, 13);
  int? _headsOverride;

  var mealIncluded = 0; // 0: مع إفطار, 1: بدون
  var payByCard = 0; // 0: نقداً, 1: بطاقة
  var timing = PaymentTiming.depositNow;
  var basis = PriceBasis.perRoom;
  var rateRoom = 240;
  var ratePerson = 20;
  var discount = DiscountType.none;
  var discountValue = 0;

  List<Room> get _all => [for (final f in floors) ...f.rooms];

  List<Room> get pickedRooms =>
      _all.where((r) => selected.contains(r.number)).toList();

  int get heads =>
      _headsOverride ??
      math.max(1, pickedRooms.fold<int>(0, (n, r) => n + r.capacity));

  int get nights {
    final d = checkOut.difference(checkIn).inDays;
    return d < 1 ? 1 : d;
  }

  int get rate => basis == PriceBasis.perPerson ? ratePerson : rateRoom;

  BookingQuote get quote => BookingQuote(
    rooms: math.max(1, selected.length),
    heads: heads,
    nights: nights,
    basis: basis,
    rate: rate,
    timing: timing,
    discount: discount,
    discountValue: discountValue,
  );

  String get kindLabel => isGroup ? 'حجز حملة' : 'حجز فرد';

  List<DiscountOption> get discountOptions {
    final perPerson = basis == PriceBasis.perPerson;
    return [
      const DiscountOption('بلا خصم', DiscountType.none, 0),
      perPerson
          ? const DiscountOption('أشخاص مجاناً', DiscountType.freePeople, 1)
          : const DiscountOption('غرف مجاناً', DiscountType.freeRooms, 1),
      if (!perPerson)
        const DiscountOption('أشخاص مجاناً', DiscountType.freePeople, 2),
      const DiscountOption('ليالٍ مجانية', DiscountType.freeNights, 1),
      const DiscountOption('نسبة مئوية', DiscountType.percent, 10),
      const DiscountOption('مبلغ مقطوع', DiscountType.fixed, 50),
    ];
  }

  String get discountLabel => switch (discount) {
    DiscountType.none => '',
    DiscountType.freeRooms => 'عدد الغرف المجانية',
    DiscountType.freePeople => 'عدد الأشخاص المجانيين',
    DiscountType.freeNights => 'عدد الليالي المجانية',
    DiscountType.percent => 'نسبة الخصم %',
    DiscountType.fixed => 'مبلغ الخصم بالدولار',
  };

  void setGroup(bool v) {
    isGroup = v;
    selected.clear();
    _headsOverride = null;
    notifyListeners();
  }

  void setFloor(int i) {
    floor = i;
    notifyListeners();
  }

  void toggleRoom(Room r) {
    if (!r.isFree) return;
    final on = selected.contains(r.number);
    if (isGroup) {
      on ? selected.remove(r.number) : selected.add(r.number);
    } else {
      selected
        ..clear()
        ..addAll(on ? const [] : [r.number]);
    }
    _headsOverride = null;
    notifyListeners();
  }

  void setDates({DateTime? checkIn, DateTime? checkOut}) {
    if (checkIn != null) this.checkIn = checkIn;
    if (checkOut != null) this.checkOut = checkOut;
    notifyListeners();
  }

  void changeHeads(int delta) {
    _headsOverride = math.max(1, heads + delta);
    notifyListeners();
  }

  void set(VoidCallback change) {
    change();
    notifyListeners();
  }

  void setRate(int v) => set(() {
    if (basis == PriceBasis.perPerson) {
      ratePerson = v;
    } else {
      rateRoom = v;
    }
  });

  void pickDiscount(DiscountOption o) => set(() {
    discount = o.type;
    discountValue = o.defaultValue;
  });
}
