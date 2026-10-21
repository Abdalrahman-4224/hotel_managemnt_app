import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';

/// 44×44 "−" / "+" button for steppers (dark variant for "+").
class NzStepButton extends StatelessWidget {
  const NzStepButton({
    super.key,
    required this.label,
    required this.tooltip,
    required this.onTap,
    this.dark = false,
  });

  final String label;
  final String tooltip;
  final VoidCallback onTap;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: dark ? AppColors.ink : AppColors.card,
            borderRadius: BorderRadius.circular(14),
            border: dark ? null : Border.all(color: AppColors.lineStrong),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppText.num(
              20,
              color: dark ? AppColors.onInk : AppColors.ink,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}
