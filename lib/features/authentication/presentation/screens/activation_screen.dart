import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../widgets/otp_input.dart';

enum _Step { details, code, password }

/// First-time login for a user the hotel admin invited:
/// 1. username + phone → the server sends an SMS code
/// 2. the 6-digit code → an activation token
/// 3. a new password → the account is active, go to login
class ActivationScreen extends ConsumerStatefulWidget {
  const ActivationScreen({super.key});

  @override
  ConsumerState<ActivationScreen> createState() => _ActivationScreenState();
}

class _ActivationScreenState extends ConsumerState<ActivationScreen> {
  final _username = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _otpKey = GlobalKey<OtpInputState>();

  var _step = _Step.details;
  var _code = '';
  String? _activationToken;
  var _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _username.dispose();
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  /// Runs a server call with the loading flag and error message handled.
  Future<void> _run(Future<void> Function() call) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await call();
    } on AppException catch (error) {
      _error = error.message;
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _sendCode() async {
    final username = _username.text.trim();
    final phone = _phone.text.trim();
    if (username.isEmpty || phone.isEmpty) {
      setState(() => _error = 'أدخل اسم المستخدم ورقم الهاتف.');
      return;
    }
    await _run(() async {
      await ref.read(authRepositoryProvider).requestActivation(username, phone);
      _step = _Step.code;
    });
  }

  Future<void> _verifyCode() async {
    if (_code.length != 6) {
      setState(() => _error = 'أدخل الرمز المكوّن من 6 أرقام.');
      return;
    }
    await _run(() async {
      _activationToken = await ref
          .read(authRepositoryProvider)
          .verifyActivation(_username.text.trim(), _phone.text.trim(), _code);
      _step = _Step.password;
    });
    if (_error != null) _otpKey.currentState?.clear();
  }

  Future<void> _setPassword() async {
    final password = _password.text;
    // Same rule as the server: 8+ characters, a letter and a number.
    final strong =
        password.length >= 8 &&
        RegExp(r'[A-Za-z]').hasMatch(password) &&
        RegExp(r'[0-9]').hasMatch(password);
    if (!strong) {
      setState(() => _error = 'كلمة المرور 8 أحرف على الأقل وفيها حرف ورقم.');
      return;
    }
    await _run(() async {
      await ref
          .read(authRepositoryProvider)
          .completeActivation(_activationToken!, password);
      if (!mounted) return;
      showNzToast(context, 'تم تفعيل الحساب، سجّل الدخول الآن');
      context.go(AppRoutes.login);
    });
  }

  @override
  Widget build(BuildContext context) {
    final (subtitle, button, onPressed) = switch (_step) {
      _Step.details => (
        'أدخل اسم المستخدم ورقم الهاتف الذي سجّله مدير الفندق، وسيصلك رمز برسالة.',
        'إرسال الرمز',
        _sendCode,
      ),
      _Step.code => (
        'أدخل الرمز الذي وصلك برسالة نصية. صلاحيته 5 دقائق.',
        'تأكيد الرمز',
        _verifyCode,
      ),
      _Step.password => (
        'اختر كلمة مرور لحسابك.',
        'تفعيل الحساب',
        _setPassword,
      ),
    };

    return Scaffold(
      backgroundColor: AppColors.paperWarm,
      body: Column(
        children: [
          NzPageHeader(
            showBack: true,
            subtitle: 'الخطوة ${_step.index + 1} من 3',
            title: 'تفعيل الحساب',
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  subtitle,
                  style: AppText.body(
                    14.5,
                    color: AppColors.inkMuted,
                    height: 1.7,
                  ),
                ),
                const SizedBox(height: 18),
                NzCard(
                  radius: 24,
                  shadow: AppShadows.card,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ..._fields(),
                      if (_error != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _error!,
                          style: AppText.body(13, color: AppColors.goldDeep),
                        ),
                      ],
                      const SizedBox(height: 20),
                      NzPrimaryButton(
                        label: _isLoading ? 'جارٍ الإرسال...' : button,
                        icon: LucideIcons.check,
                        disabled: _isLoading,
                        onPressed: onPressed,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _fields() {
    switch (_step) {
      case _Step.details:
        return [
          NzTextField(
            label: 'اسم المستخدم',
            controller: _username,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.right,
            style: AppText.body(16),
          ),
          const SizedBox(height: 16),
          NzTextField(
            label: 'رقم الهاتف',
            hint: '07700000000',
            controller: _phone,
            keyboardType: TextInputType.phone,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.right,
            style: AppText.num(16, weight: FontWeight.w500),
          ),
        ];
      case _Step.code:
        return [
          OtpInput(key: _otpKey, onChanged: (v) => _code = v),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _isLoading ? null : _sendCode,
            child: Text(
              'إعادة إرسال الرمز',
              style: AppText.body(13.5, color: AppColors.goldDeep),
            ),
          ),
        ];
      case _Step.password:
        return [
          NzTextField(
            label: 'كلمة المرور الجديدة',
            hint: '••••••••',
            controller: _password,
            obscureText: true,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.right,
            style: AppText.body(16),
          ),
        ];
    }
  }
}
