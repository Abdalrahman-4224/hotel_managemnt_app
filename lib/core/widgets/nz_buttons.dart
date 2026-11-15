import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../theme/app_sizes.dart';

/// Solid ink button (the design's primary action).
class NzPrimaryButton extends StatelessWidget {
  const NzPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this._height,
    this._radius,
    this.background = AppColors.ink,
    this.foreground = AppColors.onInk,
    this.iconColor = AppColors.goldLight,
    this.fontSize = 15.5,
    this.weight = FontWeight.w600,
    this.shadow,
    this.disabled = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double? _height;
  double get height => _height ?? 54.r;
  final double? _radius;
  double get radius => _radius ?? AppRadius.r16;
  final Color background;
  final Color foreground;
  final Color iconColor;
  final double fontSize;
  final FontWeight weight;
  final List<BoxShadow>? shadow;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final enabled = !disabled && onPressed != null;
    return Opacity(
      opacity: disabled ? .45 : 1,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: shadow,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(radius),
            onTap: enabled ? onPressed : null,
            child: _ButtonContent(
              icon: icon,
              iconSize: 18.r,
              iconColor: iconColor,
              gap: 9.r,
              padding: AppSpacing.s16,
              label: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.body(
                  fontSize,
                  weight: weight,
                  color: foreground,
                  height: 1,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// White button with a hairline border (secondary action).
class NzOutlineButton extends StatelessWidget {
  const NzOutlineButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.iconColor = AppColors.goldDeep,
    this._height,
    this._radius,
    this.background = AppColors.card,
    this.foreground = AppColors.ink,
    this.borderColor = AppColors.lineStrong,
    this.fontSize = 15,
    this.weight = FontWeight.w500,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color iconColor;
  final double? _height;
  double get height => _height ?? 52.r;
  final double? _radius;
  double get radius => _radius ?? AppRadius.r16;
  final Color background;
  final Color foreground;
  final Color borderColor;
  final double fontSize;
  final FontWeight weight;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(radius),
          onTap: onPressed,
          child: _ButtonContent(
            icon: icon,
            iconSize: 16.r,
            iconColor: iconColor,
            gap: AppSpacing.s6,
            padding: AppSpacing.s12,
            label: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.body(
                fontSize,
                weight: weight,
                color: foreground,
                height: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Square icon button (44×44, radius 14) used in page headers.
class NzIconButton extends StatelessWidget {
  const NzIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this._size,
    this._radius,
    this._iconSize,
    this.iconColor = AppColors.ink3,
    this.background = AppColors.card,
    this.borderColor = AppColors.lineStrong,
    this.borderWidth = 1,
    this.showDot = false,
    this.badge,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final double? _size;
  double get size => _size ?? 44.r;
  final double? _radius;
  double get radius => _radius ?? AppRadius.r14;
  final double? _iconSize;
  double get iconSize => _iconSize ?? 19.r;
  final Color iconColor;
  final Color background;
  final Color borderColor;
  final double borderWidth;
  final bool showDot;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    Widget button = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(radius),
          onTap: onPressed,
          child: Center(
            child: Icon(icon, size: iconSize, color: iconColor),
          ),
        ),
      ),
    );
    if (showDot || badge != null) {
      button = Stack(
        clipBehavior: Clip.none,
        children: [
          button,
          if (showDot)
            Positioned(
              top: 9.r,
              left: AppSpacing.s10,
              child: Container(
                width: 8.r,
                height: 8.r,
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          if (badge != null)
            Positioned(
              top: -5.r,
              left: -5.r,
              child: Container(
                constraints: BoxConstraints(minWidth: 20.r),
                height: 20.r,
                padding: EdgeInsets.symmetric(horizontal: 5.r),
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: Border.all(color: AppColors.paper, width: 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  badge!,
                  style: AppText.num(11.5, color: Colors.white, height: 1),
                ),
              ),
            ),
        ],
      );
    }
    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}

/// Underlined inline text action (e.g. "تغيير الرقم").
class NzLinkButton extends StatelessWidget {
  const NzLinkButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color = AppColors.goldDeep,
    this.fontSize = 14,
    this.weight = FontWeight.w500,
    this.underline = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color color;
  final double fontSize;
  final FontWeight weight;
  final bool underline;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(AppRadius.r8),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: 44.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.s6),
          child: Center(
            widthFactor: 1,
            child: Text(
              label,
              style: AppText.body(
                fontSize,
                weight: weight,
                color: color,
                height: 1,
                decoration: underline ? TextDecoration.underline : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Icon + label, centred. In a bounded width the label ellipsizes; in an
/// unbounded row (e.g. header actions) the button sizes to its content.
class _ButtonContent extends StatelessWidget {
  const _ButtonContent({
    required this.label,
    required this.icon,
    required this.iconSize,
    required this.iconColor,
    required this.gap,
    required this.padding,
  });

  final Widget label;
  final IconData? icon;
  final double iconSize;
  final Color iconColor;
  final double gap;
  final double padding;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final bounded = c.hasBoundedWidth;
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: padding),
          child: Row(
            mainAxisSize: bounded ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: iconSize, color: iconColor),
                SizedBox(width: gap),
              ],
              bounded ? Flexible(child: label) : label,
            ],
          ),
        );
      },
    );
  }
}
