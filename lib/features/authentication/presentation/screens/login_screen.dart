import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/widgets.dart';
import '../widgets/otp_input.dart';

enum _Step { credentials, otp }

/// Sign in: username + Iraqi mobile number, then a 6-digit code.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _username = TextEditingController();
  final _phone = TextEditingController();
  final _otpKey = GlobalKey<OtpInputState>();

  var _step = _Step.credentials;
  var _phoneError = false;
  var _remember = false;
  var _otp = '';
  var _secondsLeft = 0;
  Timer? _timer;

  String get _digits => _phone.text.replaceAll(RegExp(r'\D'), '');

  @override
  void dispose() {
    _timer?.cancel();
    _username.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() => _secondsLeft = (_secondsLeft - 1).clamp(0, 60));
      if (_secondsLeft == 0) t.cancel();
    });
  }

  void _sendCode() {
    if (!RegExp(r'^7\d{9}$').hasMatch(_digits)) {
      setState(() => _phoneError = true);
      return;
    }
    setState(() {
      _step = _Step.otp;
      _otp = '';
    });
    _startTimer();
    Future.delayed(
      const Duration(milliseconds: 60),
      () => _otpKey.currentState?.focusFirst(),
    );
  }

  void _editPhone() {
    _timer?.cancel();
    setState(() => _step = _Step.credentials);
  }

  void _resend() {
    _otpKey.currentState?.clear();
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    final isOtp = _step == _Step.otp;
    return Scaffold(
      backgroundColor: AppColors.paperWarm,
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.paddingOf(context).top + 28,
              ),
              child: Column(
                children: [
                  _Intro(
                    title: isOtp ? 'رمز التحقق' : 'تسجيل الدخول',
                    subtitle: isOtp ? 'أدخل الرمز المؤقت لإكمال الدخول.' : 'أدخل اسم المستخدم ورقم جوالك، وسنرسل لك رمز دخول مؤقتاً.',
                  ),
                  const Spacer(),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      24,
                      16,
                      34 + MediaQuery.paddingOf(context).bottom,
                    ),
                    child: Column(
                      children: [
                        AnimatedSwitcher(
                          duration: AppMotion.popIn,
                          child: isOtp
                              ? _otpCard(key: const ValueKey('otp'))
                              : _credentialsCard(key: const ValueKey('cred')),
                        ),
                        const SizedBox(height: 18),
                        const _SupportLine(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _credentialsCard({Key? key}) {
    return _StepCard(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      children: [
        const _FieldLabel('اسم المستخدم'),
        const SizedBox(height: 7),
        NzTextField(
          controller: _username,
          hint: 'اسم المستخدم',
          height: 54,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.right,
          autofillHints: const [AutofillHints.username],
          style: AppText.body(16),
        ),
        const SizedBox(height: 18),
        const _FieldLabel('رقم الجوال'),
        const SizedBox(height: 7),
        Directionality(
          textDirection: TextDirection.ltr,
          child: NzTextField(
            controller: _phone,
            hint: '770 000 0000',
            height: 54,
            error: _phoneError,
            keyboardType: TextInputType.phone,
            autofillHints: const [AutofillHints.telephoneNumberNational],
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d ]')),
            ],
            style: AppText.num(
              16,
              weight: FontWeight.w500,
              height: 1,
              letterSpacing: .64,
            ),
            onChanged: (_) {
              if (_phoneError) setState(() => _phoneError = false);
            },
            prefix: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: const BoxDecoration(
                color: AppColors.paper,
                border: Border(right: BorderSide(color: AppColors.lineStrong)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    LucideIcons.smartphone,
                    size: 16,
                    color: AppColors.goldDeep,
                  ),
                  const SizedBox(width: 7),
                  Text(
                    '+964',
                    style: AppText.num(
                      15,
                      weight: FontWeight.w500,
                      color: AppColors.ink3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_phoneError) ...[
          const SizedBox(height: 7),
          Text(
            'أدخل رقماً من 10 أرقام يبدأ بـ 7.',
            style: AppText.body(13, color: AppColors.goldDeep),
          ),
        ],
        const SizedBox(height: 8),
        InkWell(
          onTap: () => setState(() => _remember = !_remember),
          borderRadius: BorderRadius.circular(8),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44),
            child: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: Checkbox(
                    value: _remember,
                    onChanged: (v) => setState(() => _remember = v ?? false),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'تذكّرني على هذا الجهاز',
                  style: AppText.body(14, color: AppColors.ink3),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        NzPrimaryButton(
          label: 'إرسال رمز التحقق',
          icon: LucideIcons.messageSquare,
          onPressed: _sendCode,
          height: 56,
          radius: 18,
          fontSize: 16,
          weight: FontWeight.w500,
          shadow: AppShadows.ink,
        ),
      ],
    );
  }

  Widget _otpCard({Key? key}) {
    final full = _otp.length == 6;
    final d = _digits;
    final masked = d.length >= 4
        ? '+964 ${d.substring(0, 3)} ••• ${d.substring(d.length - 4)}'
        : '+964';
    return _StepCard(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
      children: [
        const Center(child: _PulsingShield()),
        const SizedBox(height: 10),
        Text(
          'أرسلنا رمزاً من 6 أرقام إلى',
          textAlign: TextAlign.center,
          style: AppText.body(14.5, color: AppColors.inkMuted, height: 1.7),
        ),
        const SizedBox(height: 10),
        Text(
          masked,
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
          style: AppText.num(17, height: 1, letterSpacing: .5),
        ),
        Center(
          child: NzLinkButton(label: 'تغيير الرقم', onPressed: _editPhone),
        ),
        const SizedBox(height: 12),
        OtpInput(key: _otpKey, onChanged: (v) => setState(() => _otp = v)),
        const SizedBox(height: 22),
        NzPrimaryButton(
          label: 'تأكيد ودخول',
          onPressed: () => context.go(AppRoutes.home),
          disabled: !full,
          height: 56,
          radius: 18,
          fontSize: 16,
          weight: FontWeight.w500,
          shadow: full ? AppShadows.ink : null,
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 44,
          child: _secondsLeft > 0
              ? Center(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(text: 'إعادة الإرسال بعد '),
                        TextSpan(
                          text: '0:${_secondsLeft.toString().padLeft(2, '0')}',
                          style: AppText.num(14, color: AppColors.ink3),
                        ),
                      ],
                    ),
                    style: AppText.body(14, color: AppColors.inkFaint),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'لم يصلك الرمز؟',
                      style: AppText.body(14, color: AppColors.inkFaint),
                    ),
                    const SizedBox(width: 2),
                    NzLinkButton(
                      label: 'إعادة الإرسال',
                      weight: FontWeight.w600,
                      onPressed: _resend,
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _Intro extends StatelessWidget {
  const _Intro({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const NzBrandMark(size: 64, radius: 22),
          const SizedBox(height: 14),
          Text(title, style: AppText.display(28)),
          const SizedBox(height: 14),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppText.body(15, color: AppColors.inkMuted, height: 1.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({super.key, required this.children, required this.padding});

  final List<Widget> children;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return NzCard(
          radius: 30,
          shadow: AppShadows.card,
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        )
        .animate()
        .fadeIn(duration: AppMotion.popIn, curve: AppMotion.easeOut)
        .moveY(
          begin: 10,
          end: 0,
          duration: AppMotion.popIn,
          curve: AppMotion.easeOut,
        );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: AppText.body(13.5, weight: FontWeight.w500, color: AppColors.ink3),
  );
}

/// Shield icon with an expanding gold ring.
class _PulsingShield extends StatelessWidget {
  const _PulsingShield();

  @override
  Widget build(BuildContext context) {
    final disc = Container(
      width: 56,
      height: 56,
      decoration: const BoxDecoration(
        color: AppColors.goldTint,
        shape: BoxShape.circle,
      ),
    );
    return SizedBox(
      width: 56,
      height: 56,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          disc
              .animate(onPlay: (c) => c.repeat())
              .scaleXY(
                begin: .8,
                end: 1.8,
                duration: 2400.ms,
                curve: AppMotion.easeOut,
              )
              .fade(
                begin: .6,
                end: 0,
                duration: 2400.ms,
                curve: AppMotion.easeOut,
              ),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.goldTint,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.goldBorder),
            ),
            child: const Icon(
              LucideIcons.shieldCheck,
              size: 24,
              color: AppColors.goldDeep,
            ),
          ),
        ],
      ),
    );
  }
}

class _SupportLine extends StatelessWidget {
  const _SupportLine();

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          const TextSpan(text: 'للحصول على حساب راجع مدير الفندق · '),
          TextSpan(
            text: 'الدعم الفني',
            style: AppText.body(
              13,
              color: AppColors.goldDeep,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
      style: AppText.body(13, color: AppColors.inkFaint, height: 1.7),
    );
  }
}
