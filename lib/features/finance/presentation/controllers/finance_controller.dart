import 'package:flutter/foundation.dart';

import '../../data/data_sources/finance_local_data_source.dart';
import '../../domain/entities/finance_transaction.dart';

enum Period { today, week, month, all }

extension PeriodLabel on Period {
  String get label => switch (this) {
    Period.today => 'اليوم',
    Period.week => 'هذا الأسبوع',
    Period.month => 'هذا الشهر',
    Period.all => 'كل الفترات',
  };

  String get short => switch (this) {
    Period.today => 'اليوم',
    Period.week => 'الأسبوع',
    Period.month => 'الشهر',
    Period.all => 'الكل',
  };
}

/// Filters applied to the transaction list. `null` means "all".
class FinanceFilter {
  const FinanceFilter({
    this.kind,
    this.currency,
    this.method,
    this.period = Period.month,
  });

  final TxKind? kind;
  final TxCurrency? currency;
  final TxMethod? method;
  final Period period;

  bool matches(FinanceTransaction t) =>
      (kind == null || t.kind == kind) &&
      (currency == null || t.currency == currency) &&
      (method == null || t.method == method);

  FinanceFilter copyWith({
    TxKind? Function()? kind,
    TxCurrency? Function()? currency,
    TxMethod? Function()? method,
    Period? period,
  }) => FinanceFilter(
    kind: kind == null ? this.kind : kind(),
    currency: currency == null ? this.currency : currency(),
    method: method == null ? this.method : method(),
    period: period ?? this.period,
  );
}

class ActiveFilter {
  const ActiveFilter(this.label, this.clear);

  final String label;
  final VoidCallback clear;
}

class TxGroup {
  TxGroup(this.date, this.items);

  final String date;
  final List<FinanceTransaction> items;

  String get countLabel =>
      '${items.length} ${items.length == 1 ? 'حركة' : 'حركات'}';
}

class FinanceController extends ChangeNotifier {
  FinanceController({
    FinanceLocalDataSource source = const FinanceLocalDataSource(),
  }) : totals = source.getTotals(),
       _rows = source.getTransactions();

  final FinanceTotals totals;
  List<FinanceTransaction> _rows;
  var _filter = const FinanceFilter();

  FinanceFilter get filter => _filter;

  List<FinanceTransaction> get rows =>
      _rows.where(_filter.matches).toList(growable: false);

  /// Number of rows each kind tab would show with the other filters.
  int countFor(TxKind? kind) =>
      _rows.where(_filter.copyWith(kind: () => kind).matches).length;

  /// Rows a draft filter (from the filter sheet) would produce.
  int countForDraft(FinanceFilter draft) =>
      _rows.where(draft.copyWith(kind: () => _filter.kind).matches).length;

  String get periodLine =>
      'الفترة: ${_filter.period == Period.month ? 'آب 2026' : _filter.period.label}';

  List<ActiveFilter> get activeFilters => [
    if (_filter.currency != null)
      ActiveFilter(
        _filter.currency!.label,
        () => _set(_filter.copyWith(currency: () => null)),
      ),
    if (_filter.method != null)
      ActiveFilter(
        _filter.method!.label,
        () => _set(_filter.copyWith(method: () => null)),
      ),
    if (_filter.period != Period.month)
      ActiveFilter(
        _filter.period.label,
        () => _set(_filter.copyWith(period: Period.month)),
      ),
  ];

  /// Consecutive rows with the same date, as in the design.
  List<TxGroup> get groups {
    final out = <TxGroup>[];
    for (final r in rows) {
      if (out.isNotEmpty && out.last.date == r.fullDate) {
        out.last.items.add(r);
      } else {
        out.add(TxGroup(r.fullDate, [r]));
      }
    }
    return out;
  }

  void setKind(TxKind? kind) => _set(_filter.copyWith(kind: () => kind));

  void applyFilter(FinanceFilter draft) => _set(
    FinanceFilter(
      kind: _filter.kind,
      currency: draft.currency,
      method: draft.method,
      period: draft.period,
    ),
  );

  void clearFilters() => _set(FinanceFilter(kind: _filter.kind));

  void reverse(FinanceTransaction t) {
    _rows = [t.reversed(), ..._rows];
    notifyListeners();
  }

  void add(FinanceTransaction t) {
    _rows = [t, ..._rows];
    _filter = FinanceFilter(period: _filter.period);
    notifyListeners();
  }

  void _set(FinanceFilter f) {
    _filter = f;
    notifyListeners();
  }
}
