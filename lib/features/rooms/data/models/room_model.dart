import '../../../../core/utils/json_parsers.dart';
import '../../domain/entities/room.dart';
import 'room_type_model.dart';

/// A row from GET /rooms, with JSON conversion.
class RoomModel {
  final int id;
  final String number;
  final int floorId;
  final int roomTypeId;
  final String currentStatus;

  const RoomModel({
    required this.id,
    required this.number,
    required this.floorId,
    required this.roomTypeId,
    required this.currentStatus,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: parseInt(json['room_id'])!,
      number: json['room_number'] ?? '',
      floorId: parseInt(json['floor_id']) ?? 0,
      roomTypeId: parseInt(json['room_type_id']) ?? 0,
      currentStatus: json['current_status'] ?? 'Available',
    );
  }

  /// The server's `current_status` text for an app status.
  static String statusToJson(RoomStatus status) => switch (status) {
    RoomStatus.free => 'Available',
    RoomStatus.held => 'Booked',
    RoomStatus.busy => 'Occupied',
    RoomStatus.maintenance => 'Maintenance',
  };

  static RoomStatus statusFromJson(String value) => switch (value) {
    'Available' => RoomStatus.free,
    'Booked' => RoomStatus.held,
    'Occupied' => RoomStatus.busy,
    _ => RoomStatus.maintenance,
  };

  /// [type] is this room's row from GET /room-types (null if not found).
  Room toEntity(RoomTypeModel? type) {
    return Room(
      id: id,
      number: number,
      floorId: floorId,
      roomTypeId: roomTypeId,
      status: statusFromJson(currentStatus),
      typeName: type?.name ?? '',
      capacity: type?.capacity ?? 1,
    );
  }
}
