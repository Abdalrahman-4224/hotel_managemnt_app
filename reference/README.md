# Reference Folder

This folder only holds notes. It is outside `lib/`, so it is not part of the app.
Every file here has the same path as a real file in `lib/` and explains what that file is for.

## Folder layout

```
lib/
├── core/
│   └── api/
│       ├── api_client.dart          → the only place that talks HTTP
│       └── api_providers.dart       → Riverpod providers for ApiClient
└── features/
    └── <feature_name>/              (rooms, authentication, ...)
        ├── data/                    → HOW data is fetched
        │   ├── data_sources/        → calls the API / local storage
        │   ├── models/              → JSON <-> Dart, converts to entity
        │   └── repositories/        → implements the domain contract
        ├── domain/                  → WHAT the feature can do (pure Dart)
        │   ├── entities/            → the app's clean data classes
        │   ├── repositories/        → abstract contract
        │   └── usecases/            → optional, one action per class
        └── presentation/            → the UI
            ├── controllers/         → state + logic for the screens
            ├── screens/             → full pages
            └── widgets/             → small UI parts for this feature
```

## How data flows

```
Screen ──► Controller ──► Repository (abstract, domain)
                                │
                                ▼ implemented by
                          RepositoryImpl (data)
                                │
                 ┌──────────────┴──────────────┐
                 ▼                             ▼
         RemoteDataSource               LocalDataSource
                 │                             │
                 ▼                             ▼
            ApiClient                   Storage / cache
                 │
                 ▼
             Backend API
```

What each step returns:

| Step                 | Returns                    |
|----------------------|----------------------------|
| ApiClient            | raw JSON (`dynamic`)       |
| DataSource           | `Map` or Model             |
| Model.toEntity()     | Entity                     |
| Repository           | Entity                     |
| Controller           | State that holds Entities  |
| Screen               | Widgets                    |

## Import rules

- `domain/` imports **nothing** from `data/` or `presentation/`, and never imports Flutter or Dio.
- `data/` imports `domain/` (to implement the contract and build entities).
- `presentation/` imports `domain/` entities and the repository **provider**.
- Only `ApiClient` knows about Dio and HTTP.

## Steps to add a new feature

1. `domain/entities/` → create the entity
2. `domain/repositories/` → write the abstract contract
3. `data/models/` → model with `fromJson` / `toJson` / `toEntity`
4. `data/data_sources/` → API calls using `ApiClient`
5. `data/repositories/` → `XRepositoryImpl` + its provider
6. `presentation/controllers/` → Notifier that uses the repository
7. `presentation/screens/` + `widgets/` → UI that watches the controller

The real feature to copy from is `lib/features/authentication/`.
