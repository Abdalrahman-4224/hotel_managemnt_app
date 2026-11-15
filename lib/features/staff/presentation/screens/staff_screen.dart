import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/widgets.dart';
import '../controllers/staff_controller.dart';
import '../../domain/entities/staff_member.dart';
import '../widgets/staff_tables.dart';

/// Staff log: a filterable list, and an activity view per employee.
class StaffScreen extends ConsumerStatefulWidget {
  const StaffScreen({super.key});

  @override
  ConsumerState<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends ConsumerState<StaffScreen> {
  var _staff = const <StaffMember>[];
  var _onlineOnly = false;
  String? _department;
  StaffMember? _selected;

  List<StaffMember> get _inDept => _staff
      .where((s) => _department == null || s.department == _department)
      .toList();

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(staffControllerProvider);
    _staff = async.value ?? const [];
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
                  : '${_staff.where((s) => s.online).length} نشطون اليوم من ${_staff.length}',
              title: p?.name ?? 'سجل الموظفين',
            ),
            Expanded(
              child: NzAsyncBody(
                hasValue: async.hasValue,
                error: async.error,
                onRetry: () =>
                    ref.read(staffControllerProvider.notifier).refresh(),
                child: () => RefreshIndicator(
                  onRefresh: () =>
                      ref.read(staffControllerProvider.notifier).refresh(),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.s16,
                      AppSpacing.s14,
                      AppSpacing.s16,
                      NzBottomNav.bodyPadding(context),
                    ),
                    children: p == null ? _list() : [_detail(p)],
                  ),
                ),
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
          SizedBox(width: AppSpacing.s8),
          Expanded(
            child: _Stat(
              'حجوزات',
              fmtNum(_staff.fold<int>(0, (n, s) => n + s.bookings)),
            ),
          ),
          SizedBox(width: AppSpacing.s8),
          Expanded(
            child: _Stat(
              'مهام مفتوحة',
              fmtNum(_staff.fold<int>(0, (n, s) => n + s.tasks)),
            ),
          ),
        ],
      ),
      SizedBox(height: AppSpacing.s14),
      Row(
        children: [
          Expanded(
            child: NzSegmented<bool>(
              selected: _onlineOnly,
              height: 42.r,
              fontSize: 14,
              onChanged: (v) => setState(() => _onlineOnly = v),
              segments: [
                NzSegment(false, 'الكل', count: '${inDept.length}'),
                NzSegment(
                  true,
                  'نشط اليوم',
                  count: '${inDept.where((s) => s.online).length}',
                ),
              ],
            ),
          ),
          SizedBox(width: AppSpacing.s8),
          Semantics(
            button: true,
            label: 'القسم: ${_department ?? 'كل الأقسام'}',
            child: GestureDetector(
              onTap: _openDepartments,
              child: Container(
                height: 50.r,
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.s12),
                decoration: BoxDecoration(
                  color: deptOn ? AppColors.goldTint : AppColors.card,
                  borderRadius: BorderRadius.circular(AppRadius.r16),
                  border: Border.all(
                    color: deptOn ? AppColors.goldDeep : AppColors.lineStrong,
                    width: deptOn ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 88.r),
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
                    SizedBox(width: AppSpacing.s6),
                    Icon(
                      LucideIcons.chevronDown,
                      size: 15.r,
                      color: deptOn ? AppColors.goldDarkest : AppColors.ink,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      SizedBox(height: AppSpacing.s14),
      if (list.isEmpty)
        NzDashedBox(
          padding: EdgeInsets.symmetric(
            vertical: 30.r,
            horizontal: AppSpacing.s12,
          ),
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
    // Newest first; empty while loading.
    final acts =
        ref.watch(staffActivityProvider(p.id)).value?.reversed.toList() ??
        const <StaffActivity>[];
    return Column(
          key: ValueKey(p.id),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            NzCard(
              color: AppColors.ink,
              borderColor: null,
              radius: AppRadius.r22,
              padding: EdgeInsets.all(AppSpacing.s16),
              child: Row(
                children: [
                  Container(
                    width: 54.r,
                    height: 54.r,
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
                  SizedBox(width: AppSpacing.s14),
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
                    height: 28.r,
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.s12),
                    decoration: BoxDecoration(
                      color: p.online
                          ? const Color(0x2EE3B06A)
                          : const Color(0x1AF8F5F1),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      p.lastSeen,
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
            SizedBox(height: AppSpacing.s14),
            Row(
              children: [
                Expanded(
                  child: _Stat('حجوزات اليوم', fmtNum(p.bookings), big: false),
                ),
                SizedBox(width: AppSpacing.s8),
                Expanded(
                  child: _Stat('مهام مفتوحة', fmtNum(p.tasks), big: false),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.s8),
            Row(
              children: [
                Expanded(
                  child: _Stat(
                    'مبالغ · دولار',
                    p.usd > 0 ? fmtNum(p.usd) : '—',
                    big: false,
                  ),
                ),
                SizedBox(width: AppSpacing.s8),
                Expanded(
                  child: _Stat(
                    'مبالغ · دينار',
                    p.iqd > 0 ? fmtNum(p.iqd) : '—',
                    big: false,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.s14),
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
            SizedBox(height: AppSpacing.s14),
            ActivityTable(items: acts),
          ],
        )
        .animate()
        .fadeIn(duration: 350.ms, curve: AppMotion.easeOut)
        .moveX(begin: -14, end: 0, duration: 350.ms, curve: AppMotion.easeOut);
  }

  void _openDepartments() {
    final departments = {for (final s in _staff) s.department}.toList();
    final options = <String?>[null, ...departments];
    showNzSheet<void>(
      context,
      padding: EdgeInsets.fromLTRB(
        AppSpacing.s18,
        AppSpacing.s10,
        AppSpacing.s18,
        AppSpacing.s32,
      ),
      gap: AppSpacing.s12,
      builder: (ctx) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const NzSheetTitle('القسم'),
          SizedBox(height: AppSpacing.s12),
          for (final (i, d) in options.indexed) ...[
            if (i > 0) SizedBox(height: AppSpacing.s8),
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
      radius: AppRadius.r16,
      padding: big
          ? EdgeInsets.all(AppSpacing.s12)
          : EdgeInsets.symmetric(
              horizontal: AppSpacing.s14,
              vertical: AppSpacing.s12,
            ),
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
          SizedBox(height: AppSpacing.s6),
          Text(value, style: AppText.num(big ? 22 : 20, height: 1)),
        ],
      ),
    );
  }
}
