# data/models/<name>_model.dart   (e.g. room_model.dart)

## What it is
The data class that knows the **backend JSON shape**.
It is the only place that knows field names like `room_id` or `floor_id`.

## What it does
- `fromJson(Map)` → builds the model from the API response.
- `toJson()` → builds the request body or saves to local storage.
- `toEntity()` → converts to the domain entity the app uses.

## Rules
- If the backend renames a field, **only this file changes**.
- Use helpers from `core/utils/json_parsers.dart` (for example `parseInt`),
  because the API can send numbers as strings.

## Example
```dart
class RoomModel {
  final int id;
  final String number;
  final int floorId;
  final String status;

  const RoomModel({required this.id, required this.number,
                   required this.floorId, required this.status});

  factory RoomModel.fromJson(Map<String, dynamic> json) => RoomModel(
        id: parseInt(json['room_id'])!,
        number: json['room_number'] ?? '',
        floorId: parseInt(json['floor_id'])!,
        status: json['status'] ?? 'available',
      );

  Map<String, dynamic> toJson() => {
        'room_number': number,
        'floor_id': floorId,
      };

  Room toEntity() =>
      Room(id: id, number: number, floorId: floorId, status: status);
}
```

## Who uses it
The repository impl (and sometimes the data source).

Real example: `lib/features/authentication/data/models/user_model.dart`
