import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/data_sources/bookings_local_data_source.dart';
import '../../domain/entities/booking.dart';

enum _Tab { today, upcoming, staying, departed, cancelled }

extension on _Tab {
  String get label => switch (this) {
    _Tab.today => 'اليوم',
    _Tab.upcoming => 'قادمة',
    _Tab.staying => 'مقيمون',
    _Tab.departed => 'مغادرون',
    _Tab.cancelled => 'ملغاة',
  };

  String get note => switch (this) {
    _Tab.today => 'حجوزات تاريخها اليوم: دخول وخروج وإلغاء.',
    _Tab.upcoming => 'حجوزات مؤكدة لم يُسجَّل دخولها بعد.',
    _Tab.staying => 'نزلاء داخل الفندق الآن.',
    _Tab.departed => 'سجّلوا خروجهم — كل خروج ينشئ مهمة تنظيف تلقائياً.',
    _Tab.cancelled => 'الحجوزات الملغاة تبقى في السجل للمراجعة.',
  };
}

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  final _bookings = const BookingsLocalDataSource().getBookings();
  final _statusOverrides = <String, BookingStatus>{};
  var _tab = _Tab.today;

  BookingStatus _st(Booking b) => _statusOverrides[b.id] ?? b.status;

  bool _matches(Booking b, _Tab t) => switch (t) {
    _Tab.today => b.isToday,
    _Tab.upcoming => _st(b).isUpcoming,
    _Tab.staying => _st(b) == BookingStatus.staying,
    _Tab.departed => _st(b) == BookingStatus.departed,
    _Tab.cancelled => _st(b) == BookingStatus.cancelled,
  };

  @override
  Widget build(BuildContext context) {
    final rows = _bookings.where((b) => _matches(b, _tab)).toList();
    final staying = _bookings
        .where((b) => _st(b) == BookingStatus.staying)
        .length;
    final upcoming = _bookings.where((b) => _st(b).isUpcoming).length;

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              NzPageHeader(
                showBack: Navigator.of(context).canPop(),
                subtitle: '$staying مقيمون الآن · $upcoming قادمون',
                title: 'سجل الحجوزات',
                actions: [
                  NzOutlineButton(
                    label: 'الحملات',
                    icon: LucideIcons.users,
                    height: 44,
                    radius: 14,
                    fontSize: 14,
                    onPressed: () => context.push(AppRoutes.campaigns),
                  ),
                  NzIconButton(
                    icon: LucideIcons.search,
                    tooltip: 'بحث',
                    onPressed: () {},
                  ),
                ],
                bottomBleeds: true,
                bottom: Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: NzPillScroller(
                    children: [
                      for (final t in _Tab.values)
                        NzChoicePill(
                          label: t.label,
                          count:
                              '${_bookings.where((b) => _matches(b, t)).length}',
                          selected: _tab == t,
                          onTap: () => setState(() => _tab = t),
                        ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    14,
                    16,
                    NzBottomNav.bodyPadding(context) + 76,
                  ),
                  children: [
                    Text(
                      _tab.note,
                      style: AppText.body(
                        13,
                        color: AppColors.inkMuted,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (rows.isEmpty)
                      NzDashedBox(
                        child: Text(
                          'لا حجوزات في هذا التصنيف.',
                          textAlign: TextAlign.center,
                          style: AppText.body(14, color: AppColors.inkMuted),
                        ),
                      )
                    else ...[
                      NzCard(
                        radius: 18,
                        shadow: AppShadows.card,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const NzTableHead(
                              cells: [
                                ('رقم', null, 48, TextAlign.start),
                                ('النزيل · الغرفة', 1, null, TextAlign.start),
                                ('الحالة', null, 66, TextAlign.start),
                                ('المبلغ', null, 80, TextAlign.end),
                              ],
                            ),
                            for (var i = 0; i < rows.length; i++) ...[
                              if (i > 0) const NzDivider(),
                              _BookingRow(
                                booking: rows[i],
                                status: _st(rows[i]),
                                highlight:
                                    _tab != _Tab.today && rows[i].isToday,
                                onTap: () => _open(rows[i]),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'اضغط على اسم النزيل لعرض الحجز وإجراءاته.',
                        textAlign: TextAlign.center,
                        style: AppText.body(12.5, color: AppColors.inkFaint),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          PositionedDirectional(
            end: 16,
            bottom: NzBottomNav.fabBottom(context),
            child: NzFloatingButton(
              label: 'حجز جديد',
              onPressed: () => context.push(AppRoutes.addBooking),
            ),
          ),
        ],
      ),
    );
  }

  void _open(Booking b) {
    final st = _st(b);
    showNzSheet<void>(
      context,
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 30),
      gap: 8,
      builder: (ctx) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(text: 'حجز #'),
                          TextSpan(
                            text: b.id,
                            style: AppText.num(
                              12.5,
                              weight: FontWeight.w400,
                              color: AppColors.inkMuted,
                            ),
                          ),
                          TextSpan(text: ' · ${b.kind}'),
                        ],
                      ),
                      style: AppText.body(12.5, color: AppColors.inkMuted),
                    ),
                    const SizedBox(height: 2),
                    Text(b.guest, style: AppText.display(21)),
                  ],
                ),
              ),
              BookingStatusTag(st),
            ],
          ),
          const SizedBox(height: 16),
          NzGrid(
            columns: 2,
            children: [
              _Fact('الغرف', b.rooms),
              _Fact('النوع', b.kind),
              _Fact('الدخول', b.checkIn),
              _Fact('الخروج', b.checkOut),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _Total('الإجمالي · دولار', b.usd)),
              const SizedBox(width: 8),
              Expanded(
                child: _Total(
                  'الإجمالي · دينار',
                  b.iqd,
                  color: AppColors.goldLight,
                ),
              ),
            ],
          ),
          if (b.isGroup) ...[
            const SizedBox(height: 14),
            NzOutlineButton(
              label: 'متابعة الحملة وتوزيع الأفراد',
              height: 48,
              radius: 14,
              fontSize: 14.5,
              weight: FontWeight.w600,
              background: AppColors.goldTint,
              foreground: AppColors.goldDarkest,
              borderColor: const Color(0x66B68235),
              onPressed: () {
                Navigator.of(ctx).pop();
                context.push(AppRoutes.campaigns);
              },
            ),
          ],
          const SizedBox(height: 16),
          const NzDivider(),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: NzOutlineButton(
                  label: 'إغلاق',
                  height: 54,
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: NzPrimaryButton(
                  label: st.action,
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    final next = st.next;
                    if (next != null) {
                      setState(() => _statusOverrides[b.id] = next);
                    } else if (st == BookingStatus.departed) {
                      context.push(AppRoutes.invoice);
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BookingStatusTag extends StatelessWidget {
  const BookingStatusTag(this.status, {super.key, this.small = false});

  final BookingStatus status;
  final bool small;

  @override
  Widget build(BuildContext context) {
    return NzTag(
      status.label,
      height: small ? 24 : 26,
      fontSize: small ? 11.5 : 12,
      tone: status == BookingStatus.staying
          ? NzTagTone.dark
          : status.isUpcoming
          ? NzTagTone.gold
          : NzTagTone.neutral,
    );
  }
}

class _BookingRow extends StatelessWidget {
  const _BookingRow({
    required this.booking,
    required this.status,
    required this.highlight,
    required this.onTap,
  });

  final Booking booking;
  final BookingStatus status;
  final bool highlight;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final b = booking;
    return Semantics(
      button: true,
      label: '${b.guest} — حجز ${b.id}',
      child: InkWell(
        onTap: onTap,
        child: Container(
          color: highlight ? const Color(0xFFFFFAF0) : null,
          constraints: const BoxConstraints(minHeight: 58),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              SizedBox(
                width: 48,
                child: Text(
                  b.id,
                  style: AppText.num(13, color: AppColors.ink3, height: 1),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      b.guest,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.body(14, weight: FontWeight.w600),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Container(
                          height: 18,
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          decoration: BoxDecoration(
                            color: b.isGroup ? AppColors.ink : AppColors.inert,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            b.kind,
                            style: AppText.body(
                              10.5,
                              weight: FontWeight.w600,
                              color: b.isGroup
                                  ? AppColors.goldLight
                                  : AppColors.ink3,
                              height: 1,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            b.rooms,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.num(
                              12,
                              weight: FontWeight.w400,
                              color: AppColors.inkMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 66,
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: BookingStatusTag(status, small: true),
                ),
              ),
              SizedBox(
                width: 80,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(b.amount, style: AppText.num(13.5, height: 1.3)),
                    Text(
                      b.currency,
                      style: AppText.body(11, color: AppColors.inkFaint),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return NzCard(
      radius: 14,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppText.body(12, color: AppColors.inkMuted)),
          const SizedBox(height: 3),
          Text(value, style: AppText.num(14.5, weight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _Total extends StatelessWidget {
  const _Total(this.label, this.value, {this.color = AppColors.onInk});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return NzCard(
      color: AppColors.ink,
      borderColor: null,
      radius: 16,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppText.body(12, color: AppColors.onInkMuted)),
          Text(value, style: AppText.num(20, color: color, height: 1.3)),
        ],
      ),
    );
  }
}
