# data/repositories/<name>_repository_impl.dart   (e.g. rooms_repository_impl.dart)

## What it is
The **real implementation** of the domain contract:
`class RoomsRepositoryImpl implements RoomsRepository`.

## What it does (the "glue")
1. Calls the data source(s) → gets raw `Map`s.
2. Converts: `Map` → `Model.fromJson` → `.toEntity()`.
3. Returns **entities** to whoever called it.
4. Combines sources when needed (remote + local cache, API + TokenStorage).
5. Handles data-related errors when it makes sense
   (for example: if logout fails on the server, still log out on the device).

## It also exposes the provider
The provider is typed with the **abstract** contract, not the Impl:
```dart
final roomsRepositoryProvider = Provider<RoomsRepository>((ref) {
  return RoomsRepositoryImpl(
    ref.watch(roomsRemoteDataSourceProvider),
    ref.watch(roomsLocalDataSourceProvider),
  );
});
```

## Example
```dart
class RoomsRepositoryImpl implements RoomsRepository {
  final RoomsRemoteDataSource remote;
  final RoomsLocalDataSource local;
  RoomsRepositoryImpl(this.remote, this.local);

  @override
  Future<List<Room>> getRooms() async {
    final list = await remote.fetchRooms();
    return list.map((j) => RoomModel.fromJson(j).toEntity()).toList();
  }

  @override
  Future<Room> createRoom({required String number, required int floorId}) async {
    final body = {'room_number': number, 'floor_id': floorId};
    final data = await remote.createRoom(body);
    return RoomModel.fromJson(data).toEntity();
  }
}
```

## Who uses it
The controller, through `roomsRepositoryProvider`, and it only sees the `RoomsRepository` type.

Real example: `lib/features/authentication/data/repositories/auth_repository_impl.dart`
