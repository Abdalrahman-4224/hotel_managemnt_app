import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/room_repository_impl.dart';
import '../../domain/entities/floors.dart';
import '../../domain/entities/room.dart';

/// Loads the hotel's floors (with their rooms) for the rooms screen.
///
/// The state is an AsyncValue, so the screen gets loading / error / data:
///   ref.watch(floorsControllerProvider).when(...)
class FloorsController extends AsyncNotifier<List<Floor>> {
  /// Runs the first time the screen watches this provider.
  @override
  Future<List<Floor>> build() {
    return ref.read(roomsRepositoryProvider).getFloors();
  }

  /// Loads the floors again (pull to refresh, retry after an error).
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(roomsRepositoryProvider).getFloors(),
    );
  }

  /// Changes a room's status. The screen updates right away; if the
  /// server refuses, the old status comes back and the error is rethrown
  /// so the screen can show it.
  Future<void> setRoomStatus(Room room, RoomStatus status) async {
    final before = state.value;
    if (before == null || room.status == status) return;

    state = AsyncData(_replaceStatus(before, room.id, status));
    try {
      await ref.read(roomsRepositoryProvider).updateRoomStatus(room.id, status);
    } catch (_) {
      state = AsyncData(before);
      rethrow;
    }
  }

  List<Floor> _replaceStatus(
    List<Floor> floors,
    int roomId,
    RoomStatus status,
  ) {
    return [
      for (final floor in floors)
        floor.copyWith(
          rooms: [
            for (final r in floor.rooms)
              r.id == roomId ? r.copyWith(status: status) : r,
          ],
        ),
    ];
  }
}

final floorsControllerProvider =
    AsyncNotifierProvider<FloorsController, List<Floor>>(FloorsController.new);
