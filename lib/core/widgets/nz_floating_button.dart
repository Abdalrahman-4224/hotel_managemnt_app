import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../theme/app_sizes.dart';

/// Floating dark pill action ("+ حركة جديدة") above the bottom nav.
class NzFloatingButton extends StatelessWidget {
  const NzFloatingButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon = LucideIcons.plus,
  });

  final String label;
  final IconData icon;

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54.r,
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(AppRadius.r18),
        boxShadow: AppShadows.floating,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.r18),
          onTap: onPressed,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.s20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18.r, color: AppColors.goldLight),
                SizedBox(width: AppSpacing.s8),
                Text(
                  label,
                  style: AppText.body(
                    15,
                    weight: FontWeight.w600,
                    color: AppColors.onInk,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
