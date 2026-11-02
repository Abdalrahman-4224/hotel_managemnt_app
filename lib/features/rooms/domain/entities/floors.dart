import '../entities/room.dart';

class Floor {
  final int id;
  final String name;
  final List<Room> rooms;

  const Floor({required this.id, required this.name, required this.rooms});

  Floor copyWith({List<Room>? rooms}) {
    return Floor(id: id, name: name, rooms: rooms ?? this.rooms);
  }
}
