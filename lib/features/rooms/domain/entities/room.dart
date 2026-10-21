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
  const Room(this.number, this.status, this.type, this.beds, this.view);

  final String number;
  final RoomStatus status;
  final String type;
  final String beds;
  final String view;

  bool get isFree => status == RoomStatus.free;

  /// How many guests the room sleeps.
  int get capacity => switch (type) {
    'مفردة' => 1,
    'مزدوجة' => 2,
    'ثلاثية' => 3,
    'جناح' => 4,
    _ => 1,
  };
}

class Floor {
  const Floor(this.name, this.rooms);

  final String name;
  final List<Room> rooms;
}
