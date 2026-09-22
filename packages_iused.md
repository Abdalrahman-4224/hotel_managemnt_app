State Management & DI

✅ Riverpod (you got this)
➕ GetIt — dependency injection for repositories, use cases, data sources

dart
// main.dart setup
final getIt = GetIt.instance;
getIt.registerSingleton<AuthRepository>(AuthRepositoryImpl(...));

// in your usecase
class LoginUser {
  final AuthRepository repo = getIt<AuthRepository>();
}

Why: keeps your controller code clean. Riverpod watches state, GetIt provides dependencies.

Models & Serialization

✅ Freezed — auto-generate immutable classes, copyWith, equality

dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String email,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

Then final newUser = user.copyWith(email: 'new@email.com'); works automatically.

✅ json_serializable — auto generates fromJson / toJson (Freezed uses this under the hood)

Why: less boilerplate, no null errors, copyWith is free.

Responsive UI

✅ flutter_screenutil — scale fonts, sizes, padding to any screen

dart
import 'package:flutter_screenutil/flutter_screenutil.dart';

// In main.dart
ScreenUtilInit(
  designSize: const Size(390, 844), // your figma/design file size
  builder: () => MyApp(),
);

// In any widget
Text('Hello', style: TextStyle(fontSize: 16.sp)); // scales automatically
SizedBox(height: 20.h); // height scales

Why: one code, looks good on phone, tablet, iPad. .sp = scale percentage.

Local Storage

Pick one:

Hive (simple key-value, fast)

dart
final box = Hive.box('auth');
box.put('token', 'xyz123');
final token = box.get('token');

SQLite (structured data, relations)

dart
final db = await openDatabase('app.db');
await db.insert('users', {'id': 1, 'email': '...'});

Why Hive for you: you're already using Riverpod. Hive + Riverpod is simple. Use SQLite only if your data has complex relationships.

UI Polish

✅ flutter_animate — smooth transitions, fades, slides

dart
MyWidget()
  .animate()
  .fadeIn(duration: 600.ms)
  .slide(begin: Offset(0, .2))

✅ lottie — animated icons, loaders (use sparingly)

✅ Material Design 3 — already built-in, just use useMaterial3: true in your theme

Why: smooth animations = users feel the app is polished.

API & Error Handling

✅ Dio (you got this)
➕ Dio + Interceptors — auto-handle token refresh, logging, retries

dart
dio.interceptors.add(
  InterceptorsWrapper(
    onRequest: (options, handler) {
      options.headers['Authorization'] = 'Bearer $token';
      return handler.next(options);
    },
    onError: (error, handler) async {
      if (error.response?.statusCode == 401) {
        // refresh token logic
      }
      return handler.next(error);
    },
  ),
);
Code Quality

✅ Linting — create analysis_options.yaml

yaml
linter:
  rules:
    - avoid_empty_else
    - avoid_print
    - prefer_const_constructors
    - prefer_final_variables

Why: catches bad patterns before runtime.

✅ Build Runner — generates code automatically

bash
flutter pub run build_runner watch

Runs whenever you save a .freezed.dart or .g.dart file.

Testing (later)
dart
// mocktail for mocking
import 'package:mocktail/mocktail.dart';

// flutter_test (built-in)
testWidgets('login shows error', (tester) async {
  await tester.pumpWidget(MyApp());
  // ...
});
Your final pubspec.yaml essentials
yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State & navigation
  riverpod: ^latest
  go_router: ^latest
  get_it: ^latest
  
  # Dio & networking
  dio: ^latest
  
  # Models & serialization
  freezed_annotation: ^latest
  json_annotation: ^latest
  
  # UI
  flutter_screenutil: ^latest
  flutter_animate: ^latest
  
  # Local storage
  hive: ^latest
  hive_flutter: ^latest

dev_dependencies:
  build_runner: ^latest
  freezed: ^latest
  json_serializable: ^latest
The order to learn them:
Freezed first — it's a pain to set up, smooth sailing after
ScreenUtil next — test on 3 devices immediately
GetIt — use it for repositories (small win)
flutter_animate — polish screens as you go
Hive — add when you need persistence (login tokens, cache)
One file to start: core/di/service_locator.dart
dart
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  // Data sources
  getIt.registerSingleton(AuthRemoteDataSource(getIt<Dio>()));
  
  // Repositories
  getIt.registerSingleton<AuthRepository>(
    AuthRepositoryImpl(getIt<AuthRemoteDataSource>()),
  );
  
  // Use cases
  getIt.registerSingleton(LoginUser(getIt<AuthRepository>()));
}

Then in main.dart: setupServiceLocator(); before runApp().