import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';

class NzNavItem {
  const NzNavItem(this.label, this.icon);

  final String label;
  final IconData icon;
}

/// The dark bottom bar with the animated notch under the active tab.
///
/// Used with `Scaffold(extendBody: true)`, so content scrolls behind the
/// transparent notch area. Scrollable bodies should add
/// [NzBottomNav.bodyPadding] to their bottom padding.
class NzBottomNav extends StatelessWidget {
  const NzBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const items = [
    NzNavItem('الرئيسية', LucideIcons.house),
    NzNavItem('حسابي', LucideIcons.userRound),
    NzNavItem('المالية', LucideIcons.wallet),
    NzNavItem('الموظفون', LucideIcons.users),
  ];

  /// Transparent band above the bar where the active circle sits.
  static const _overlap = 26.0;

  /// Height of the bar itself (call from outside the shell's body).
  static double heightOf(BuildContext context) =>
      84 + math.max(MediaQuery.paddingOf(context).bottom, 24);

  // Inside the shell's body, Scaffold(extendBody: true) reports the bar's
  // height as the bottom padding, so these read it from there.

  /// Bottom padding a scroll view needs so its last item clears the bar.
  static double bodyPadding(BuildContext context) =>
      MediaQuery.paddingOf(context).bottom + _overlap;

  /// Bottom offset for a floating action button sitting above the bar.
  static double fabBottom(BuildContext context) =>
      MediaQuery.paddingOf(context).bottom - 8;

  @override
  Widget build(BuildContext context) {
    final height = heightOf(context);
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return SizedBox(
      height: height,
      child: LayoutBuilder(
        builder: (context, c) {
          final colW = c.maxWidth / items.length;
          final visual = rtl ? items.length - 1 - currentIndex : currentIndex;
          final center = (visual + .5) * colW;
          return TweenAnimationBuilder<double>(
            tween: Tween(end: center),
            duration: const Duration(milliseconds: 380),
            curve: Curves.easeOutCubic,
            builder: (context, cx, _) => Stack(
              children: [
                Positioned.fill(child: CustomPaint(painter: _NotchPainter(cx))),
                Row(
                  children: [
                    for (var i = 0; i < items.length; i++)
                      Expanded(
                        child: _NavButton(
                          item: items[i],
                          active: i == currentIndex,
                          onTap: () => onTap(i),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.active,
    required this.onTap,
  });

  final NzNavItem item;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: active,
      label: item.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeOutCubic,
              top: active ? 0 : 40,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeOutCubic,
                width: active ? 54 : 22,
                height: active ? 54 : 22,
                decoration: BoxDecoration(
                  color: active ? AppColors.gold : Colors.transparent,
                  shape: BoxShape.circle,
                  boxShadow: active
                      ? const [
                          BoxShadow(
                            color: Color(0x8C1C1B19),
                            offset: Offset(0, 8),
                            blurRadius: 16,
                            spreadRadius: -8,
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  item.icon,
                  size: 22,
                  color: active ? AppColors.ink : AppColors.onInkMuted,
                ),
              ),
            ),
            Positioned(
              top: 72,
              left: 0,
              right: 0,
              child: Text(
                item.label,
                textAlign: TextAlign.center,
                style: active
                    ? AppText.body(
                        12,
                        weight: FontWeight.w600,
                        color: AppColors.goldLight,
                        height: 1,
                      )
                    : AppText.body(
                        11.5,
                        weight: FontWeight.w500,
                        color: AppColors.onInkMuted,
                        height: 1,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Port of the SVG path:
/// `M0,44 Q0,26 18,26 L c-50,26 C c-30,26 c-34,66 c,66
///  C c+34,66 c+30,26 c+50,26 L W-18,26 Q W,26 W,44 L W,H L0,H Z`
class _NotchPainter extends CustomPainter {
  _NotchPainter(this.c);

  final double c;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final path = Path()
      ..moveTo(0, 44)
      ..quadraticBezierTo(0, 26, 18, 26)
      ..lineTo(c - 50, 26)
      ..cubicTo(c - 30, 26, c - 34, 66, c, 66)
      ..cubicTo(c + 34, 66, c + 30, 26, c + 50, 26)
      ..lineTo(w - 18, 26)
      ..quadraticBezierTo(w, 26, w, 44)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(path, Paint()..color = AppColors.ink);
  }

  @override
  bool shouldRepaint(_NotchPainter old) => old.c != c;
}
