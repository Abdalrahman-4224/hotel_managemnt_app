/// Room status, matching the server's `current_status`:
/// Available → free, Booked → held, Occupied → busy, anything else → maintenance.
enum RoomStatus { free, busy, held, maintenance }

extension RoomStatusLabel on RoomStatus {
  String get label => switch (this) {
    RoomStatus.free => 'متاحة',
    RoomStatus.busy => 'مشغولة',
    RoomStatus.held => 'محجوزة',
    RoomStatus.maintenance => 'صيانة',
  };
}

class Room {
  final int id;
  final String number;
  final int floorId;
  final int roomTypeId;
  final RoomStatus status;

  // These two come from the room type (GET /room-types).
  final String typeName;
  final int capacity;

  const Room({
    required this.id,
    required this.number,
    required this.floorId,
    required this.roomTypeId,
    required this.status,
    required this.typeName,
    required this.capacity,
  });

  bool get isFree => status == RoomStatus.free;

  Room copyWith({RoomStatus? status}) {
    return Room(
      id: id,
      number: number,
      floorId: floorId,
      roomTypeId: roomTypeId,
      status: status ?? this.status,
      typeName: typeName,
      capacity: capacity,
    );
  }
}
