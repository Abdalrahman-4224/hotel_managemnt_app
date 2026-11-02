import '../entities/floors.dart';
import '../entities/room.dart';

/// What the app can do with rooms and floors.
/// The real implementation is in data/repositories/room_repository_impl.dart.
abstract class RoomsRepository {
  /// All floors of the current hotel, each with its rooms.
  Future<List<Floor>> getFloors();

  /// Changes a room's status on the server.
  Future<void> updateRoomStatus(int roomId, RoomStatus status);
}
