import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/assistant_card.dart';

/// Lists in a card show this many rows; the rest are summed up in a footer.
const _maxRows = 6;

/// The numbers of an answer, drawn for its type.
class AssistantCardView extends StatelessWidget {
  const AssistantCardView(this.card, {super.key});

  final AssistantCard card;

  @override
  Widget build(BuildContext context) {
    return switch (card) {
      final MoneyCard c => _MoneyView(c),
      final OccupancyCard c => _OccupancyView(c),
      final MovementsCard c => _MovementsView(c),
      final DebtsCard c => _DebtsView(c),
      final TasksCard c => _TasksView(c),
      final StockCard c => _StockView(c),
    };
  }
}

// ---------------------------------------------------------------- money

class _MoneyView extends StatelessWidget {
  const _MoneyView(this.c);

  final MoneyCard c;

  @override
  Widget build(BuildContext context) {
    final (title, icon) = switch (c.kind) {
      MoneyKind.revenue => ('الإيرادات', LucideIcons.trendingUp),
      MoneyKind.expenses => ('المصروفات', LucideIcons.trendingDown),
      MoneyKind.profit => ('صافي الربح', LucideIcons.wallet),
    };
    final m = c.headline;
    final negative = m.usd < 0 || m.iqd < 0;
    return NzInkCard(
      padding: EdgeInsets.all(AppSpacing.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16.r, color: AppColors.goldLight),
              SizedBox(width: AppSpacing.s8),
              Expanded(
                child: Text(
                  title,
                  style: AppText.body(13, color: AppColors.onInkMuted),
                ),
              ),
              if (c.count != null)
                Text(
                  '${c.count} حركة',
                  style: AppText.body(12, color: AppColors.onInkMuted),
                ),
            ],
          ),
          SizedBox(height: AppSpacing.s12),
          Wrap(
            spacing: AppSpacing.s16,
            runSpacing: AppSpacing.s6,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              NzAmount(
                _signed(m.usd),
                'دولار',
                size: 28,
                color: negative ? AppColors.amber : Colors.white,
                unitColor: AppColors.onInkMuted,
                unitSize: 13,
              ),
              NzAmount(
                _signed(m.iqd),
                'دينار',
                size: 18,
                color: AppColors.goldLight,
                unitColor: AppColors.onInkMuted,
                unitSize: 12.5,
              ),
            ],
          ),
          if (c.kind == MoneyKind.profit) ...[
            SizedBox(height: AppSpacing.s12),
            const NzDivider(color: AppColors.onInkLine),
            SizedBox(height: AppSpacing.s12),
            _OnInkLine('الإيرادات', c.revenue),
            SizedBox(height: AppSpacing.s6),
            _OnInkLine('المصروفات', c.expenses),
          ],
        ],
      ),
    );
  }
}

String _signed(double v) => v < 0 ? '-${fmtNum(-v)}' : fmtNum(v);

class _OnInkLine extends StatelessWidget {
  const _OnInkLine(this.label, this.m);

  final String label;
  final Money m;

  @override
  Widget build(BuildContext context) {
    final style = AppText.num(
      13,
      weight: FontWeight.w500,
      color: AppColors.onInk,
    );
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppText.body(12.5, color: AppColors.onInkMuted),
          ),
        ),
        // Big totals shrink to fit rather than push the label off screen.
        Flexible(
          flex: 3,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerEnd,
            child: Row(
              children: [
                Text('${fmtNum(m.usd)} \$', style: style),
                SizedBox(width: AppSpacing.s12),
                Text('${fmtNum(m.iqd)} د.ع', style: style),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ------------------------------------------------------------ occupancy

class _OccupancyView extends StatelessWidget {
  const _OccupancyView(this.c);

  final OccupancyCard c;

  @override
  Widget build(BuildContext context) {
    final stats = <(String, int?)>[
      if (c.isLive) ...[
        ('مشغولة', c.occupied),
        ('محجوزة', c.booked),
        ('فارغة', c.free),
        ('خارج الخدمة', c.outOfService),
      ] else if (c.isPeriod) ...[
        ('عدد الأيام', c.days),
        ('ليالٍ محجوزة', c.bookedRoomNights),
      ] else ...[
        ('محجوزة', c.reserved),
        ('فارغة', c.free),
      ],
    ];
    return _Panel(
      icon: LucideIcons.bedDouble,
      title: c.isPeriod ? 'متوسط الإشغال' : 'الإشغال',
      trailing: c.isLive
          ? const NzTag('مباشر', tone: NzTagTone.gold, fontSize: 11.5)
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${c.percent}%', style: AppText.num(30, height: 1)),
              SizedBox(width: AppSpacing.s8),
              Flexible(
                child: Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.s3),
                  child: Text(
                    'من ${c.totalRooms} غرفة',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.body(12.5, color: AppColors.inkMuted),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.s10),
          NzProgressBar(value: c.percent / 100, height: 6.r),
          SizedBox(height: AppSpacing.s14),
          Row(
            children: [
              for (var i = 0; i < stats.length; i++) ...[
                if (i > 0) SizedBox(width: AppSpacing.s6),
                Expanded(child: _Stat(stats[i].$1, stats[i].$2 ?? 0)),
              ],
            ],
          ),
          if (c.freeRooms.isNotEmpty) ...[
            SizedBox(height: AppSpacing.s14),
            Text(
              'الغرف الفارغة',
              style: AppText.body(12.5, color: AppColors.inkMuted),
            ),
            SizedBox(height: AppSpacing.s8),
            Wrap(
              spacing: AppSpacing.s6,
              runSpacing: AppSpacing.s6,
              children: [
                for (final r in c.freeRooms.take(18))
                  NzTag(r, tone: NzTagTone.outline, fontSize: 12),
                if (c.freeRooms.length > 18)
                  NzTag('+${c.freeRooms.length - 18}', fontSize: 12),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value);

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.s8),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(AppRadius.r12),
      ),
      child: Column(
        children: [
          Text('$value', style: AppText.num(17, height: 1.1)),
          SizedBox(height: AppSpacing.s2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.body(11, color: AppColors.inkMuted),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------- arrivals / departures

class _MovementsView extends StatelessWidget {
  const _MovementsView(this.c);

  final MovementsCard c;

  @override
  Widget build(BuildContext context) {
    return _ListPanel(
      icon: c.arrivals ? LucideIcons.logIn : LucideIcons.logOut,
      title: c.arrivals ? 'الواصلون' : 'المغادرون',
      count: c.items.length,
      more: c.more,
      empty: c.arrivals ? 'لا يوجد واصلون.' : 'لا يوجد مغادرون.',
      rows: [
        for (final m in c.items)
          _Row(
            leading: NzInitialAvatar(
              _initial(m.guest),
              size: 34.r,
              fontSize: 13,
            ),
            title: m.guest,
            subtitle: [
              if (m.rooms.isNotEmpty) _rooms(m.rooms),
              _nights(m.nights),
            ].join(' · '),
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  fmtDate(c.arrivals ? m.checkIn : m.checkOut),
                  style: AppText.num(12.5, weight: FontWeight.w500),
                ),
                if (m.isGroup) ...[
                  SizedBox(height: AppSpacing.s4),
                  NzTag(
                    'حملة',
                    tone: NzTagTone.gold,
                    height: 20.r,
                    fontSize: 11,
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

String _rooms(List<String> rooms) =>
    rooms.length == 1 ? 'غرفة ${rooms.first}' : 'غرف ${rooms.join('، ')}';

String _nights(int n) => switch (n) {
  1 => 'ليلة واحدة',
  2 => 'ليلتان',
  >= 3 && <= 10 => '$n ليالٍ',
  _ => '$n ليلة',
};

/// First letter of a name, for the round avatar.
String _initial(String name) =>
    name.trim().isEmpty ? '؟' : name.trim().characters.first;

// ---------------------------------------------------------------- debts

class _DebtsView extends StatelessWidget {
  const _DebtsView(this.c);

  final DebtsCard c;

  @override
  Widget build(BuildContext context) {
    return _ListPanel(
      icon: LucideIcons.receipt,
      title: 'ديون النزلاء',
      count: c.items.length,
      more: c.more,
      empty: 'لا توجد ديون على النزلاء.',
      header: c.items.isEmpty
          ? null
          : Wrap(
              spacing: AppSpacing.s16,
              runSpacing: AppSpacing.s4,
              crossAxisAlignment: WrapCrossAlignment.end,
              children: [
                NzAmount(fmtNum(c.total.usd), 'دولار', size: 22),
                NzAmount(
                  fmtNum(c.total.iqd),
                  'دينار',
                  size: 16,
                  color: AppColors.goldDeep,
                ),
              ],
            ),
      rows: [
        for (final d in c.items)
          _Row(
            leading: NzInitialAvatar(
              _initial(d.guest),
              size: 34.r,
              fontSize: 13,
            ),
            title: d.guest,
            subtitle: d.rooms.isEmpty ? null : _rooms(d.rooms),
            badge: d.leftHotel ? 'غادر' : null,
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (d.amount.usd != 0)
                  Text('${fmtNum(d.amount.usd)} \$', style: AppText.num(13.5)),
                if (d.amount.iqd != 0)
                  Text(
                    '${fmtNum(d.amount.iqd)} د.ع',
                    style: AppText.num(12, color: AppColors.goldDeep),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------- tasks

class _TasksView extends StatelessWidget {
  const _TasksView(this.c);

  final TasksCard c;

  @override
  Widget build(BuildContext context) {
    return _ListPanel(
      icon: LucideIcons.listChecks,
      title: 'المهام المفتوحة',
      count: c.open,
      more: c.open > c.items.length,
      empty: 'لا توجد مهام مفتوحة.',
      rows: [
        for (final t in c.items)
          _Row(
            leading: NzIconTile(
              t.urgent ? LucideIcons.triangleAlert : LucideIcons.listChecks,
              tone: t.urgent ? NzIconTileTone.ink : NzIconTileTone.inert,
              size: 34.r,
              radius: AppRadius.r10,
              iconSize: 16.r,
            ),
            title: t.title,
            subtitle: [
              if (t.rooms.isNotEmpty) _rooms(t.rooms),
              if (t.assignee != null && t.assignee!.isNotEmpty) t.assignee!,
            ].join(' · '),
            trailing: NzTag(
              t.inProgress ? 'قيد التنفيذ' : 'جديدة',
              tone: t.inProgress ? NzTagTone.gold : NzTagTone.neutral,
              height: 22.r,
              fontSize: 11.5,
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------- stock

class _StockView extends StatelessWidget {
  const _StockView(this.c);

  final StockCard c;

  @override
  Widget build(BuildContext context) {
    return _ListPanel(
      icon: LucideIcons.package,
      title: 'مواد ناقصة',
      count: c.items.length,
      more: c.more,
      empty: 'كل المواد فوق الحد الأدنى.',
      rows: [
        for (final s in c.items)
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.s14,
              vertical: AppSpacing.s10,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        s.item,
                        style: AppText.body(14, weight: FontWeight.w500),
                      ),
                    ),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: fmtNum(s.quantity),
                            style: AppText.num(
                              13.5,
                              color: s.quantity <= 0
                                  ? AppColors.danger
                                  : AppColors.ink,
                            ),
                          ),
                          TextSpan(
                            text: ' / ${fmtNum(s.min)}',
                            style: AppText.num(
                              12,
                              weight: FontWeight.w400,
                              color: AppColors.inkFaint,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.s6),
                NzProgressBar(
                  value: s.min <= 0 ? 0 : s.quantity / s.min,
                  fill: s.quantity <= 0 ? AppColors.danger : AppColors.amber,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ------------------------------------------------------------- building blocks

/// White card with an icon + title header.
class _Panel extends StatelessWidget {
  const _Panel({
    required this.icon,
    required this.title,
    required this.child,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return NzCard(
      radius: AppRadius.r20,
      shadow: AppShadows.card,
      padding: EdgeInsets.all(AppSpacing.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PanelTitle(icon: icon, title: title, trailing: trailing),
          SizedBox(height: AppSpacing.s14),
          child,
        ],
      ),
    );
  }
}

class _PanelTitle extends StatelessWidget {
  const _PanelTitle({required this.icon, required this.title, this.trailing});

  final IconData icon;
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        NzIconTile(icon, size: 30.r, radius: AppRadius.r10, iconSize: 15.r),
        SizedBox(width: AppSpacing.s10),
        Expanded(
          child: Text(
            title,
            style: AppText.body(14.5, weight: FontWeight.w600),
          ),
        ),
        ?trailing,
      ],
    );
  }
}

/// A titled list of rows, capped at [_maxRows] with a "more" footer.
class _ListPanel extends StatelessWidget {
  const _ListPanel({
    required this.icon,
    required this.title,
    required this.count,
    required this.more,
    required this.empty,
    required this.rows,
    this.header,
  });

  final IconData icon;
  final String title;
  final int count;

  /// The server cut the list short.
  final bool more;
  final String empty;
  final List<Widget> rows;
  final Widget? header;

  @override
  Widget build(BuildContext context) {
    final shown = rows.take(_maxRows).toList();
    final hidden = rows.length - shown.length;
    return NzCard(
      radius: AppRadius.r20,
      shadow: AppShadows.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.s16,
              AppSpacing.s14,
              AppSpacing.s16,
              AppSpacing.s12,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _PanelTitle(
                  icon: icon,
                  title: title,
                  trailing: count == 0
                      ? null
                      : NzTag(
                          more ? '$count+' : '$count',
                          tone: NzTagTone.dark,
                          height: 22.r,
                          fontSize: 12,
                        ),
                ),
                if (header != null) ...[
                  SizedBox(height: AppSpacing.s12),
                  header!,
                ],
              ],
            ),
          ),
          if (rows.isEmpty)
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.s16,
                0,
                AppSpacing.s16,
                AppSpacing.s16,
              ),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.circleCheck,
                    size: 16.r,
                    color: AppColors.gold,
                  ),
                  SizedBox(width: AppSpacing.s8),
                  Text(
                    empty,
                    style: AppText.body(13.5, color: AppColors.inkMuted),
                  ),
                ],
              ),
            )
          else ...[
            for (final row in shown) ...[const NzDivider(), row],
            if (hidden > 0 || more) ...[
              const NzDivider(),
              Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.s10),
                child: Text(
                  more ? 'وغيرها…' : 'و$hidden أخرى',
                  textAlign: TextAlign.center,
                  style: AppText.body(12.5, color: AppColors.inkMuted),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.leading,
    required this.title,
    required this.trailing,
    this.subtitle,
    this.badge,
  });

  final Widget leading;
  final String title;
  final String? subtitle;
  final String? badge;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.s14,
        vertical: AppSpacing.s10,
      ),
      child: Row(
        children: [
          leading,
          SizedBox(width: AppSpacing.s10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.body(14, weight: FontWeight.w500),
                      ),
                    ),
                    if (badge != null) ...[
                      SizedBox(width: AppSpacing.s6),
                      NzTag(badge!, height: 20.r, fontSize: 11),
                    ],
                  ],
                ),
                if (subtitle != null && subtitle!.isNotEmpty)
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.body(12, color: AppColors.inkMuted),
                  ),
              ],
            ),
          ),
          SizedBox(width: AppSpacing.s8),
          // Capped, so a long amount scales down instead of crowding out
          // the name.
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 110.r),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerEnd,
              child: trailing,
            ),
          ),
        ],
      ),
    );
  }
}
