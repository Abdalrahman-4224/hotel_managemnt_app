import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../data/repositories/assistant_repository_impl.dart';
import '../../domain/entities/assistant_card.dart';
import '../../domain/entities/assistant_reply.dart';

/// Where an answer is. The server needs ~2 s to understand the question and
/// ~10 s to write the sentence, so each step gets its own label in the UI.
enum ReplyPhase {
  /// Sent; the server hasn't said what the question is about yet.
  thinking,

  /// Understood; the numbers are being fetched.
  fetching,

  /// The numbers are in; the sentence is being written.
  writing,
  done,
  failed,

  /// The user pressed stop.
  stopped;

  bool get isPending => this == thinking || this == fetching || this == writing;
}

class AssistantAnswer {
  const AssistantAnswer({
    this.phase = ReplyPhase.thinking,
    this.topic,
    this.lang = AssistantLang.arabic,
    this.period,
    this.card,
    this.text = '',
    this.error,
  });

  final ReplyPhase phase;
  final AssistantTopic? topic;
  final AssistantLang lang;
  final AssistantPeriod? period;
  final AssistantCard? card;
  final String text;
  final String? error;

  AssistantAnswer copyWith({
    ReplyPhase? phase,
    AssistantTopic? topic,
    AssistantLang? lang,
    AssistantPeriod? period,
    AssistantCard? card,
    String? text,
    String? error,
  }) => AssistantAnswer(
    phase: phase ?? this.phase,
    topic: topic ?? this.topic,
    lang: lang ?? this.lang,
    period: period ?? this.period,
    card: card ?? this.card,
    text: text ?? this.text,
    error: error ?? this.error,
  );
}

/// One question and its answer.
class ChatTurn {
  const ChatTurn({
    required this.question,
    this.answer = const AssistantAnswer(),
  });

  final String question;
  final AssistantAnswer answer;

  ChatTurn withAnswer(AssistantAnswer answer) =>
      ChatTurn(question: question, answer: answer);
}

/// The conversation on the assistant screen. It lives only while the screen
/// is open: leaving the screen cancels any answer still being written.
class AssistantController extends Notifier<List<ChatTurn>> {
  StreamSubscription<AssistantEvent>? _subscription;

  /// The next question starts a new conversation on the server too.
  var _fresh = true;

  @override
  List<ChatTurn> build() {
    ref.onDispose(() => _subscription?.cancel());
    return const [];
  }

  bool get isBusy => state.isNotEmpty && state.last.answer.phase.isPending;

  void send(String question) {
    final q = question.trim();
    if (q.isEmpty || isBusy) return;
    state = [...state, ChatTurn(question: q)];
    _ask(q);
  }

  /// Asks the last question again after it failed or was stopped.
  void retry() {
    if (state.isEmpty || isBusy) return;
    final q = state.last.question;
    // Only the very first question of the chat resets the server's memory.
    _fresh = state.length == 1;
    state = [...state.sublist(0, state.length - 1), ChatTurn(question: q)];
    _ask(q);
  }

  void stop() {
    if (!isBusy) return;
    _subscription?.cancel();
    _subscription = null;
    _updateAnswer((a) => a.copyWith(phase: ReplyPhase.stopped));
  }

  void newChat() {
    _subscription?.cancel();
    _subscription = null;
    _fresh = true;
    state = const [];
  }

  void _ask(String question) {
    final reset = _fresh;
    _fresh = false;
    _subscription = ref
        .read(assistantRepositoryProvider)
        .ask(question, reset: reset)
        .listen(
          _onEvent,
          onError: (Object error) => _updateAnswer(
            (a) =>
                a.copyWith(phase: ReplyPhase.failed, error: errorText(error)),
          ),
          onDone: () {
            _subscription = null;
            // The stream ended without a "done" event: keep what arrived.
            _updateAnswer(
              (a) => a.phase.isPending ? a.copyWith(phase: ReplyPhase.done) : a,
            );
          },
        );
  }

  void _onEvent(AssistantEvent event) {
    _updateAnswer(
      (a) => switch (event) {
        AssistantRouted(:final topic, :final lang, :final period) => a.copyWith(
          topic: topic,
          lang: lang,
          period: period,
          phase: topic.hasData ? ReplyPhase.fetching : ReplyPhase.thinking,
        ),
        AssistantData(:final card, :final period) => a.copyWith(
          card: card,
          period: period,
          phase: ReplyPhase.writing,
        ),
        AssistantDelta(:final text) => a.copyWith(
          text: a.text + text,
          phase: ReplyPhase.writing,
        ),
        AssistantDone() => a.copyWith(
          topic: event.topic,
          lang: event.lang,
          period: event.period,
          card: event.card,
          // An empty final sentence means the model failed after the data
          // arrived; keep whatever was streamed instead of wiping it.
          text: event.answer.isEmpty ? null : event.answer,
          phase: ReplyPhase.done,
        ),
      },
    );
  }

  void _updateAnswer(AssistantAnswer Function(AssistantAnswer) change) {
    if (state.isEmpty) return;
    final last = state.last;
    state = [
      ...state.sublist(0, state.length - 1),
      last.withAnswer(change(last.answer)),
    ];
  }
}

final assistantControllerProvider =
    NotifierProvider.autoDispose<AssistantController, List<ChatTurn>>(
      AssistantController.new,
    );

/// Whether the assistant is switched on and ready. Checked when the screen opens.
final assistantStatusProvider = FutureProvider.autoDispose<AssistantStatus>((
  ref,
) {
  return ref.read(assistantRepositoryProvider).getStatus();
});
