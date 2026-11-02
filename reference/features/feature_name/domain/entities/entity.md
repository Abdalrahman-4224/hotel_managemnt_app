# domain/entities/<name>.dart   (e.g. room.dart)

## What it is
The **clean** Dart class the whole app works with. Pure Dart.

## Rules
- No `fromJson` or `toJson`. JSON belongs to the model.
- No imports from Flutter, Dio, Riverpod, or `data/`.
- Uses the app's names, not the backend's (`fullName`, not `full_name`).
- Can have small helper getters about its own data:
  ```dart
  bool get isAvailable => status == 'available';
  ```

## Example
```dart
class Room {
  final int id;
  final String number;
  final int floorId;
  final String status;

  const Room({
    required this.id,
    required this.number,
    required this.floorId,
    required this.status,
  });

  bool get isAvailable => status == 'available';
}
```

## Who uses it
The repository (both contract and impl), the controller, and the screens/widgets.

Real example: `lib/features/authentication/domain/entities/auth_user.dart`
