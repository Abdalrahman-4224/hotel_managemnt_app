import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/data_sources/profile_local_data_source.dart';
import '../../domain/entities/profile.dart';
import '../widgets/settings_row.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _source = const ProfileLocalDataSource();
  var _notifications = true;
  var _biometric = false;

  @override
  Widget build(BuildContext context) {
    final user = _source.getProfile();
    final plan = _source.getSubscription();
    return Scaffold(
      body: Column(
        children: [
          NzPageHeader(
            subtitle: 'الحساب والاشتراك',
            title: 'حسابي',
            actions: [
              NzOutlineButton(
                label: 'تعديل',
                height: 44,
                radius: 14,
                fontSize: 14,
                onPressed: () {},
              ),
            ],
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                NzBottomNav.bodyPadding(context),
              ),
              children: [
                _UserCard(user: user),
                const SizedBox(height: 18),
                _SubscriptionCard(
                  plan: plan,
                  onRenew: () => _openRenew(context),
                ),
                const SizedBox(height: 18),
                const NzGroupLabel('الفندق'),
                const SizedBox(height: 8),
                const NzListCard(
                  children: [
                    SettingsRow(
                      icon: LucideIcons.building,
                      title: 'فندق أ',
                      subtitle: 'بغداد · الكرادة · 84 غرفة',
                    ),
                    SettingsRow(
                      icon: LucideIcons.receipt,
                      title: 'بيانات الفوترة والضريبة',
                    ),
                    SettingsRow(
                      icon: LucideIcons.coins,
                      title: 'العملة الافتراضية',
                      value: 'دولار',
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const NzGroupLabel('الحساب والأمان'),
                const SizedBox(height: 8),
                NzListCard(
                  children: [
                    const SettingsRow(
                      icon: LucideIcons.userRound,
                      title: 'المعلومات الشخصية',
                    ),
                    const SettingsRow(
                      icon: LucideIcons.lock,
                      title: 'تغيير كلمة المرور',
                    ),
                    SettingsRow(
                      icon: LucideIcons.smartphone,
                      title: 'رقم الهاتف',
                      value: user.maskedPhone,
                    ),
                    const SettingsRow(
                      icon: LucideIcons.monitor,
                      title: 'الأجهزة المتصلة',
                      value: '2',
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const NzGroupLabel('التفضيلات'),
                const SizedBox(height: 8),
                NzListCard(
                  children: [
                    SettingsRow(
                      icon: LucideIcons.bell,
                      title: 'الإشعارات',
                      subtitle: 'الحجوزات والمهام والمخزن',
                      trailing: NzSwitch(
                        value: _notifications,
                        semanticLabel: 'الإشعارات',
                        onChanged: (v) => setState(() => _notifications = v),
                      ),
                    ),
                    SettingsRow(
                      icon: LucideIcons.fingerprint,
                      title: 'الدخول بالبصمة',
                      subtitle: 'بدل رمز التحقق',
                      trailing: NzSwitch(
                        value: _biometric,
                        semanticLabel: 'الدخول بالبصمة',
                        onChanged: (v) => setState(() => _biometric = v),
                      ),
                    ),
                    const SettingsRow(
                      icon: LucideIcons.globe,
                      title: 'اللغة',
                      value: 'العربية',
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const NzGroupLabel('الدعم'),
                const SizedBox(height: 8),
                const NzListCard(
                  children: [
                    SettingsRow(
                      icon: LucideIcons.circleQuestionMark,
                      title: 'المساعدة والدعم الفني',
                    ),
                    SettingsRow(
                      icon: LucideIcons.fileText,
                      title: 'الشروط وسياسة الخصوصية',
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                NzOutlineButton(
                  label: 'تسجيل الخروج',
                  foreground: AppColors.danger,
                  borderColor: AppColors.dangerBorder,
                  weight: FontWeight.w600,
                  onPressed: () => context.go(AppRoutes.login),
                ),
                const SizedBox(height: 18),
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(text: 'نُزُل · الإصدار '),
                      TextSpan(
                        text: '2.4.0',
                        style: AppText.num(
                          12,
                          weight: FontWeight.w400,
                          color: AppColors.inkFaint,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  style: AppText.body(12, color: AppColors.inkFaint),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openRenew(BuildContext context) {
    final terms = _source.getRenewalTerms();
    var selected = 1;
    showNzSheet<void>(
      context,
      background: AppColors.paper,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 34),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const NzSheetTitle(
              'تجديد الاشتراك',
              subtitle: 'الباقة الاحترافية · يبدأ التجديد من تاريخ الانتهاء',
            ),
            const SizedBox(height: 14),
            for (var i = 0; i < terms.length; i++) ...[
              if (i > 0) const SizedBox(height: 8),
              NzOptionTile(
                selected: selected == i,
                onTap: () => setSheet(() => selected = i),
                child: Row(
                  children: [
                    NzRadioDot(selected: selected == i),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            terms[i].label,
                            style: AppText.body(15, weight: FontWeight.w600),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            terms[i].note,
                            style: AppText.body(
                              12.5,
                              color: AppColors.inkMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(terms[i].price, style: AppText.num(17, height: 1)),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 14),
            NzPrimaryButton(
              label: 'متابعة الدفع · ${terms[selected].price}',
              height: 52,
              fontSize: 15,
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard({required this.user});

  final UserProfile user;

  @override
  Widget build(BuildContext context) {
    return NzCard(
      radius: 22,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          NzInitialAvatar(user.initial, size: 60, fontSize: 24, serif: true),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.name, style: AppText.display(18, height: 1.35)),
                const SizedBox(height: 3),
                Text(
                  user.role,
                  style: AppText.body(13, color: AppColors.inkMuted),
                ),
                const SizedBox(height: 3),
                Text(
                  user.phone,
                  textDirection: TextDirection.ltr,
                  style: AppText.num(
                    13,
                    weight: FontWeight.w500,
                    color: AppColors.ink3,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SubscriptionCard extends StatelessWidget {
  const _SubscriptionCard({required this.plan, required this.onRenew});

  final Subscription plan;
  final VoidCallback onRenew;

  @override
  Widget build(BuildContext context) {
    return NzInkCard(
      shadow: null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الاشتراك',
                      style: AppText.body(12.5, color: AppColors.onInkMuted),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      plan.name,
                      style: AppText.display(20, color: AppColors.onInk),
                    ),
                  ],
                ),
              ),
              NzTag(plan.status, tone: NzTagTone.solidGold),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(text: 'ينتهي في '),
                      TextSpan(
                        text: plan.endsOn,
                        style: AppText.body(
                          13,
                          weight: FontWeight.w500,
                          color: AppColors.onInk,
                        ),
                      ),
                    ],
                  ),
                  style: AppText.body(13, color: AppColors.onInkMuted),
                ),
              ),
              NzAmount(
                '${plan.daysLeft}',
                'يوماً متبقياً',
                size: 22,
                color: AppColors.amber,
                unitColor: AppColors.onInkMuted,
                unitSize: 12.5,
              ),
            ],
          ),
          const SizedBox(height: 8),
          NzProgressBar(
            value: plan.daysLeft / plan.totalDays,
            height: 6,
            track: AppColors.onInkTrack,
            fill: AppColors.amber,
          ),
          const SizedBox(height: 8),
          Text(plan.note, style: AppText.body(12, color: AppColors.onInkMuted)),
          const SizedBox(height: 14),
          const NzDivider(color: AppColors.onInkLine),
          const SizedBox(height: 14),
          Row(
            children: [
              for (var i = 0; i < plan.usage.length; i++) ...[
                if (i > 0) const SizedBox(width: 12),
                Expanded(child: _UsageMeter(plan.usage[i])),
              ],
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: NzPrimaryButton(
                  label: 'تجديد الاشتراك',
                  background: AppColors.gold,
                  foreground: AppColors.ink,
                  height: 48,
                  radius: 14,
                  fontSize: 14.5,
                  onPressed: onRenew,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: NzOutlineButton(
                  label: 'سجل الدفعات',
                  background: Colors.transparent,
                  foreground: AppColors.onInk,
                  borderColor: AppColors.onInkBorder,
                  height: 48,
                  radius: 14,
                  fontSize: 14.5,
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UsageMeter extends StatelessWidget {
  const _UsageMeter(this.usage);

  final PlanUsage usage;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.centerStart,
          child: Row(
            children: [
              Text(
                usage.label,
                style: AppText.body(12.5, color: AppColors.onInkMuted),
              ),
              const SizedBox(width: 6),
              Text(
                '${usage.used} / ${usage.limit}',
                textDirection: TextDirection.ltr,
                style: AppText.num(
                  12.5,
                  weight: FontWeight.w400,
                  color: AppColors.onInk,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        NzProgressBar(
          value: usage.ratio,
          track: AppColors.onInkTrack,
          fill: AppColors.goldLight,
        ),
      ],
    );
  }
}
