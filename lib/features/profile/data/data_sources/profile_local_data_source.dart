import '../../domain/entities/profile.dart';

/// Renewal prices. The server has no pricing yet, so they live in the app.
class ProfileLocalDataSource {
  const ProfileLocalDataSource();

  List<RenewalTerm> getRenewalTerms() => const [
    RenewalTerm('شهري', 'يُجدَّد كل شهر', r'$49'),
    RenewalTerm('سنوي', 'وفّر شهرين · الأكثر اختياراً', r'$490'),
    RenewalTerm('سنتان', 'وفّر 20%', r'$940'),
  ];
}
