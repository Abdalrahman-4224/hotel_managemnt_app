import '../../../../core/utils/json_parsers.dart';

/// A row from GET /room-types. Only used to fill a room's type name and capacity.
class RoomTypeModel {
  final int id;
  final String name;
  final int capacity;

  const RoomTypeModel({
    required this.id,
    required this.name,
    required this.capacity,
  });

  factory RoomTypeModel.fromJson(Map<String, dynamic> json) {
    return RoomTypeModel(
      id: parseInt(json['room_type_id'])!,
      name: json['type_name'] ?? '',
      capacity: parseInt(json['capacity']) ?? 1,
    );
  }
}
