import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hotel_managemnt_app/features/assistant/domain/entities/assistant_card.dart';
import 'package:hotel_managemnt_app/features/assistant/domain/entities/assistant_reply.dart';
import 'package:hotel_managemnt_app/features/assistant/presentation/controllers/assistant_controller.dart';
import 'package:hotel_managemnt_app/features/assistant/presentation/screens/assistant_screen.dart';
import 'package:hotel_managemnt_app/features/assistant/presentation/widgets/chat_widgets.dart';

/// Starts the screen with a ready-made conversation, no server involved.
class _Preset extends AssistantController {
  _Preset(this.turns);

  final List<ChatTurn> turns;

  @override
  List<ChatTurn> build() => turns;
}

final _today = DateTime.now();
final _day = DateTime(_today.year, _today.month, _today.day);
final _month = AssistantPeriod(
  from: DateTime(_today.year, _today.month),
  to: _day,
);

ChatTurn _turn(
  String q,
  AssistantCard? card, {
  String text = 'دخلنا من 1 لـ 15 بالشهر هو 4350 دولار و6,250,000 دينار عراقي، وهذا أعلى من الشهر الماضي.',
  ReplyPhase phase = ReplyPhase.done,
  AssistantPeriod? period,
}) => ChatTurn(
  question: q,
  answer: AssistantAnswer(
    phase: phase,
    card: card,
    text: text,
    period: period ?? _month,
    lang: AssistantLang.iraqi,
  ),
);

const _rooms = [
  '101',
  '102',
  '103',
  '104',
  '105',
  '106',
  '107',
  '108',
  '109',
  '110',
  '201',
  '202',
  '203',
  '204',
  '205',
  '206',
  '207',
  '208',
  '209',
  '210',
];

final _allCards = <ChatTurn>[
  _turn(
    'شكد دخلنا هالشهر؟',
    const MoneyCard(
      kind: MoneyKind.revenue,
      revenue: Money(usd: 4350, iqd: 6250000),
      expenses: Money.zero,
      net: Money.zero,
      count: 31,
    ),
  ),
  _turn(
    'شكد الربح؟',
    const MoneyCard(
      kind: MoneyKind.profit,
      revenue: Money(usd: 125000, iqd: 98000000),
      expenses: Money(usd: 132000, iqd: 12000000),
      net: Money(usd: -7000, iqd: 86000000),
    ),
  ),
  _turn(
    'شكو غرف فارغة هسه؟',
    const OccupancyCard(
      isLive: true,
      totalRooms: 40,
      percent: 55,
      occupied: 22,
      booked: 5,
      free: 11,
      outOfService: 2,
      freeRooms: _rooms,
    ),
    period: AssistantPeriod(from: _day, to: _day),
  ),
  _turn(
    'الإشغال هالأسبوع؟',
    const OccupancyCard(
      isLive: false,
      totalRooms: 40,
      percent: 54,
      days: 7,
      bookedRoomNights: 150,
    ),
  ),
  _turn(
    'منو واصل اليوم؟',
    MovementsCard(
      arrivals: true,
      more: true,
      items: [
        for (var i = 0; i < 8; i++)
          Movement(
            guest: i.isEven
                ? 'عبد الرحمن وليد العبيدي الطويل الاسم جداً'
                : 'سارة',
            rooms: i.isEven ? _rooms.sublist(0, 6) : ['5'],
            checkIn: _day,
            checkOut: _day.add(const Duration(days: 3)),
            nights: 3,
            isGroup: i.isEven,
            status: 'Confirmed',
          ),
      ],
    ),
  ),
  _turn(
    'شكد الديون؟',
    const DebtsCard(
      total: Money(usd: 1200, iqd: 3500000),
      more: false,
      items: [
        GuestDebt(
          guest: 'محمد',
          rooms: ['12'],
          amount: Money(usd: 1200, iqd: 3500000),
          leftHotel: true,
        ),
        GuestDebt(
          guest: '',
          rooms: [],
          amount: Money(usd: 0, iqd: 250000),
          leftHotel: false,
        ),
      ],
    ),
  ),
  _turn(
    'شنو المهام المفتوحة؟',
    const TasksCard(
      open: 9,
      items: [
        OpenTask(
          title: 'تصليح مكيف الغرفة وتغيير الفلتر وتنظيف المجاري',
          rooms: ['301', '302'],
          assignee: 'علي حسن',
          urgent: true,
          inProgress: true,
        ),
        OpenTask(
          title: 'تنظيف',
          rooms: [],
          assignee: null,
          urgent: false,
          inProgress: false,
        ),
      ],
    ),
  ),
  _turn(
    'شنو المواد الناقصة؟',
    const StockCard(
      more: false,
      items: [
        LowStockItem(item: 'مناشف', quantity: 0, min: 20),
        LowStockItem(item: 'صابون', quantity: 4, min: 10),
      ],
    ),
  ),
  _turn('شكد الرواتب؟', null, text: 'هذه المعلومة غير متوفرة حالياً.'),
  _turn(
    'How much did we make today?',
    null,
    text: '',
    phase: ReplyPhase.fetching,
  ),
];

Future<void> _pump(
  WidgetTester tester,
  List<ChatTurn> turns, {
  AssistantStatus status = const AssistantStatus(
    enabled: true,
    ready: true,
    waiting: 0,
  ),
  Size size = const Size(390, 844),
  double textScale = 1,
}) async {
  tester.view.physicalSize = size * 3;
  tester.view.devicePixelRatio = 3;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        assistantControllerProvider.overrideWith(() => _Preset(turns)),
        assistantStatusProvider.overrideWith((ref) async => status),
      ],
      child: ScreenUtilInit(
        designSize: const Size(390, 844),
        minTextAdapt: true,
        builder: (_, _) => const MaterialApp(
          locale: Locale('ar'),
          supportedLocales: [Locale('ar')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          home: AssistantScreen(),
        ),
      ),
    ),
  );
  // The typing dots and caret repeat forever, so pumpAndSettle would hang.
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Scrolls the conversation from the newest turn to the oldest, so every
/// card is laid out at least once.
Future<void> _scrollAll(WidgetTester tester) async {
  final list = find.byType(Scrollable).first;
  for (var i = 0; i < 40; i++) {
    await tester.drag(list, const Offset(0, 400));
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  // No network in tests: fall back to the default test font.
  GoogleFonts.config.allowRuntimeFetching = false;

  for (final (name, size, scale) in [
    ('phone', const Size(390, 844), 1.0),
    ('small phone, large text', const Size(320, 640), 1.3),
  ]) {
    group(name, () {
      testWidgets('welcome screen', (tester) async {
        await _pump(tester, const [], size: size, textScale: scale);
        expect(find.text('اسألني عن فندقك'), findsOneWidget);
        expect(find.text('شكد دخلنا هالشهر؟'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('every card type, done and pending', (tester) async {
        await _pump(tester, _allCards, size: size, textScale: scale);
        expect(find.text('يجلب البيانات…'), findsOneWidget);
        await _scrollAll(tester);
        expect(tester.takeException(), isNull);
      });
    });
  }

  test('text direction follows the first letter', () {
    expect(textDirectionOf('How much did we spend?'), TextDirection.ltr);
    expect(textDirectionOf('شكد دخلنا هالشهر؟'), TextDirection.rtl);
    expect(textDirectionOf('2026 revenue?'), TextDirection.ltr);
    expect(textDirectionOf('٢٠٢٦ شكد؟'), TextDirection.rtl);
    expect(textDirectionOf(''), TextDirection.rtl);
  });

  testWidgets('an English question bubble reads left to right', (tester) async {
    await _pump(tester, [
      _turn('How much did we spend this month?', null, text: '0 USD.'),
    ]);
    final text = tester.widget<Text>(
      find.text('How much did we spend this month?'),
    );
    expect(text.textDirection, TextDirection.ltr);
  });

  testWidgets('failed answer offers a retry', (tester) async {
    await _pump(tester, [
      const ChatTurn(
        question: 'شكد دخلنا؟',
        answer: AssistantAnswer(
          phase: ReplyPhase.failed,
          error: 'المساعد مشغول الآن بأسئلة أخرى، حاول بعد لحظات.',
        ),
      ),
    ]);
    expect(
      find.text('المساعد مشغول الآن بأسئلة أخرى، حاول بعد لحظات.'),
      findsOneWidget,
    );
    expect(find.text('إعادة'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('switched off on the server: no composer', (tester) async {
    await _pump(
      tester,
      const [],
      status: const AssistantStatus(enabled: false, ready: false, waiting: 0),
    );
    expect(find.text('المساعد غير مفعّل على الخادم حالياً.'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
