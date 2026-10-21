import 'dart:math' as math;

enum PriceBasis { perRoom, perPerson }

enum PaymentTiming { fullNow, depositNow, onCheckout }

enum DiscountType { none, freeRooms, freePeople, freeNights, percent, fixed }

/// Pure pricing for a booking (USD), ported from the design's logic.
class BookingQuote {
  const BookingQuote({
    required this.rooms,
    required this.heads,
    required this.nights,
    required this.basis,
    required this.rate,
    required this.timing,
    required this.discount,
    required this.discountValue,
  });

  final int rooms;
  final int heads;
  final int nights;
  final PriceBasis basis;
  final int rate;
  final PaymentTiming timing;
  final DiscountType discount;
  final int discountValue;

  int get units => basis == PriceBasis.perPerson ? heads : rooms;

  int get gross => rate * units * nights;

  int get discountAmount {
    final dv = discountValue;
    final num amount = switch (discount) {
      DiscountType.none => 0,
      DiscountType.freeRooms => rate * math.min(dv, units) * nights,
      DiscountType.freePeople =>
        (gross * math.min(dv, heads) / math.max(1, heads)).round(),
      DiscountType.freeNights => rate * units * math.min(dv, nights),
      DiscountType.percent => (gross * math.min(dv, 100) / 100).round(),
      DiscountType.fixed => math.min(dv, gross),
    };
    return amount.toInt();
  }

  int get total => math.max(0, gross - discountAmount);

  int get receivedNow => switch (timing) {
    PaymentTiming.fullNow => total,
    PaymentTiming.depositNow => (total / 2).round(),
    PaymentTiming.onCheckout => 0,
  };

  int get dueOnCheckout => total - receivedNow;
}
