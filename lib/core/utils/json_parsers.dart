// The server (PostgreSQL) sometimes sends numbers as strings, e.g. "12" or "150.00".
// These helpers accept both.

int? parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  return int.parse(value.toString());
}

double? parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.parse(value.toString());
}

/// Dates arrive as "2026-11-01", timestamps as "2026-11-01T14:00:00.000Z".
DateTime? parseDate(dynamic value) {
  if (value == null) return null;
  return DateTime.parse(value.toString()).toLocal();
}
