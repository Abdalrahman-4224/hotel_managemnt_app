# domain/repositories/<name>_repository.dart   (e.g. rooms_repository.dart)

## What it is
The **contract**: an `abstract class` listing everything the feature can do.
It says **WHAT**, never **HOW**.

## Rules
- `abstract class` only, with no code inside the methods.
- Takes and returns **entities** or simple types. Never `Map`, models, or JSON.
- No imports from `data/`, Dio, or Flutter.

## Example
```dart
import '../entities/room.dart';

abstract class RoomsRepository {
  Future<List<Room>> getRooms();
  Future<List<Floor>> getFloors();
  Future<Room> createRoom({required String number, required int floorId});
}
```

## Why have it
- The controller depends on this, not on the API, so the UI never touches JSON.
- You can swap the implementation (real API, cache, fake for tests)
  without changing the UI.

## Who implements it
`data/repositories/<name>_repository_impl.dart`

Real example: `lib/features/authentication/domain/repositories/auth_repository.dart`
