# features/<feature_name>/

Each feature (rooms, authentication, bookings, ...) has the same 3 layers:

| Layer           | Question it answers         | May import                     |
|-----------------|-----------------------------|--------------------------------|
| `domain/`       | WHAT can this feature do?   | nothing (pure Dart)            |
| `data/`         | HOW is data fetched/saved?  | `domain/`, `core/`             |
| `presentation/` | HOW is it shown to the user?| `domain/`, repo provider, `core/` |

The examples in these notes use **rooms**, so the real files would be:
- `domain/entities/room.dart`
- `domain/repositories/rooms_repository.dart`
- `data/models/room_model.dart`
- `data/data_sources/rooms_remote_data_source.dart`
- `data/data_sources/rooms_local_data_source.dart`
- `data/repositories/rooms_repository_impl.dart`
- `presentation/controllers/rooms_controller.dart`
- `presentation/screens/rooms_screen.dart`
- `presentation/widgets/room_widgets.dart`
