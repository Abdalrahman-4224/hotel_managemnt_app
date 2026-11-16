import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../authentication/domain/entities/auth_user.dart';
import '../../../authentication/domain/entities/biometric_kind.dart';
import '../../../authentication/domain/entities/permissions.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';
import '../../../authentication/presentation/controllers/biometric_controller.dart';
import '../../../authentication/presentation/controllers/permissions_controller.dart';
import '../../domain/entities/profile.dart';
import '../controllers/hotel_controller.dart';
import '../widgets/account_sheets.dart';
import '../widgets/settings_row.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  /// The signed-in user as the profile card shows them.
  UserProfile _profile(AuthUser? u) {
    final name = u?.fullName ?? '';
    final phone = u?.phone ?? '';
    return UserProfile(
      initial: name.isEmpty ? '؟' : name.substring(0, 1),
      name: name,
      role: u?.roleName ?? '',
      phone: phone,
      // Keep the last 4 digits only.
      maskedPhone: phone.length > 4
          ? '••• ${phone.substring(phone.length - 4)}'
          : phone,
    );
  }

  /// Off: forget the saved login. On: confirm the password and a scan.
  Future<void> _setBiometric(BiometricKind kind, bool on) async {
    if (on) {
      await showEnableBiometricSheet(context, kind);
      return;
    }
    try {
      await ref.read(authControllerProvider.notifier).disableBiometric();
      ref.invalidate(biometricStatusProvider);
      if (mounted) showNzToast(context, kind.disabledToast);
    } catch (error) {
      if (mounted) showNzToast(context, errorText(error));
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _profile(ref.watch(authControllerProvider).user);
    final hotel = ref.watch(currentHotelProvider).value;
    final biometric = ref.watch(biometricStatusProvider).value;
    final biometricKind = biometric?.kind;
    final biometricOn = biometric?.enabled ?? false;
    // The subscription is only fetched for roles allowed to see it.
    final canSeePlan = ref.watch(canProvider).can(Permissions.subscriptionView);
    final plan = canSeePlan ? ref.watch(subscriptionProvider) : null;

    return Scaffold(
      body: Column(
        children: [
          NzPageHeader(
            subtitle: 'الحساب والأمان',
            title: 'حسابي',
            actions: [
              NzOutlineButton(
                label: 'تعديل',
                height: 44.r,
                radius: AppRadius.r14,
                fontSize: 14,
                onPressed: () => showEditProfileSheet(context),
              ),
            ],
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.s16,
                AppSpacing.s16,
                AppSpacing.s16,
                NzBottomNav.bodyPadding(context),
              ),
              children: [
                _UserCard(user: user),
                if (plan != null) ...[
                  SizedBox(height: AppSpacing.s18),
                  if (plan.hasValue)
                    _SubscriptionCard(plan: plan.value!)
                  else if (plan.hasError)
                    NzStateMessage.error(
                      plan.error,
                      onRetry: () => ref.invalidate(subscriptionProvider),
                    )
                  else
                    const Center(child: CircularProgressIndicator()),
                ],
                SizedBox(height: AppSpacing.s18),
                const NzGroupLabel('الفندق'),
                SizedBox(height: AppSpacing.s8),
                NzListCard(
                  children: [
                    SettingsRow(
                      icon: LucideIcons.building,
                      title: hotel?.name ?? '—',
                      subtitle: '${hotel?.roomsCount ?? 0} غرفة',
                    ),
                    const SettingsRow(
                      icon: LucideIcons.coins,
                      title: 'عملة الحجوزات',
                      value: 'دولار',
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.s18),
                const NzGroupLabel('الحساب والأمان'),
                SizedBox(height: AppSpacing.s8),
                NzListCard(
                  children: [
                    SettingsRow(
                      icon: LucideIcons.userRound,
                      title: 'المعلومات الشخصية',
                      subtitle: 'الاسم والبريد الإلكتروني',
                      onTap: () => showEditProfileSheet(context),
                    ),
                    SettingsRow(
                      icon: LucideIcons.lock,
                      title: 'تغيير كلمة المرور',
                      onTap: () => showChangePasswordSheet(context),
                    ),
                    // Read-only: only the hotel manager may change a phone.
                    SettingsRow(
                      icon: LucideIcons.smartphone,
                      title: 'رقم الهاتف',
                      subtitle: 'لا يمكن تغييره، راجع مدير الفندق',
                      value: user.maskedPhone,
                    ),
                    // Only on phones with a sensor set up. The wording and the
                    // icon follow it: a fingerprint, or a face on an iPhone.
                    if (biometricKind != null)
                      SettingsRow(
                        icon: biometricKind.icon,
                        title: biometricKind.signInTitle,
                        subtitle: 'بدل كلمة المرور على هذا الجهاز',
                        trailing: NzSwitch(
                          value: biometricOn,
                          semanticLabel: biometricKind.signInTitle,
                          onChanged: (on) => _setBiometric(biometricKind, on),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: AppSpacing.s18),
                const NzGroupLabel('التفضيلات'),
                SizedBox(height: AppSpacing.s8),
                const NzListCard(
                  children: [
                    SettingsRow(
                      icon: LucideIcons.globe,
                      title: 'اللغة',
                      value: 'العربية',
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.s18),
                NzOutlineButton(
                  label: 'تسجيل الخروج',
                  foreground: AppColors.danger,
                  borderColor: AppColors.dangerBorder,
                  weight: FontWeight.w600,
                  // The router sends the user to login after sign out.
                  onPressed: () =>
                      ref.read(authControllerProvider.notifier).signOut(),
                ),
              ],
            ),
          ),
        ],
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
      radius: AppRadius.r22,
      padding: EdgeInsets.all(AppSpacing.s16),
      child: Row(
        children: [
          NzInitialAvatar(user.initial, size: 60.r, fontSize: 24, serif: true),
          SizedBox(width: AppSpacing.s14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.name, style: AppText.display(18, height: 1.35)),
                SizedBox(height: AppSpacing.s3),
                Text(
                  user.role,
                  style: AppText.body(13, color: AppColors.inkMuted),
                ),
                SizedBox(height: AppSpacing.s3),
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
  const _SubscriptionCard({required this.plan});

  final Subscription plan;

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
                    SizedBox(height: AppSpacing.s4),
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
          SizedBox(height: AppSpacing.s14),
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
          SizedBox(height: AppSpacing.s8),
          NzProgressBar(
            value: plan.daysLeft / plan.totalDays,
            height: 6.r,
            track: AppColors.onInkTrack,
            fill: AppColors.amber,
          ),
          SizedBox(height: AppSpacing.s8),
          Text(plan.note, style: AppText.body(12, color: AppColors.onInkMuted)),
          SizedBox(height: AppSpacing.s14),
          const NzDivider(color: AppColors.onInkLine),
          SizedBox(height: AppSpacing.s14),
          Row(
            children: [
              for (var i = 0; i < plan.usage.length; i++) ...[
                if (i > 0) SizedBox(width: AppSpacing.s12),
                Expanded(child: _UsageMeter(plan.usage[i])),
              ],
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
              SizedBox(width: AppSpacing.s6),
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
        SizedBox(height: AppSpacing.s6),
        NzProgressBar(
          value: usage.ratio,
          track: AppColors.onInkTrack,
          fill: AppColors.goldLight,
        ),
      ],
    );
  }
}
