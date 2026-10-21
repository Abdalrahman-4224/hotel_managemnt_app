import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import 'nz_buttons.dart';

/// Top header shared by every screen: optional leading widget,
/// a muted subtitle above a serif title, trailing actions, and an
/// optional [bottom] row (tabs / segmented control).
class NzPageHeader extends StatelessWidget {
  const NzPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.actions = const [],
    this.bottom,
    this.showBack = false,
    this.onBack,
    this.background = AppColors.paper,
    this.bottomGap = 12,
    this.bottomBleeds = false,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget> actions;
  final Widget? bottom;

  /// Shows the 44×44 back button (a right-pointing chevron in RTL).
  final bool showBack;
  final VoidCallback? onBack;
  final Color background;
  final double bottomGap;

  /// Lets [bottom] run edge to edge (for horizontal pill scrollers that
  /// add their own 16px inset).
  final bool bottomBleeds;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return Container(
      decoration: BoxDecoration(
        color: background,
        border: const Border(bottom: BorderSide(color: AppColors.line)),
      ),
      padding: EdgeInsets.only(top: top + 10, bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                if (showBack) ...[
                  NzIconButton(
                    icon: LucideIcons.chevronRight,
                    tooltip: 'رجوع',
                    onPressed: onBack ?? () => Navigator.of(context).maybePop(),
                  ),
                  const SizedBox(width: 10),
                ],
                if (leading != null) ...[leading!, const SizedBox(width: 12)],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.body(12.5, color: AppColors.inkMuted),
                        ),
                      const SizedBox(height: 2),
                      Text(title, style: AppText.display(22)),
                    ],
                  ),
                ),
                for (final a in actions) ...[const SizedBox(width: 10), a],
              ],
            ),
          ),
          if (bottom != null) ...[
            SizedBox(height: bottomGap),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: bottomBleeds ? 0 : 16),
              child: bottom!,
            ),
          ],
        ],
      ),
    );
  }
}

/// Section heading: serif title with an optional link on the far side.
class NzSectionTitle extends StatelessWidget {
  const NzSectionTitle(
    this.title, {
    super.key,
    this.actionLabel,
    this.onAction,
    this.size = 18,
    this.trailing,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final double size;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: AppText.display(size, height: 1.4))),
        ?trailing,
        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionLabel!,
              style: AppText.body(13, color: AppColors.goldDeep),
            ),
          ),
      ],
    );
  }
}

/// Small muted group label used above settings lists.
class NzGroupLabel extends StatelessWidget {
  const NzGroupLabel(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        label,
        style: AppText.body(
          14,
          weight: FontWeight.w600,
          color: AppColors.inkMuted,
          height: 1.4,
        ),
      ),
    );
  }
}
