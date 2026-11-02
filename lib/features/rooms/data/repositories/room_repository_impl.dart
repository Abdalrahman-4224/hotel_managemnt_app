import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/floors.dart';
import '../../domain/entities/room.dart';
import '../../domain/repositories/rooms_repository.dart';
import '../data_sources/rooms_data_source.dart';
import '../models/floors_model.dart';
import '../models/room_model.dart';
import '../models/room_type_model.dart';

class RoomRepositoryImp implements RoomsRepository {
  final RoomsDataSource roomsDataSource;

  RoomRepositoryImp(this.roomsDataSource);

  @override
  Future<List<Floor>> getFloors() async {
    // The three calls don't depend on each other, so run them together.
    final (floorsJson, roomsJson, typesJson) = await (
      roomsDataSource.fetchFloors(),
      roomsDataSource.fetchRooms(),
      roomsDataSource.fetchRoomTypes(),
    ).wait;

    final types = {
      for (final json in typesJson)
        RoomTypeModel.fromJson(json).id: RoomTypeModel.fromJson(json),
    };
    final rooms = roomsJson.map((json) {
      final model = RoomModel.fromJson(json);
      return model.toEntity(types[model.roomTypeId]);
    }).toList();

    // GET /floors has no rooms in it: put each room in its floor.
    return floorsJson.map((json) {
      final floor = FloorsModel.fromJson(json).toEntity();
      return floor.copyWith(
        rooms: rooms.where((r) => r.floorId == floor.id).toList(),
      );
    }).toList();
  }

  @override
  Future<void> updateRoomStatus(int roomId, RoomStatus status) async {
    await roomsDataSource.updateRoom(roomId, {
      'current_status': RoomModel.statusToJson(status),
    });
  }
}

final roomsRepositoryProvider = Provider<RoomsRepository>((ref) {
  return RoomRepositoryImp(ref.watch(roomsDataSourceProvider));
});
