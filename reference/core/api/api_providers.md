# core/api/api_providers.dart

## What it is
The Riverpod providers that create `ApiClient` (and what it needs, such as `TokenStorage`).

## What it does
- `apiClientProvider` → builds one `ApiClient` for the whole app.
- Data source providers read it:
  ```dart
  final apiClient = ref.watch(apiClientProvider);
  ```

## Why it is a provider
- You create it in one place and share it everywhere.
- In tests you can replace it with a fake client using `overrideWithValue`.
