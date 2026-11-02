import 'package:intl/intl.dart';

final _grouped = NumberFormat('#,##0', 'en_US');

/// `12500` → `12,500` (Western digits, as in the design).
String fmtNum(num n) => _grouped.format(n.round());

/// `19/8/2026`, or `—` when there is no date.
String fmtDate(DateTime? d) =>
    d == null ? '—' : '${d.day}/${d.month}/${d.year}';

/// `09:40`.
String fmtTime(DateTime? d) => d == null ? '' : DateFormat('HH:mm').format(d);

/// `2026-11-01`: how the server wants dates sent.
String apiDate(DateTime d) => DateFormat('yyyy-MM-dd', 'en_US').format(d);

bool isSameDay(DateTime? a, DateTime b) =>
    a != null && a.year == b.year && a.month == b.month && a.day == b.day;
