import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    // Seeded from the brand gold, so Material's own pieces (date picker,
    // progress spinner, text selection) match the design instead of the
    // template's default indigo.
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.gold,
      surface: AppColors.paper,
    ),
    // Same colour as the page headers, so a header and its screen read as one.
    scaffoldBackgroundColor: AppColors.paper,
  );
}
