import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/data_sources/staff_local_data_source.dart';
import '../../domain/entities/staff_member.dart';
import '../widgets/staff_tables.dart';

/// Staff log: a filterable list, and an activity view per employee.
class StaffScreen extends StatefulWidget {
  const StaffScreen({super.key});

  @override
  State<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends State<StaffScreen> {
  final _staff = const StaffLocalDataSource().getStaff();
  var _onlineOnly = false;
  String? _department;
  StaffMember? _selected;

  List<StaffMember> get _inDept => _staff
      .where((s) => _department == null || s.department == _department)
      .toList();

  @override
  Widget build(BuildContext context) {
    final p = _selected;
    return PopScope(
      canPop: p == null,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) setState(() => _selected = null);
      },
      child: Scaffold(
        body: Column(
          children: [
            NzPageHeader(
              showBack: p != null,
              onBack: () => setState(() => _selected = null),
              subtitle: p != null
                  ? '${p.department} · آخر نشاط ${p.lastSeen}'
                  : '${_staff.where((s) => s.online).length} يعملون الآن من ${_staff.length}',
              title: p?.name ?? 'سجل الموظفين',
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  16,
                  14,
                  16,
                  NzBottomNav.bodyPadding(context),
                ),
                children: p == null ? _list() : [_detail(p)],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _list() {
    final inDept = _inDept;
    final list = inDept.where((s) => !_onlineOnly || s.online).toList();
    final deptOn = _department != null;
    return [
      Row(
        children: [
          Expanded(
            child: _Stat(
              'عملوا اليوم',
              '${_staff.where((s) => s.online).length}',
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _Stat(
              'حجوزات',
              fmtNum(_staff.fold<int>(0, (n, s) => n + s.bookings)),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _Stat(
              'مهام منجزة',
              fmtNum(_staff.fold<int>(0, (n, s) => n + s.tasks)),
            ),
          ),
        ],
      ),
      const SizedBox(height: 14),
      Row(
        children: [
          Expanded(
            child: NzSegmented<bool>(
              selected: _onlineOnly,
              height: 42,
              fontSize: 14,
              onChanged: (v) => setState(() => _onlineOnly = v),
              segments: [
                NzSegment(false, 'الكل', count: '${inDept.length}'),
                NzSegment(
                  true,
                  'نشط الآن',
                  count: '${inDept.where((s) => s.online).length}',
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Semantics(
            button: true,
            label: 'القسم: ${_department ?? 'كل الأقسام'}',
            child: GestureDetector(
              onTap: _openDepartments,
              child: Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: deptOn ? AppColors.goldTint : AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: deptOn ? AppColors.goldDeep : AppColors.lineStrong,
                    width: deptOn ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 88),
                      child: Text(
                        _department ?? 'كل الأقسام',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.body(
                          13.5,
                          weight: FontWeight.w600,
                          color: deptOn ? AppColors.goldDarkest : AppColors.ink,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      LucideIcons.chevronDown,
                      size: 15,
                      color: deptOn ? AppColors.goldDarkest : AppColors.ink,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 14),
      if (list.isEmpty)
        NzDashedBox(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 12),
          child: Text(
            'لا موظفين بهذا الفلتر.',
            textAlign: TextAlign.center,
            style: AppText.body(14, color: AppColors.inkMuted),
          ),
        )
      else
        StaffTable(staff: list, onOpen: (s) => setState(() => _selected = s)),
    ];
  }

  Widget _detail(StaffMember p) {
    final acts = p.activity.reversed.toList();
    return Column(
          key: ValueKey(p.id),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            NzCard(
              color: AppColors.ink,
              borderColor: null,
              radius: 22,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0x29E3B06A),
                      border: Border.all(color: const Color(0x73E3B06A)),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      p.initial,
                      style: AppText.display(
                        21,
                        color: AppColors.goldLight,
                        height: 1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.name,
                          style: AppText.body(
                            17,
                            weight: FontWeight.w600,
                            color: AppColors.onInk,
                          ),
                        ),
                        Text(
                          '${p.department} · ${p.role}',
                          style: AppText.body(13, color: AppColors.onInkMuted),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 28,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: p.online
                          ? const Color(0x2EE3B06A)
                          : const Color(0x1AF8F5F1),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      p.online ? 'يعمل الآن' : 'غير متصل',
                      style: AppText.body(
                        12.5,
                        weight: FontWeight.w600,
                        color: p.online
                            ? AppColors.goldLight
                            : AppColors.onInkMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _Stat('حجوزات اليوم', fmtNum(p.bookings), big: false),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _Stat('مهام اليوم', fmtNum(p.tasks), big: false),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _Stat(
                    'مبالغ · دولار',
                    p.usd > 0 ? fmtNum(p.usd) : '—',
                    big: false,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _Stat(
                    'مبالغ · دينار',
                    p.iqd > 0 ? fmtNum(p.iqd) : '—',
                    big: false,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'سجل النشاط',
                    style: AppText.display(17, height: 1.4),
                  ),
                ),
                Text(
                  '${acts.length} إجراء',
                  style: AppText.body(12.5, color: AppColors.inkFaint),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ActivityTable(items: acts),
          ],
        )
        .animate()
        .fadeIn(duration: 350.ms, curve: AppMotion.easeOut)
        .moveX(begin: -14, end: 0, duration: 350.ms, curve: AppMotion.easeOut);
  }

  void _openDepartments() {
    final options = <String?>[null, ...StaffLocalDataSource.departments];
    showNzSheet<void>(
      context,
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 32),
      gap: 12,
      builder: (ctx) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const NzSheetTitle('القسم'),
          const SizedBox(height: 12),
          for (final (i, d) in options.indexed) ...[
            if (i > 0) const SizedBox(height: 8),
            NzRadioRow(
              label: d ?? 'كل الأقسام',
              trailing:
                  '${_staff.where((s) => d == null || s.department == d).length}',
              selected: _department == d,
              onTap: () {
                setState(() => _department = d);
                Navigator.of(ctx).pop();
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value, {this.big = true});

  final String label;
  final String value;
  final bool big;

  @override
  Widget build(BuildContext context) {
    return NzCard(
      radius: 16,
      padding: big
          ? const EdgeInsets.all(12)
          : const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppText.body(
              big ? 12 : 12.5,
              color: AppColors.inkMuted,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(value, style: AppText.num(big ? 22 : 20, height: 1)),
        ],
      ),
    );
  }
}
