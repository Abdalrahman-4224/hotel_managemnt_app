# presentation/screens/<name>_screen.dart   (e.g. rooms_screen.dart)

## What it is
A full page (a route in `core/routes/app_router.dart`).

## What it does
- `ref.watch(roomsControllerProvider)` → rebuilds when the state changes.
- Shows loading, error, or data.
- On user actions it calls controller methods:
  `ref.read(roomsControllerProvider.notifier).createRoom(...)`.
- Builds the page from widgets in `widgets/` and shared widgets in `core/widgets/` (`Nz...`).

## Rules
- No API calls, no JSON, and no repository or data source calls directly.
- Keep it thin. Logic goes in the controller, big UI parts go in `widgets/`.

## Example
```dart
final rooms = ref.watch(roomsControllerProvider);
return rooms.when(
  loading: () => const Center(child: CircularProgressIndicator()),
  error: (e, _) => Text(e.toString()),
  data: (list) => ListView(children: [for (final r in list) RoomCard(room: r)]),
);
```
