import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppGradients {
  const AppGradients._();
  static const LinearGradient gradient = LinearGradient(
    colors: [AppColors.accent, AppColors.primary],
    stops: [.03, 0.3],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );
}
