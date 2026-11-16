import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotel_managemnt_app/core/api/api_client.dart';
import 'package:hotel_managemnt_app/core/api/api_providers.dart';
import 'package:hotel_managemnt_app/core/storage/token_storage.dart';
import 'package:hotel_managemnt_app/features/assistant/data/models/assistant_model.dart';
import 'package:hotel_managemnt_app/features/assistant/domain/entities/assistant_card.dart';
import 'package:hotel_managemnt_app/features/assistant/domain/entities/assistant_reply.dart';
import 'package:hotel_managemnt_app/features/assistant/presentation/controllers/assistant_controller.dart';

class _FakeTokenStorage extends TokenStorage {
  @override
  Future<String?> read() async => 'test-token';
}

/// Answers every request with [status] and [body], sent in [chunk]-byte
/// pieces so lines and multi-byte Arabic letters arrive split, as on a real
/// connection.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.status, this.body);

  static const chunk = 7;

  final int status;
  final String body;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final bytes = utf8.encode(body);
    final pieces = [
      for (var i = 0; i < bytes.length; i += chunk)
        Uint8List.fromList(
          bytes.sublist(i, i + chunk > bytes.length ? bytes.length : i + chunk),
        ),
    ];
    return ResponseBody(
      Stream.fromIterable(pieces),
      status,
      headers: {
        Headers.contentTypeHeader: [
          status == 200 ? 'text/event-stream' : 'application/json',
        ],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

String _sse(List<(String, Object)> events) =>
    events.map((e) => 'event: ${e.$1}\ndata: ${jsonEncode(e.$2)}\n\n').join();

/// Runs one question through the real data source, repository and controller.
Future<(List<ChatTurn>, _FakeAdapter)> _ask(
  _FakeAdapter adapter, {
  List<String> questions = const ['شكد دخلنا هالشهر؟'],
}) async {
  final client = ApiClient(tokenStorage: _FakeTokenStorage());
  client.dio.httpClientAdapter = adapter;
  final container = ProviderContainer(
    overrides: [apiClientProvider.overrideWithValue(client)],
  );
  addTearDown(container.dispose);
  // autoDispose: keep the conversation alive for the test.
  container.listen(assistantControllerProvider, (_, _) {});
  final chat = container.read(assistantControllerProvider.notifier);

  for (final q in questions) {
    chat.send(q);
    while (chat.isBusy) {
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }
  }
  return (container.read(assistantControllerProvider), adapter);
}

const _revCard = {
  'period': {'from': '2026-11-01', 'to': '2026-11-15'},
  'revenue': {'USD': 4350, 'IQD': '6250000.00'},
  'count': 31,
};
const _answer =
    'دخلنا من 1 لـ 15 بالشهر 11 هو 4350 دولار و6,250,000 دينار عراقي.';

void main() {
  test('streams a revenue answer: card, sentence, period', () async {
    final adapter = _FakeAdapter(
      200,
      _sse([
        ('route', {'type': 'rev', 'lang': 'iq', 'period': _revCard['period']!}),
        (
          'data',
          {'type': 'rev', 'period': _revCard['period']!, 'card': _revCard},
        ),
        ('delta', {'text': 'دخلنا'}),
        ('delta', {'text': ' من 1'}),
        (
          'done',
          {
            'type': 'rev',
            'lang': 'iq',
            'period': _revCard['period']!,
            'card': _revCard,
            'answer': _answer,
          },
        ),
      ]),
    );
    final (turns, _) = await _ask(adapter);

    final a = turns.single.answer;
    expect(a.phase, ReplyPhase.done);
    expect(a.topic, AssistantTopic.revenue);
    expect(a.lang, AssistantLang.iraqi);
    expect(a.text, _answer);
    expect(a.period!.from, DateTime(2026, 11, 1));
    expect(a.period!.isOneDay, isFalse);
    final card = a.card as MoneyCard;
    expect(card.headline.usd, 4350);
    expect(card.headline.iqd, 6250000); // sent as a string
    expect(card.count, 31);

    final req = adapter.requests.single;
    expect(req.path, '/assistant/chat');
    expect(req.headers['Authorization'], 'Bearer test-token');
    expect(req.data, {
      'message': 'شكد دخلنا هالشهر؟',
      'stream': true,
      'reset': true,
    });
  });

  test('only the first question of a chat resets the server memory', () async {
    final adapter = _FakeAdapter(
      200,
      _sse([
        ('route', {'type': 'hi', 'lang': 'iq', 'period': null}),
        (
          'done',
          {
            'type': 'hi',
            'lang': 'iq',
            'period': null,
            'card': null,
            'answer': 'هلا بيك',
          },
        ),
      ]),
    );
    final (turns, _) = await _ask(adapter, questions: ['هلو', 'وباجر؟']);

    expect(turns, hasLength(2));
    expect([for (final r in adapter.requests) r.data['reset']], [true, false]);
    expect(turns.last.answer.card, isNull);
    expect(turns.last.answer.text, 'هلا بيك');
  });

  test('an error status before the stream shows the server message', () async {
    final adapter = _FakeAdapter(
      429,
      jsonEncode({
        'success': false,
        'code': 'busy',
        'message': 'المساعد مشغول الآن بأسئلة أخرى، حاول بعد لحظات.',
      }),
    );
    final (turns, _) = await _ask(adapter);

    expect(turns.single.answer.phase, ReplyPhase.failed);
    expect(
      turns.single.answer.error,
      'المساعد مشغول الآن بأسئلة أخرى، حاول بعد لحظات.',
    );
  });

  test('an error event mid-stream keeps the card already shown', () async {
    final adapter = _FakeAdapter(
      200,
      _sse([
        ('route', {'type': 'rev', 'lang': 'iq', 'period': _revCard['period']!}),
        (
          'data',
          {'type': 'rev', 'period': _revCard['period']!, 'card': _revCard},
        ),
        (
          'error',
          {
            'success': false,
            'code': 'unavailable',
            'message': 'المساعد غير متاح حالياً، حاول بعد قليل.',
          },
        ),
      ]),
    );
    final (turns, _) = await _ask(adapter);

    final a = turns.single.answer;
    expect(a.phase, ReplyPhase.failed);
    expect(a.error, 'المساعد غير متاح حالياً، حاول بعد قليل.');
    expect(a.card, isA<MoneyCard>());
  });

  test('an empty final sentence keeps the streamed text', () async {
    final adapter = _FakeAdapter(
      200,
      _sse([
        ('data', {'type': 'rev', 'period': null, 'card': _revCard}),
        ('delta', {'text': 'دخلنا 4350 دولار'}),
        ('done', {'type': 'rev', 'lang': 'iq', 'card': _revCard, 'answer': ''}),
      ]),
    );
    final (turns, _) = await _ask(adapter);
    expect(turns.single.answer.text, 'دخلنا 4350 دولار');
  });

  group('card parsing', () {
    test('live occupancy', () {
      final c = AssistantModel.card(AssistantTopic.occupancy, {
        'period': {'from': '2026-11-15', 'to': '2026-11-15'},
        'basis': 'live',
        'total_rooms': '40',
        'occupied': 22,
        'booked': 5,
        'free': 11,
        'out_of_service': 2,
        'occupancy_percent': 55,
        'free_rooms': ['101', 102],
      }) as OccupancyCard;
      expect(c.isLive, isTrue);
      expect(c.isPeriod, isFalse);
      expect(c.totalRooms, 40);
      expect(c.freeRooms, ['101', '102']);
    });

    test('occupancy over a period', () {
      final c = AssistantModel.card(AssistantTopic.occupancy, {
        'basis': 'bookings',
        'total_rooms': 40,
        'days': 7,
        'booked_room_nights': 150,
        'occupancy_percent': 54,
      }) as OccupancyCard;
      expect(c.isLive, isFalse);
      expect(c.isPeriod, isTrue);
      expect(c.bookedRoomNights, 150);
    });

    test('arrivals', () {
      final c = AssistantModel.card(AssistantTopic.arrivals, {
        'count': 1,
        'more': false,
        'arrivals': [
          {
            'guest': 'عمر خالد',
            'rooms': ['101', '102'],
            'check_in': '2026-11-15',
            'check_out': '2026-11-18',
            'nights': 3,
            'group': true,
            'status': 'Confirmed',
          },
        ],
      }) as MovementsCard;
      expect(c.arrivals, isTrue);
      expect(c.items.single.rooms, ['101', '102']);
      expect(c.items.single.isGroup, isTrue);
      expect(c.items.single.checkIn, DateTime(2026, 11, 15));
    });

    test('debts, tasks and stock', () {
      final d = AssistantModel.card(AssistantTopic.debts, {
        'total': {'USD': 120, 'IQD': 0},
        'count': 1,
        'more': false,
        'debts': [
          {
            'guest': 'سارة',
            'rooms': ['5'],
            'USD': 120,
            'IQD': 0,
            'left_hotel': true,
          },
        ],
      }) as DebtsCard;
      expect(d.total.usd, 120);
      expect(d.items.single.leftHotel, isTrue);

      final t = AssistantModel.card(AssistantTopic.tasks, {
        'open': 3,
        'tasks': [
          {
            'title': 'تنظيف',
            'rooms': [],
            'assignee': null,
            'urgent': true,
            'status': 'in_progress',
          },
        ],
      }) as TasksCard;
      expect(t.open, 3);
      expect(t.items.single.inProgress, isTrue);

      final s = AssistantModel.card(AssistantTopic.stock, {
        'count': 1,
        'more': true,
        'items': [
          {'item': 'مناشف', 'quantity': '2', 'min': 10},
        ],
      }) as StockCard;
      expect(s.items.single.quantity, 2);
      expect(s.more, isTrue);
    });

    test('types without data have no card; unknown types read as na', () {
      expect(AssistantModel.card(AssistantTopic.hi, null), isNull);
      expect(AssistantModel.topic('salaries'), AssistantTopic.na);
    });
  });
}
