# data/data_sources/<name>_remote_data_source.dart   (e.g. rooms_remote_data_source.dart)

## What it is
The class that makes the **actual API calls** for this feature, using `ApiClient`.

## What it does
- Knows the endpoint paths: `/rooms`, `/floors`, `/rooms/:id`.
- Calls `apiClient.get/post/put/delete`.
- Returns **raw data**: `Map<String, dynamic>` / `List<Map>`.
  (It may also return models. Pick one style and use it everywhere.)

## What it does NOT do
- No entities, no business rules, no saving tokens, no UI state.
- No try/catch for showing messages. `ApiClient` already throws `AppException`.

## Example
```dart
class RoomsRemoteDataSource {
  final ApiClient apiClient;
  RoomsRemoteDataSource(this.apiClient);

  Future<List<Map<String, dynamic>>> fetchRooms() async {
    final data = await apiClient.get('/rooms');
    return List<Map<String, dynamic>>.from(data);
  }

  Future<Map<String, dynamic>> createRoom(Map<String, dynamic> body) async {
    return await apiClient.post('/rooms', data: body);
  }
}

final roomsRemoteDataSourceProvider = Provider<RoomsRemoteDataSource>((ref) {
  return RoomsRemoteDataSource(ref.watch(apiClientProvider));
});
```

## Who uses it
Only the repository impl. **Never** the controller or a screen.

Real examples:
- `lib/features/authentication/data/data_sources/auth_remote_data_source.dart`
- `lib/features/rooms/data/data_sources/rooms_data_source.dart`
