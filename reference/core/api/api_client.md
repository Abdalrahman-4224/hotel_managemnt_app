# core/api/api_client.dart

## What it is
The **only** class in the app that knows about HTTP and Dio.
Every feature uses it. It belongs to no single feature.

## What it does
- Holds the base URL (from `core/constants/app_constants.dart`).
- Adds headers, for example `Authorization: Bearer <token>` from `TokenStorage`.
- Gives simple methods: `get(path)`, `post(path, data:)`, `put(path, data:)`, `delete(path)`.
- Turns Dio and HTTP errors into `AppException` (`core/errors/app_exception.dart`),
  so the rest of the app never sees a `DioException`.
- Returns the raw JSON body (`dynamic`).

## What it does NOT do
- It doesn't know endpoint names like `/rooms`. Data sources pass those in.
- It doesn't build models or entities.

## Who uses it
Only **data sources** (`features/*/data/data_sources/`).
