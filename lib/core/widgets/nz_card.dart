import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// White rounded card with the design's hairline border.
class NzCard extends StatelessWidget {
  const NzCard({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.radius = 20,
    this.color = AppColors.card,
    this.borderColor = AppColors.line,
    this.borderWidth = 1,
    this.shadow,
    this.onTap,
    this.width,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color color;
  final Color? borderColor;
  final double borderWidth;
  final List<BoxShadow>? shadow;
  final VoidCallback? onTap;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final inner = BorderRadius.circular(
      borderColor == null ? radius : (radius - borderWidth).clamp(0, radius),
    );
    Widget content = Padding(padding: padding, child: child);
    if (onTap != null) {
      content = Material(
        type: MaterialType.transparency,
        child: InkWell(onTap: onTap, borderRadius: inner, child: content),
      );
    }
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: borderColor == null
            ? null
            : Border.all(color: borderColor!, width: borderWidth),
        boxShadow: shadow,
      ),
      child: ClipRRect(borderRadius: inner, child: content),
    );
  }
}

/// Dark "ink" surface card used for hero/summary blocks.
class NzInkCard extends StatelessWidget {
  const NzInkCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.radius = 24,
    this.shadow = AppShadows.ink,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final List<BoxShadow>? shadow;

  @override
  Widget build(BuildContext context) {
    return NzCard(
      color: AppColors.ink,
      borderColor: null,
      radius: radius,
      shadow: shadow,
      padding: padding,
      child: DefaultTextStyle.merge(
        style: const TextStyle(color: AppColors.onInk),
        child: child,
      ),
    );
  }
}

/// A hairline divider matching `border-bottom: 1px solid var(--line)`.
class NzDivider extends StatelessWidget {
  const NzDivider({super.key, this.color = AppColors.line});

  final Color color;

  @override
  Widget build(BuildContext context) => Container(height: 1, color: color);
}

/// Card whose children are separated by hairlines (list groups).
class NzListCard extends StatelessWidget {
  const NzListCard({
    super.key,
    required this.children,
    this.radius = 20,
    this.shadow,
  });

  final List<Widget> children;
  final double radius;
  final List<BoxShadow>? shadow;

  @override
  Widget build(BuildContext context) {
    return NzCard(
      radius: radius,
      shadow: shadow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const NzDivider(),
            children[i],
          ],
        ],
      ),
    );
  }
}

/// Dashed rounded outline, used for empty states.
class NzDashedBox extends StatelessWidget {
  const NzDashedBox({
    super.key,
    required this.child,
    this.radius = 18,
    this.color = AppColors.lineStrong,
    this.padding = const EdgeInsets.symmetric(vertical: 36, horizontal: 12),
  });

  final Widget child;
  final double radius;
  final Color color;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedRRectPainter(radius: radius, color: color),
      child: Padding(padding: padding, child: child),
    );
  }
}

class _DashedRRectPainter extends CustomPainter {
  _DashedRRectPainter({required this.radius, required this.color});

  final double radius;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          Radius.circular(radius),
        ).deflate(0.5),
      );
    for (final metric in path.computeMetrics()) {
      var d = 0.0;
      while (d < metric.length) {
        canvas.drawPath(metric.extractPath(d, d + 4), paint);
        d += 7;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedRRectPainter old) =>
      old.radius != radius || old.color != color;
}
