import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';

/// Opens the design's bottom sheet: rounded 28px top, grabber, dim scrim.
///
/// Uses the root navigator so the sheet covers the bottom nav bar.
Future<T?> showNzSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  Color background = AppColors.sheet,
  EdgeInsets padding = const EdgeInsets.fromLTRB(18, 10, 18, 30),
  double gap = 14,
}) {
  return showModalBottomSheet<T>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: background,
    barrierColor: AppColors.scrim,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (ctx) {
      final insets = MediaQuery.viewInsetsOf(ctx).bottom;
      final safe = MediaQuery.paddingOf(ctx).bottom;
      return Padding(
        padding: EdgeInsets.only(bottom: insets),
        child: SingleChildScrollView(
          padding: padding.copyWith(bottom: padding.bottom + safe),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.grabber,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              SizedBox(height: gap),
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
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: AppText.body(13, color: AppColors.inkMuted),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 10), trailing!],
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
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
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (ctx) {
      final column = Column(
        mainAxisSize: shrinkWrap ? MainAxisSize.min : MainAxisSize.max,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.line)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.grabber,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                header(ctx),
              ],
            ),
          ),
          Flexible(
            fit: shrinkWrap ? FlexFit.loose : FlexFit.tight,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
              child: body(ctx),
            ),
          ),
          if (footer != null)
            Container(
              padding: EdgeInsets.fromLTRB(
                18,
                12,
                18,
                30 + MediaQuery.paddingOf(ctx).bottom,
              ),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.line)),
              ),
              child: footer(ctx),
            ),
        ],
      );
      return shrinkWrap
          ? ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(ctx).height * heightFactor,
              ),
              child: column,
            )
          : FractionallySizedBox(heightFactor: heightFactor, child: column);
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppText.body(12, color: AppColors.inkMuted)),
          const SizedBox(height: 3),
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
