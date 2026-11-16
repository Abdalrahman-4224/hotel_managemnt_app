/// The numbers behind an assistant answer, read straight from the database.
/// These are the figures to trust: the sentence is only the model's wording
/// of them, so the UI always shows the card, with the sentence under it.
sealed class AssistantCard {
  const AssistantCard();
}

/// The two currencies are always kept apart; the server never converts.
class Money {
  const Money({required this.usd, required this.iqd});

  static const zero = Money(usd: 0, iqd: 0);

  final double usd;
  final double iqd;
}

/// `rev`, `exp` and `profit`.
enum MoneyKind { revenue, expenses, profit }

class MoneyCard extends AssistantCard {
  const MoneyCard({
    required this.kind,
    required this.revenue,
    required this.expenses,
    required this.net,
    this.count,
  });

  final MoneyKind kind;
  final Money revenue;
  final Money expenses;

  /// Revenue minus expenses. Only meaningful for [MoneyKind.profit].
  final Money net;

  /// How many transactions the total is made of (revenue / expenses only).
  final int? count;

  /// The figure the card leads with.
  Money get headline => switch (kind) {
    MoneyKind.revenue => revenue,
    MoneyKind.expenses => expenses,
    MoneyKind.profit => net,
  };
}

/// `occ`. Three shapes, depending on what was asked:
/// * today: the live room states ([isLive]), as on the room map
/// * another day: rooms reserved by bookings that day
/// * a period: average occupancy over [days]
class OccupancyCard extends AssistantCard {
  const OccupancyCard({
    required this.isLive,
    required this.totalRooms,
    required this.percent,
    this.occupied,
    this.booked,
    this.free,
    this.outOfService,
    this.reserved,
    this.days,
    this.bookedRoomNights,
    this.freeRooms = const [],
  });

  final bool isLive;
  final int totalRooms;
  final int percent;

  // Live only.
  final int? occupied;
  final int? booked;
  final int? outOfService;

  // One day (live or from bookings).
  final int? free;
  final int? reserved;

  // A period.
  final int? days;
  final int? bookedRoomNights;

  final List<String> freeRooms;

  bool get isPeriod => days != null;
}

/// One booking arriving or leaving.
class Movement {
  const Movement({
    required this.guest,
    required this.rooms,
    required this.checkIn,
    required this.checkOut,
    required this.nights,
    required this.isGroup,
    required this.status,
  });

  final String guest;
  final List<String> rooms;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final int nights;

  /// A campaign (group) booking.
  final bool isGroup;
  final String status;
}

/// `in` (arrivals) and `out` (departures).
class MovementsCard extends AssistantCard {
  const MovementsCard({
    required this.arrivals,
    required this.items,
    required this.more,
  });

  final bool arrivals;
  final List<Movement> items;

  /// The server sends at most 50 rows; true means there are more.
  final bool more;
}

class GuestDebt {
  const GuestDebt({
    required this.guest,
    required this.rooms,
    required this.amount,
    required this.leftHotel,
  });

  final String guest;
  final List<String> rooms;
  final Money amount;

  /// The guest has already checked out.
  final bool leftHotel;
}

/// `debts`: what guests still owe.
class DebtsCard extends AssistantCard {
  const DebtsCard({
    required this.total,
    required this.items,
    required this.more,
  });

  final Money total;
  final List<GuestDebt> items;
  final bool more;
}

class OpenTask {
  const OpenTask({
    required this.title,
    required this.rooms,
    required this.assignee,
    required this.urgent,
    required this.inProgress,
  });

  final String title;
  final List<String> rooms;
  final String? assignee;
  final bool urgent;
  final bool inProgress;
}

/// `tasks`: the open tasks, urgent first.
class TasksCard extends AssistantCard {
  const TasksCard({required this.open, required this.items});

  final int open;
  final List<OpenTask> items;
}

class LowStockItem {
  const LowStockItem({
    required this.item,
    required this.quantity,
    required this.min,
  });

  final String item;
  final double quantity;
  final double min;
}

/// `stock`: items at or below their minimum quantity.
class StockCard extends AssistantCard {
  const StockCard({required this.items, required this.more});

  final List<LowStockItem> items;
  final bool more;
}
