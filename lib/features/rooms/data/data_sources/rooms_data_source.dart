import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_providers.dart';

class RoomsDataSource {
  final ApiClient apiClient;

  RoomsDataSource(this.apiClient);

  Future<List<Map<String, dynamic>>> fetchFloors() async {
    final data = await apiClient.get('/floors');
    return List<Map<String, dynamic>>.from(data);
  }

  Future<List<Map<String, dynamic>>> fetchRooms() async {
    final data = await apiClient.get('/rooms');
    return List<Map<String, dynamic>>.from(data);
  }

  Future<List<Map<String, dynamic>>> fetchRoomTypes() async {
    final data = await apiClient.get('/room-types');
    return List<Map<String, dynamic>>.from(data);
  }

  /// Creates a new room on the server.
  Future<Map<String, dynamic>> createRoom(Map<String, dynamic> roomData) async {
    final data = await apiClient.post('/rooms', data: roomData);
    return data;
  }

  /// Updates only the fields sent, e.g. {'current_status': 'Maintenance'}.
  Future<Map<String, dynamic>> updateRoom(
    int roomId,
    Map<String, dynamic> roomData,
  ) async {
    final data = await apiClient.put('/rooms/$roomId', data: roomData);
    return data;
  }
}

final roomsDataSourceProvider = Provider<RoomsDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return RoomsDataSource(apiClient);
});
