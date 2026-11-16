import 'assistant_card.dart';

/// GET /assistant/status.
class AssistantStatus {
  const AssistantStatus({
    required this.enabled,
    required this.ready,
    required this.waiting,
  });

  /// False: the assistant is switched off on the server; hide it.
  final bool enabled;

  /// False: the model is still starting, so the first answer is slow (30-60 s).
  final bool ready;

  /// Questions queued on the server right now.
  final int waiting;
}

/// The dates an answer covers. One day has the same [from] and [to].
class AssistantPeriod {
  const AssistantPeriod({required this.from, required this.to});

  final DateTime from;
  final DateTime to;

  bool get isOneDay => from == to;
}

/// The language the question was asked in, which the answer is written in.
enum AssistantLang { iraqi, arabic, english }

/// What one question was about. [hi], [na] and [off] have no card.
enum AssistantTopic {
  revenue,
  expenses,
  profit,
  occupancy,
  arrivals,
  departures,
  debts,
  tasks,
  stock,

  /// A greeting or thanks.
  hi,

  /// About the hotel, but nothing we have data for yet.
  na,

  /// Not about the hotel.
  off;

  bool get hasData => !(this == hi || this == na || this == off);
}

/// What the server sends while answering, in this order:
/// [AssistantRouted] → [AssistantData] → [AssistantDelta]… → [AssistantDone].
/// Questions without data skip straight from routed to done.
sealed class AssistantEvent {
  const AssistantEvent();
}

/// The question was understood (~2 s in).
class AssistantRouted extends AssistantEvent {
  const AssistantRouted({required this.topic, required this.lang, this.period});

  final AssistantTopic topic;
  final AssistantLang lang;
  final AssistantPeriod? period;
}

/// The numbers are ready: show them before the sentence is written.
class AssistantData extends AssistantEvent {
  const AssistantData({required this.card, this.period});

  final AssistantCard? card;
  final AssistantPeriod? period;
}

/// The next piece of the sentence.
class AssistantDelta extends AssistantEvent {
  const AssistantDelta(this.text);

  final String text;
}

/// The full answer. [answer] can be empty if the model failed after the data
/// was fetched; the card is still correct then.
class AssistantDone extends AssistantEvent {
  const AssistantDone({
    required this.topic,
    required this.lang,
    required this.answer,
    this.card,
    this.period,
  });

  final AssistantTopic topic;
  final AssistantLang lang;
  final String answer;
  final AssistantCard? card;
  final AssistantPeriod? period;
}
