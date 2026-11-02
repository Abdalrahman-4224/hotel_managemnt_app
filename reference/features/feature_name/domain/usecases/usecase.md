# domain/usecases/   (OPTIONAL)

## What it is
One class = one action, for example `CreateRoomUseCase` or `CheckInGuestUseCase`.
It sits between the controller and the repository.

## When to use
- When an action has business rules that combine several repository calls.
  Example: check-in = check the room is available → create booking → mark the room occupied.
- When the same logic is needed in more than one controller.

## When to skip
- When the use case would only call `repository.getRooms()` and return the result.
  Then the controller can call the repository directly.
  **This project skips them for now**, and that is fine.

## Example
```dart
class CreateRoomUseCase {
  final RoomsRepository repository;
  CreateRoomUseCase(this.repository);

  Future<Room> call({required String number, required int floorId}) {
    if (number.trim().isEmpty) throw ArgumentError('Room number is required');
    return repository.createRoom(number: number.trim(), floorId: floorId);
  }
}
```
