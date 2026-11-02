import 'package:flutter/foundation.dart';

import '../../../../core/utils/formatters.dart';
import '../../domain/entities/finance_transaction.dart';
import '../../domain/repositories/finance_repository.dart';

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
      inPeriod(t) &&
      (kind == null || t.kind == kind) &&
      (currency == null || t.currency == currency) &&
      (method == null || t.method == method);

  bool inPeriod(FinanceTransaction t) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return switch (period) {
      Period.today => !t.when.isBefore(today),
      Period.week => !t.when.isBefore(today.subtract(const Duration(days: 6))),
      Period.month => t.when.year == now.year && t.when.month == now.month,
      Period.all => true,
    };
  }

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

const _months = [
  'كانون الثاني', 'شباط', 'آذار', 'نيسان', 'أيار', 'حزيران', //
  'تموز', 'آب', 'أيلول', 'تشرين الأول', 'تشرين الثاني', 'كانون الأول',
];

class FinanceController extends ChangeNotifier {
  FinanceController({required this.repository});

  final FinanceRepository repository;
  List<FinanceTransaction> _rows = const [];
  var _filter = const FinanceFilter();

  // First load state. After that, the old rows stay on screen while reloading.
  var isLoading = true;
  Object? error;

  /// Loads the rows from the server. Errors are kept in [error].
  Future<void> load() async {
    try {
      _rows = await repository.getTransactions();
      error = null;
    } catch (e) {
      error = e;
    }
    isLoading = false;
    notifyListeners();
  }

  /// Income, expense and net for the chosen period, per currency.
  FinanceTotals get totals {
    double sum(TxKind kind, TxCurrency currency) => _rows
        .where(
          (t) =>
              _filter.inPeriod(t) && t.kind == kind && t.currency == currency,
        )
        .fold(0, (n, t) => n + t.value);
    final inUsd = sum(TxKind.income, TxCurrency.usd);
    final inIqd = sum(TxKind.income, TxCurrency.iqd);
    final outUsd = sum(TxKind.expense, TxCurrency.usd);
    final outIqd = sum(TxKind.expense, TxCurrency.iqd);
    String net(double v) => v < 0 ? '−${fmtNum(-v)}' : fmtNum(v);
    return FinanceTotals(
      incomeUsd: fmtNum(inUsd),
      incomeIqd: fmtNum(inIqd),
      expenseUsd: fmtNum(outUsd),
      expenseIqd: fmtNum(outIqd),
      netUsd: net(inUsd - outUsd),
      netIqd: net(inIqd - outIqd),
    );
  }

  FinanceFilter get filter => _filter;

  List<FinanceTransaction> get rows =>
      _rows.where(_filter.matches).toList(growable: false);

  /// Number of rows each kind tab would show with the other filters.
  int countFor(TxKind? kind) =>
      _rows.where(_filter.copyWith(kind: () => kind).matches).length;

  /// Rows a draft filter (from the filter sheet) would produce.
  int countForDraft(FinanceFilter draft) =>
      _rows.where(draft.copyWith(kind: () => _filter.kind).matches).length;

  String get periodLine {
    final now = DateTime.now();
    final month = '${_months[now.month - 1]} ${now.year}';
    return 'الفترة: ${_filter.period == Period.month ? month : _filter.period.label}';
  }

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

  /// Records the correcting entry: same amount, opposite direction.
  /// Errors are rethrown so the sheet can show them.
  Future<void> reverse(FinanceTransaction t) async {
    await repository.addTransaction(
      NewTransaction(
        kind: t.isIncome ? TxKind.expense : TxKind.income,
        reference: 'عكس: ${t.reference}',
        method: t.method,
        amount: t.value,
        currency: t.currency,
        bookingId: t.bookingId,
      ),
    );
    await load();
  }

  Future<void> add(NewTransaction t) async {
    await repository.addTransaction(t);
    _filter = FinanceFilter(period: _filter.period);
    await load();
  }

  void _set(FinanceFilter f) {
    _filter = f;
    notifyListeners();
  }
}
