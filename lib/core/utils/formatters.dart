import 'package:intl/intl.dart';

final _grouped = NumberFormat('#,##0', 'en_US');

/// `12500` → `12,500` (Western digits, as in the design).
String fmtNum(num n) => _grouped.format(n.round());
