import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';
import '../../../authentication/presentation/controllers/biometric_controller.dart';

/// Edit the signed-in user's name and email. The phone is shown but locked.
Future<void> showEditProfileSheet(BuildContext context) {
  return showNzSheet<void>(context, builder: (_) => const _EditProfileSheet());
}

/// Change the signed-in user's password.
Future<void> showChangePasswordSheet(BuildContext context) {
  return showNzSheet<void>(
    context,
    builder: (_) => const _ChangePasswordSheet(),
  );
}

/// Turn fingerprint sign-in on: confirm the password, then scan a finger.
Future<void> showEnableBiometricSheet(BuildContext context) {
  return showNzSheet<void>(
    context,
    builder: (_) => const _EnableBiometricSheet(),
  );
}

/// Same rule the server enforces (activation and password change).
String? _passwordProblem(String password) {
  if (password.length < 8) return 'كلمة المرور 8 أحرف على الأقل.';
  if (!RegExp(r'[A-Za-z]').hasMatch(password) ||
      !RegExp(r'[0-9]').hasMatch(password)) {
    return 'كلمة المرور يجب أن تحتوي على حرف ورقم.';
  }
  return null;
}

// ---------------------------------------------------------------- edit profile

class _EditProfileSheet extends ConsumerStatefulWidget {
  const _EditProfileSheet();

  @override
  ConsumerState<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends ConsumerState<_EditProfileSheet> {
  late final _user = ref.read(authControllerProvider).user!;
  late final _name = TextEditingController(text: _user.fullName);
  late final _email = TextEditingController(text: _user.email ?? '');
  var _saving = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'اكتب الاسم الكامل.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref
          .read(authControllerProvider.notifier)
          .updateProfile(fullName: name, email: _email.text.trim());
      if (!mounted) return;
      showNzToast(context, 'تم حفظ المعلومات');
      Navigator.of(context).pop();
    } catch (error) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = errorText(error);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _SheetForm(
      title: 'المعلومات الشخصية',
      error: _error,
      buttonLabel: _saving ? 'جارٍ الحفظ...' : 'حفظ',
      busy: _saving,
      onSubmit: _save,
      children: [
        NzTextField(
          label: 'الاسم الكامل',
          controller: _name,
          style: AppText.body(16),
        ),
        SizedBox(height: AppSpacing.s14),
        NzTextField(
          label: 'البريد الإلكتروني',
          hint: 'name@example.com',
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.right,
          style: AppText.body(16),
        ),
        SizedBox(height: AppSpacing.s14),
        // The phone is how the account is verified, so only the hotel manager
        // may change it. Shown here, but not editable.
        _LockedValue(
          label: 'رقم الهاتف',
          value: _user.phone ?? '—',
          note: 'لا يمكن تغيير رقم الهاتف. راجع مدير الفندق.',
        ),
      ],
    );
  }
}

// ------------------------------------------------------------- change password

class _ChangePasswordSheet extends ConsumerStatefulWidget {
  const _ChangePasswordSheet();

  @override
  ConsumerState<_ChangePasswordSheet> createState() =>
      _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends ConsumerState<_ChangePasswordSheet> {
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();
  var _saving = false;
  String? _error;

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    String? problem;
    if (_current.text.isEmpty) {
      problem = 'اكتب كلمة المرور الحالية.';
    } else if (_next.text != _confirm.text) {
      problem = 'كلمتا المرور الجديدتان غير متطابقتين.';
    } else {
      problem = _passwordProblem(_next.text);
    }
    if (problem != null) {
      setState(() => _error = problem);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref
          .read(authControllerProvider.notifier)
          .changePassword(_current.text, _next.text);
      if (!mounted) return;
      showNzToast(context, 'تم تغيير كلمة المرور');
      Navigator.of(context).pop();
    } catch (error) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = errorText(error);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _SheetForm(
      title: 'تغيير كلمة المرور',
      error: _error,
      buttonLabel: _saving ? 'جارٍ الحفظ...' : 'تغيير كلمة المرور',
      busy: _saving,
      onSubmit: _save,
      children: [
        _PasswordField(label: 'كلمة المرور الحالية', controller: _current),
        SizedBox(height: AppSpacing.s14),
        _PasswordField(label: 'كلمة المرور الجديدة', controller: _next),
        SizedBox(height: AppSpacing.s14),
        _PasswordField(
          label: 'تأكيد كلمة المرور الجديدة',
          controller: _confirm,
        ),
        SizedBox(height: AppSpacing.s8),
        Text(
          '8 أحرف على الأقل، وفيها حرف ورقم.',
          style: AppText.body(12.5, color: AppColors.inkMuted),
        ),
      ],
    );
  }
}

// -------------------------------------------------------------- fingerprint on

class _EnableBiometricSheet extends ConsumerStatefulWidget {
  const _EnableBiometricSheet();

  @override
  ConsumerState<_EnableBiometricSheet> createState() =>
      _EnableBiometricSheetState();
}

class _EnableBiometricSheetState extends ConsumerState<_EnableBiometricSheet> {
  final _password = TextEditingController();
  var _saving = false;
  String? _error;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  Future<void> _enable() async {
    if (_password.text.isEmpty) {
      setState(() => _error = 'اكتب كلمة المرور.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final done = await ref
          .read(authControllerProvider.notifier)
          .enableBiometric(_password.text);
      if (!mounted) return;
      if (!done) {
        // The fingerprint scan was cancelled: stay here so they can retry.
        setState(() => _saving = false);
        return;
      }
      ref.invalidate(biometricStatusProvider);
      showNzToast(context, 'تم تفعيل الدخول بالبصمة');
      Navigator.of(context).pop();
    } catch (error) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = errorText(error);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _SheetForm(
      title: 'الدخول بالبصمة',
      subtitle: 'أكّد كلمة المرور، ثم ضع إصبعك على المستشعر.',
      error: _error,
      buttonLabel: _saving ? 'جارٍ التفعيل...' : 'تفعيل',
      buttonIcon: LucideIcons.fingerprint,
      busy: _saving,
      onSubmit: _enable,
      children: [_PasswordField(label: 'كلمة المرور', controller: _password)],
    );
  }
}

// --------------------------------------------------------------------- shared

/// Title, fields, an error line and one main button.
class _SheetForm extends StatelessWidget {
  const _SheetForm({
    required this.title,
    required this.children,
    required this.buttonLabel,
    required this.busy,
    required this.onSubmit,
    this.subtitle,
    this.error,
    this.buttonIcon = LucideIcons.check,
  });

  final String title;
  final String? subtitle;
  final List<Widget> children;
  final String? error;
  final String buttonLabel;
  final IconData buttonIcon;
  final bool busy;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NzSheetTitle(title, subtitle: subtitle),
        SizedBox(height: AppSpacing.s16),
        ...children,
        if (error != null) ...[
          SizedBox(height: AppSpacing.s12),
          Text(error!, style: AppText.body(13, color: AppColors.goldDeep)),
        ],
        SizedBox(height: AppSpacing.s18),
        NzPrimaryButton(
          label: buttonLabel,
          icon: buttonIcon,
          disabled: busy,
          onPressed: onSubmit,
        ),
      ],
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({required this.label, required this.controller});

  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return NzTextField(
      label: label,
      hint: '••••••••',
      controller: controller,
      obscureText: true,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.right,
      style: AppText.body(16),
    );
  }
}

/// A value the user can see but not change, with the reason.
class _LockedValue extends StatelessWidget {
  const _LockedValue({
    required this.label,
    required this.value,
    required this.note,
  });

  final String label;
  final String value;
  final String note;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: AppText.body(13, color: AppColors.inkMuted)),
        SizedBox(height: AppSpacing.s6),
        Container(
          height: 52.r,
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.s14),
          decoration: BoxDecoration(
            color: AppColors.inert,
            borderRadius: BorderRadius.circular(AppRadius.r16),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.right,
                  style: AppText.num(16, color: AppColors.inkMuted),
                ),
              ),
              SizedBox(width: AppSpacing.s8),
              Icon(LucideIcons.lock, size: 16.r, color: AppColors.inkFaint),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.s6),
        Text(note, style: AppText.body(12, color: AppColors.inkFaint)),
      ],
    );
  }
}
