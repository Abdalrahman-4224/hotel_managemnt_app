# data/data_sources/<name>_local_data_source.dart   (e.g. rooms_local_data_source.dart)

## What it is
Reads and writes data **on the device**: cache, SharedPreferences, secure storage, Hive, etc.

## What it does
- Saves the last data fetched, so the screen can show something offline or load faster.
- Reads it back.
- Clears it (for example on logout).

## Rules
- Works with JSON/`Map` or models, not entities.
- Knows nothing about the API.

## Who uses it
Only the repository impl. The **repository decides** when to use remote and when to use local.
Example: "try the API, and if it fails, return the cached rooms."
