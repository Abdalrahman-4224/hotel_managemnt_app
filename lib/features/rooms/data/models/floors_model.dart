import '../../../../core/utils/json_parsers.dart';
import '../../domain/entities/floors.dart';

class FloorsModel {
  final int? floorid;
  final int? hotelid;
  final int? floornumber;
  final String? floorname;

  const FloorsModel({
    required this.floorid,
    required this.hotelid,
    required this.floorname,
    required this.floornumber,
  });

  factory FloorsModel.fromJson(Map<String, dynamic> json) {
    return FloorsModel(
      floorid: parseInt(json['floor_id'])!,
      hotelid: parseInt(json['hotel_id']),
      floornumber: parseInt(json['floor_number']),
      floorname: json['name_floor'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'floor_id': floorid,
      'hotel_id': hotelid,
      'floor_number': floornumber,
      'name_floor': floorname,
    };
  }

  Floor toEntity() {
    return Floor(id: floorid ?? 0, name: floorname ?? '', rooms: []);
  }
}
