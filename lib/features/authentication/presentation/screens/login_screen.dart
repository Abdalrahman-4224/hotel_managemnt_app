import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/widgets.dart';
import '../controllers/auth_controller.dart';

/// Sign in with username + password.
/// After a successful login the router moves to home by itself.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _username = TextEditingController();
  final _password = TextEditingController();

  /// Shown when a field is empty (before calling the server).
  String? _formError;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  void _signIn() {
    final username = _username.text.trim();
    final password = _password.text;

    if (username.isEmpty || password.isEmpty) {
      setState(() => _formError = 'أدخل اسم المستخدم وكلمة المرور.');
      return;
    }

    setState(() => _formError = null);
    ref.read(authControllerProvider.notifier).signIn(username, password);
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final error = _formError ?? auth.errorMessage;

    return Scaffold(
      backgroundColor: AppColors.paperWarm,
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.paddingOf(context).top + 28.h,
              ),
              child: Column(
                children: [
                  const _Intro(
                    title: 'تسجيل الدخول',
                    subtitle:
                        'أدخل اسم المستخدم وكلمة المرور للدخول إلى حسابك.',
                  ),
                  const Spacer(),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      16.w,
                      24.h,
                      16.w,
                      34.h + MediaQuery.paddingOf(context).bottom,
                    ),
                    // Keeps the form at a readable width on tablets.
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: Column(
                        children: [
                          _loginCard(isLoading: auth.isLoading, error: error),
                          SizedBox(height: 18.h),
                          const _SupportLine(),
                        ],
                      ),
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

  Widget _loginCard({required bool isLoading, String? error}) {
    return _StepCard(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      children: [
        const _FieldLabel('اسم المستخدم'),
        SizedBox(height: 7.h),
        NzTextField(
          controller: _username,
          hint: 'اسم المستخدم',
          height: 54.h,
          error: error != null,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.right,
          autofillHints: const [AutofillHints.username],
          style: AppText.body(16),
        ),
        SizedBox(height: 18.h),
        const _FieldLabel('كلمة المرور'),
        SizedBox(height: 7.h),
        NzTextField(
          controller: _password,
          hint: '••••••••',
          height: 54.h,
          error: error != null,
          obscureText: true,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.right,
          autofillHints: const [AutofillHints.password],
          style: AppText.body(16),
        ),
        if (error != null) ...[
          SizedBox(height: 10.h),
          Text(error, style: AppText.body(13, color: AppColors.goldDeep)),
        ],
        SizedBox(height: 22.h),
        NzPrimaryButton(
          label: isLoading ? 'جارٍ الدخول...' : 'دخول',
          icon: LucideIcons.logIn,
          onPressed: _signIn,
          disabled: isLoading,
          height: 56.h,
          radius: 18.r,
          fontSize: 16,
          weight: FontWeight.w500,
          shadow: AppShadows.ink,
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
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: [
          NzBrandMark(size: 64.r, radius: 22.r),
          SizedBox(height: 14.h),
          Text(title, style: AppText.display(28)),
          SizedBox(height: 14.h),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 300.w),
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
  const _StepCard({required this.children, required this.padding});

  final List<Widget> children;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return NzCard(
          radius: 30.r,
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
          begin: 10.h,
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

class _SupportLine extends StatelessWidget {
  const _SupportLine();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Invited users have no password yet: they set one here.
        TextButton(
          onPressed: () => context.push(AppRoutes.activate),
          child: Text(
            'أول مرة؟ فعّل حسابك',
            style: AppText.body(
              14,
              weight: FontWeight.w500,
              color: AppColors.goldDeep,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        Text(
          'للحصول على حساب راجع مدير الفندق',
          textAlign: TextAlign.center,
          style: AppText.body(13, color: AppColors.inkFaint, height: 1.7),
        ),
      ],
    );
  }
}
