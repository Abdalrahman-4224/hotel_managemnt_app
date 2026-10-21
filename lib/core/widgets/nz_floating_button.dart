import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';

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
      height: 54,
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppShadows.floating,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18, color: AppColors.goldLight),
                const SizedBox(width: 8),
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
