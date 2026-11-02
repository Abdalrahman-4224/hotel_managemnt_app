import '../../../rooms/domain/entities/room.dart';

/// Everything the add-booking form collects, ready to send.
class NewBooking {
  const NewBooking({
    required this.rooms,
    required this.isGroup,
    required this.groupName,
    required this.guestName,
    required this.phone,
    required this.nationalId,
    required this.heads,
    required this.checkIn,
    required this.checkOut,
    required this.withBreakfast,
    required this.total,
    required this.receivedNow,
    required this.payByCard,
  });

  final List<Room> rooms;
  final bool isGroup;
  final String groupName;
  final String guestName;
  final String phone;
  final String nationalId;
  final int heads;
  final DateTime checkIn;
  final DateTime checkOut;
  final bool withBreakfast;

  /// In US dollars, for all rooms together.
  final int total;
  final int receivedNow;
  final bool payByCard;
}
