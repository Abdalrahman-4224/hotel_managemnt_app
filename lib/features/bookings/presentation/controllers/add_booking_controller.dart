import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../rooms/domain/entities/floors.dart';
import '../../../rooms/domain/entities/room.dart';
import '../../domain/entities/booking_quote.dart';
import '../../domain/entities/new_booking.dart';
import '../../domain/repositories/bookings_repository.dart'
    show BookingPartlySaved, BookingsRepository;

class DiscountOption {
  const DiscountOption(this.label, this.type, this.defaultValue);

  final String label;
  final DiscountType type;
  final int defaultValue;
}

/// State of the add-booking flow (room picking + booking details).
class AddBookingController extends ChangeNotifier {
  AddBookingController({
    required this.floors,
    required this.repository,
    this.canRecordPayment = true,
  }) : timing = canRecordPayment
           ? PaymentTiming.depositNow
           : PaymentTiming.onCheckout;

  final List<Floor> floors;
  final BookingsRepository repository;

  /// FINANCE_CREATE. Without it the server refuses the payment that follows
  /// the booking, so the form takes no money: all of it is due on checkout.
  final bool canRecordPayment;

  // Guest (or, for a group, the person in charge) details.
  final groupName = TextEditingController();
  final guestName = TextEditingController();
  final phone = TextEditingController();
  final nationalId = TextEditingController();

  /// Holds on the picked rooms while the details form is open.
  var _lockIds = <int>[];
  var isSaving = false;

  var isGroup = false;
  var floor = 0;
  final selected = <String>[];

  DateTime checkIn = DateUtils.dateOnly(DateTime.now());
  DateTime checkOut = DateUtils.dateOnly(
    DateTime.now().add(const Duration(days: 1)),
  );
  int? _headsOverride;

  var mealIncluded = 0; // 0: مع إفطار, 1: بدون
  var payByCard = 0; // 0: نقداً, 1: بطاقة
  PaymentTiming timing;
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
    if (checkIn != null) {
      this.checkIn = checkIn;
      // Keep at least one night: moving check-in past check-out drags it on.
      if (!this.checkOut.isAfter(checkIn)) {
        this.checkOut = checkIn.add(const Duration(days: 1));
      }
    }
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

  /// Step 1 → 2: hold the picked rooms so nobody else books them meanwhile.
  Future<void> holdRooms() async {
    _lockIds = await repository.holdRooms([for (final r in pickedRooms) r.id]);
  }

  /// The form was closed without confirming.
  Future<void> releaseRooms() async {
    await repository.releaseHolds(_lockIds);
    _lockIds = [];
  }

  /// The first problem with the form, or null when it can be sent.
  String? validate() {
    if (isGroup && groupName.text.trim().isEmpty) return 'اكتب اسم الحملة.';
    if (guestName.text.trim().isEmpty) return 'اكتب اسم النزيل.';
    if (nationalId.text.trim().isEmpty) return 'اكتب رقم الهوية أو الجواز.';
    if (!checkOut.isAfter(checkIn)) return 'تاريخ الخروج بعد تاريخ الدخول.';
    // Clearing the price box leaves 0, and the server takes whatever total it
    // is sent - so a booking worth nothing would be saved without a word.
    if (rate <= 0) return 'اكتب سعر الليلة.';
    if (selected.isEmpty) return 'اختر غرفة واحدة على الأقل.';
    return null;
  }

  /// Step 2: create the booking on the server. Errors are rethrown.
  Future<void> confirm() async {
    set(() => isSaving = true);
    try {
      final q = quote;
      await repository.createBooking(
        NewBooking(
          rooms: pickedRooms,
          isGroup: isGroup,
          groupName: groupName.text.trim(),
          guestName: guestName.text.trim(),
          phone: phone.text.trim(),
          nationalId: nationalId.text.trim(),
          heads: heads,
          checkIn: checkIn,
          checkOut: checkOut,
          withBreakfast: mealIncluded == 0,
          total: q.total,
          receivedNow: q.receivedNow,
          payByCard: payByCard == 1,
        ),
      );
      // confirmBooking ends the holds itself.
      _lockIds = [];
    } on BookingPartlySaved {
      // Part of it is on the server, so the rooms are no longer ours to free.
      _lockIds = [];
      rethrow;
    } finally {
      set(() => isSaving = false);
    }
  }

  @override
  void dispose() {
    groupName.dispose();
    guestName.dispose();
    phone.dispose();
    nationalId.dispose();
    super.dispose();
  }
}
