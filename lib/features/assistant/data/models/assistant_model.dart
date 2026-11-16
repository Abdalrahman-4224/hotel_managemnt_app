import '../../../../core/utils/json_parsers.dart';
import '../../domain/entities/assistant_card.dart';
import '../../domain/entities/assistant_reply.dart';

/// Turns the assistant's JSON into domain objects.
/// Field names follow the backend's ASSISTANT.md.
class AssistantModel {
  const AssistantModel._();

  static AssistantStatus status(Map<String, dynamic> json) => AssistantStatus(
    enabled: json['enabled'] == true,
    ready: json['ready'] == true,
    waiting: parseInt(json['waiting']) ?? 0,
  );

  static const _topics = {
    'rev': AssistantTopic.revenue,
    'exp': AssistantTopic.expenses,
    'profit': AssistantTopic.profit,
    'occ': AssistantTopic.occupancy,
    'in': AssistantTopic.arrivals,
    'out': AssistantTopic.departures,
    'debts': AssistantTopic.debts,
    'tasks': AssistantTopic.tasks,
    'stock': AssistantTopic.stock,
    'hi': AssistantTopic.hi,
    'na': AssistantTopic.na,
    'off': AssistantTopic.off,
  };

  /// An unknown type (added on the server later) is shown as "not available".
  static AssistantTopic topic(dynamic type) =>
      _topics[type] ?? AssistantTopic.na;

  static AssistantLang lang(dynamic code) => switch (code) {
    'en' => AssistantLang.english,
    'iq' => AssistantLang.iraqi,
    _ => AssistantLang.arabic,
  };

  static AssistantPeriod? period(dynamic json) {
    if (json is! Map || json['from'] == null || json['to'] == null) return null;
    return AssistantPeriod(
      from: DateTime.parse(json['from']),
      to: DateTime.parse(json['to']),
    );
  }

  static AssistantEvent? event(String name, Map<String, dynamic> data) {
    switch (name) {
      case 'route':
        return AssistantRouted(
          topic: topic(data['type']),
          lang: lang(data['lang']),
          period: period(data['period']),
        );
      case 'data':
        return AssistantData(
          card: card(topic(data['type']), data['card']),
          period: period(data['period']),
        );
      case 'delta':
        return AssistantDelta(data['text']?.toString() ?? '');
      case 'done':
        final t = topic(data['type']);
        return AssistantDone(
          topic: t,
          lang: lang(data['lang']),
          answer: data['answer']?.toString() ?? '',
          card: card(t, data['card']),
          period: period(data['period']),
        );
    }
    return null; // An event this version of the app doesn't know: skip it.
  }

  static AssistantCard? card(AssistantTopic topic, dynamic json) {
    if (json is! Map) return null;
    final c = Map<String, dynamic>.from(json);
    return switch (topic) {
      AssistantTopic.revenue => _money(MoneyKind.revenue, c),
      AssistantTopic.expenses => _money(MoneyKind.expenses, c),
      AssistantTopic.profit => _money(MoneyKind.profit, c),
      AssistantTopic.occupancy => _occupancy(c),
      AssistantTopic.arrivals => _movements(true, c),
      AssistantTopic.departures => _movements(false, c),
      AssistantTopic.debts => _debts(c),
      AssistantTopic.tasks => _tasks(c),
      AssistantTopic.stock => _stock(c),
      _ => null,
    };
  }

  static Money _amount(dynamic json) {
    if (json is! Map) return Money.zero;
    return Money(
      usd: parseDouble(json['USD']) ?? 0,
      iqd: parseDouble(json['IQD']) ?? 0,
    );
  }

  static List<String> _strings(dynamic list) =>
      list is List ? [for (final x in list) x.toString()] : const [];

  static List<Map<String, dynamic>> _rows(dynamic list) => list is List
      ? [for (final x in list) Map<String, dynamic>.from(x as Map)]
      : const [];

  static MoneyCard _money(MoneyKind kind, Map<String, dynamic> c) => MoneyCard(
    kind: kind,
    revenue: _amount(c['revenue']),
    expenses: _amount(c['expenses']),
    net: _amount(c['net']),
    count: parseInt(c['count']),
  );

  static OccupancyCard _occupancy(Map<String, dynamic> c) => OccupancyCard(
    isLive: c['basis'] == 'live',
    totalRooms: parseInt(c['total_rooms']) ?? 0,
    percent: parseInt(c['occupancy_percent']) ?? 0,
    occupied: parseInt(c['occupied']),
    booked: parseInt(c['booked']),
    free: parseInt(c['free']),
    outOfService: parseInt(c['out_of_service']),
    reserved: parseInt(c['reserved']),
    days: parseInt(c['days']),
    bookedRoomNights: parseInt(c['booked_room_nights']),
    freeRooms: _strings(c['free_rooms']),
  );

  static MovementsCard _movements(bool arrivals, Map<String, dynamic> c) {
    final rows = _rows(c[arrivals ? 'arrivals' : 'departures']);
    return MovementsCard(
      arrivals: arrivals,
      more: c['more'] == true,
      items: [
        for (final r in rows)
          Movement(
            guest: r['guest']?.toString() ?? '—',
            rooms: _strings(r['rooms']),
            checkIn: parseDate(r['check_in']),
            checkOut: parseDate(r['check_out']),
            nights: parseInt(r['nights']) ?? 0,
            isGroup: r['group'] == true,
            status: r['status']?.toString() ?? '',
          ),
      ],
    );
  }

  static DebtsCard _debts(Map<String, dynamic> c) => DebtsCard(
    total: _amount(c['total']),
    more: c['more'] == true,
    items: [
      for (final r in _rows(c['debts']))
        GuestDebt(
          guest: r['guest']?.toString() ?? '—',
          rooms: _strings(r['rooms']),
          amount: _amount(r),
          leftHotel: r['left_hotel'] == true,
        ),
    ],
  );

  static TasksCard _tasks(Map<String, dynamic> c) {
    final rows = _rows(c['tasks']);
    return TasksCard(
      open: parseInt(c['open']) ?? rows.length,
      items: [
        for (final r in rows)
          OpenTask(
            title: r['title']?.toString() ?? '—',
            rooms: _strings(r['rooms']),
            assignee: r['assignee']?.toString(),
            urgent: r['urgent'] == true,
            inProgress: r['status'] == 'in_progress',
          ),
      ],
    );
  }

  static StockCard _stock(Map<String, dynamic> c) => StockCard(
    more: c['more'] == true,
    items: [
      for (final r in _rows(c['items']))
        LowStockItem(
          item: r['item']?.toString() ?? '—',
          quantity: parseDouble(r['quantity']) ?? 0,
          min: parseDouble(r['min']) ?? 0,
        ),
    ],
  );
}
