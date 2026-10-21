import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';

/// Header row for the design's simple tables.
class NzTableHead extends StatelessWidget {
  const NzTableHead({super.key, required this.cells});

  /// (label, flex, fixed width, alignment) – give either a flex or a width.
  final List<(String, int?, double?, TextAlign)> cells;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.paper,
        border: Border(bottom: BorderSide(color: AppColors.lineStrong)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          for (final c in cells)
            _cell(
              c.$2,
              c.$3,
              Text(
                c.$1,
                textAlign: c.$4,
                style: AppText.body(
                  12,
                  weight: FontWeight.w500,
                  color: AppColors.inkMuted,
                  height: 1,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

Widget _cell(int? flex, double? width, Widget child) => width != null
    ? SizedBox(width: width, child: child)
    : Expanded(flex: flex ?? 1, child: child);
