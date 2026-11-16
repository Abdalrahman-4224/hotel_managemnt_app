/// How this phone recognises its owner. Every label in the app follows it,
/// so an iPhone with Face ID says "face" where a Samsung says "fingerprint".
///
/// The wording lives here, in one place, because the same words are needed by
/// the system prompt, the login button, the settings row and the sheets.
enum BiometricKind {
  fingerprint(
    signInTitle: 'الدخول بالبصمة',
    enableReason: 'أكّد بصمتك لتفعيل الدخول بالبصمة',
    signInReason: 'سجّل الدخول ببصمتك',
    enableHint: 'أكّد كلمة المرور، ثم ضع إصبعك على المستشعر.',
    promptHint: 'المس مستشعر البصمة',
    notEnrolled: 'لا توجد بصمة مسجّلة على هذا الجهاز',
    failed: 'تعذّر التحقق بالبصمة، حاول مرة أخرى',
  ),
  face(
    signInTitle: 'الدخول بالوجه',
    enableReason: 'أكّد وجهك لتفعيل الدخول بالوجه',
    signInReason: 'سجّل الدخول بوجهك',
    enableHint: 'أكّد كلمة المرور، ثم انظر إلى الكاميرا.',
    promptHint: 'انظر إلى الكاميرا',
    notEnrolled: 'لا يوجد وجه مسجّل على هذا الجهاز',
    failed: 'تعذّر التحقق بالوجه، حاول مرة أخرى',
  );

  const BiometricKind({
    required this.signInTitle,
    required this.enableReason,
    required this.signInReason,
    required this.enableHint,
    required this.promptHint,
    required this.notEnrolled,
    required this.failed,
  });

  /// The name of the feature: the button, the settings row and the sheet
  /// title all use this.
  final String signInTitle;

  /// Shown on the phone's own prompt while turning it on.
  final String enableReason;

  /// Shown on the phone's own prompt while signing in.
  final String signInReason;

  /// What to do after the password, on the enable sheet.
  final String enableHint;

  /// The hint under Android's prompt.
  final String promptHint;

  /// Nothing is enrolled on the phone itself.
  final String notEnrolled;

  /// The scan failed for a reason worth telling the user about.
  final String failed;

  String get enabledToast => 'تم تفعيل $signInTitle';

  String get disabledToast => 'تم إيقاف $signInTitle';

  /// Asked for before it was ever turned on.
  String get notSetUp => 'فعّل $signInTitle من صفحة حسابي أولاً';

  /// The server no longer accepts this phone's token.
  String get expired =>
      'انتهت صلاحية $signInTitle. سجّل الدخول بكلمة المرور ثم فعّلها من جديد';
}
