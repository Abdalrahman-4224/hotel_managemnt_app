import '../../domain/entities/profile.dart';

/// Sample data from the design. Replace with an API data source.
class ProfileLocalDataSource {
  const ProfileLocalDataSource();

  UserProfile getProfile() => const UserProfile(
    initial: 'أ',
    name: 'أحمد الكاظمي',
    role: 'مدير الفندق · صلاحيات كاملة',
    phone: '+964 770 123 4567',
    maskedPhone: '0770 ••• 4567',
  );

  Subscription getSubscription() => const Subscription(
    name: 'الباقة الاحترافية',
    status: 'نشط',
    endsOn: '15 تشرين الثاني 2026',
    daysLeft: 36,
    totalDays: 365,
    note: 'التجديد التلقائي متوقف · سيصلك تذكير قبل 7 أيام من الانتهاء',
    usage: [
      PlanUsage('الغرف', 84, 100),
      PlanUsage('المستخدمون', 12, 15),
      PlanUsage('الفروع', 1, 2),
    ],
  );

  List<RenewalTerm> getRenewalTerms() => const [
    RenewalTerm('شهري', 'يُجدَّد كل شهر', r'$49'),
    RenewalTerm('سنوي', 'وفّر شهرين · الأكثر اختياراً', r'$490'),
    RenewalTerm('سنتان', 'وفّر 20%', r'$940'),
  ];
}
