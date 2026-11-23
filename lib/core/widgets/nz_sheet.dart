import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../theme/app_sizes.dart';

/// Opens the design's bottom sheet: rounded 28px top, grabber, dim scrim.
///
/// Uses the root navigator so the sheet covers the bottom nav bar.
Future<T?> showNzSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  Color background = AppColors.sheet,
  EdgeInsets? padding,
  double? gap,
}) {
  final pad =
      padding ??
      EdgeInsets.fromLTRB(AppSpacing.s18, AppSpacing.s10, AppSpacing.s18, 30.r);
  return showModalBottomSheet<T>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: background,
    barrierColor: AppColors.scrim,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.r28)),
    ),
    builder: (ctx) {
      final insets = MediaQuery.viewInsetsOf(ctx).bottom;
      final safe = MediaQuery.paddingOf(ctx).bottom;
      return Padding(
        padding: EdgeInsets.only(bottom: insets),
        child: SingleChildScrollView(
          padding: pad.copyWith(bottom: pad.bottom + safe),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40.r,
                  height: 5.r,
                  decoration: BoxDecoration(
                    color: AppColors.grabber,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                ),
              ),
              SizedBox(height: gap ?? AppSpacing.s14),
              builder(ctx),
            ],
          ),
        ),
      );
    },
  );
}

/// Sheet title (serif 21) with an optional trailing widget.
class NzSheetTitle extends StatelessWidget {
  const NzSheetTitle(this.title, {super.key, this.trailing, this.subtitle});

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: AppText.display(21)),
              if (subtitle != null) ...[
                SizedBox(height: AppSpacing.s2),
                Text(
                  subtitle!,
                  style: AppText.body(13, color: AppColors.inkMuted),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[SizedBox(width: AppSpacing.s10), trailing!],
      ],
    );
  }
}

/// Floating toast that slides in above the bottom of the screen.
void showNzToast(BuildContext context, String message) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.ink,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.r16),
      ),
      margin: EdgeInsets.fromLTRB(
        AppSpacing.s16,
        0,
        AppSpacing.s16,
        AppSpacing.s24,
      ),
      duration: const Duration(milliseconds: 2400),
      content: Text(
        message,
        style: AppText.body(
          14,
          weight: FontWeight.w500,
          color: AppColors.onInk,
        ),
      ),
    ),
  );
}

/// Tall sheet (default 92% height) with a fixed header and footer around a
/// scrolling body – used for multi-section details.
Future<T?> showNzTallSheet<T>(
  BuildContext context, {
  required WidgetBuilder header,
  required WidgetBuilder body,
  WidgetBuilder? footer,
  double heightFactor = .92,
  bool shrinkWrap = false,
}) {
  return showModalBottomSheet<T>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.sheet,
    barrierColor: AppColors.scrim,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.r28)),
    ),
    builder: (ctx) {
      final column = Column(
        mainAxisSize: shrinkWrap ? MainAxisSize.min : MainAxisSize.max,
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.s18,
              AppSpacing.s10,
              AppSpacing.s18,
              AppSpacing.s12,
            ),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.line)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40.r,
                    height: 5.r,
                    decoration: BoxDecoration(
                      color: AppColors.grabber,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.s8),
                header(ctx),
              ],
            ),
          ),
          Flexible(
            fit: shrinkWrap ? FlexFit.loose : FlexFit.tight,
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.s18,
                AppSpacing.s14,
                AppSpacing.s18,
                AppSpacing.s18,
              ),
              child: body(ctx),
            ),
          ),
          if (footer != null)
            Container(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.s18,
                AppSpacing.s12,
                AppSpacing.s18,
                30.r + MediaQuery.paddingOf(ctx).bottom,
              ),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.line)),
              ),
              child: footer(ctx),
            ),
        ],
      );
      // The sheet does not move for the keyboard by itself, so it is lifted
      // above it here and its height taken from what is left: the header and
      // the save button stay in view and the body scrolls between them. This
      // matters most on an iPad on its side, where the keyboard takes half
      // the screen.
      final insets = MediaQuery.viewInsetsOf(ctx).bottom;
      final room = MediaQuery.sizeOf(ctx).height - insets;
      return Padding(
        padding: EdgeInsets.only(bottom: insets),
        child: shrinkWrap
            ? ConstrainedBox(
                constraints: BoxConstraints(maxHeight: room * heightFactor),
                child: column,
              )
            : FractionallySizedBox(heightFactor: heightFactor, child: column),
      );
    },
  );
}

/// Small grey caption over a value, in a white card (used in sheet grids).
class NzFact extends StatelessWidget {
  const NzFact(this.label, this.value, {super.key, this.numeric = false});

  final String label;
  final String value;
  final bool numeric;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.s12,
        vertical: AppSpacing.s10,
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.r14),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppText.body(12, color: AppColors.inkMuted)),
          SizedBox(height: AppSpacing.s3),
          Text(
            value,
            style: numeric
                ? AppText.num(14.5, weight: FontWeight.w500)
                : AppText.body(14, weight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
