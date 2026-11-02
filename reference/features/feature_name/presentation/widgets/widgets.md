# presentation/widgets/<name>_widgets.dart   (e.g. room_widgets.dart)

## What it is
Small, reusable UI parts that **only this feature** uses (`RoomCard`, `FloorTabs`, `RoomStatusBadge`).

## Rules
- Takes **entities** and callbacks as parameters:
  ```dart
  RoomCard(room: room, onTap: () => ...)
  ```
- Usually doesn't read providers itself. The screen passes the data in.
  This keeps widgets simple and easy to reuse.
- If more than one feature needs a widget, move it to `lib/core/widgets/`.
