# presentation/controllers/<name>_controller.dart   (e.g. rooms_controller.dart)

## What it is
A Riverpod `Notifier` (or `AsyncNotifier`) that holds the **screen state**
and runs the actions the user triggers.

## What it does
- Holds the state: data (entities), `isLoading`, `errorMessage`, selected filter, ...
- Has methods the UI calls: `loadRooms()`, `createRoom(...)`, `refresh()`.
- Calls the **repository** (`ref.read(roomsRepositoryProvider)`).
- Catches `AppException` and puts `e.message` into the state, so the UI can show it.

## Rules
- Talks to the repository only. **Never** to a data source or `ApiClient`.
- No widgets and no `BuildContext` in here.
- Works with entities, never `Map` or JSON.

## Example
```dart
class RoomsController extends AsyncNotifier<List<Room>> {
  @override
  Future<List<Room>> build() {
    return ref.read(roomsRepositoryProvider).getRooms();
  }

  Future<void> createRoom(String number, int floorId) async {
    await ref.read(roomsRepositoryProvider)
        .createRoom(number: number, floorId: floorId);
    ref.invalidateSelf(); // reload the list
  }
}

final roomsControllerProvider =
    AsyncNotifierProvider<RoomsController, List<Room>>(RoomsController.new);
```

Real example: `lib/features/authentication/presentation/controllers/auth_controller.dart`
