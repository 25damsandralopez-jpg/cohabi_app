import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class CohabiTextStyles {
  static const TextStyle pageTitle = TextStyle(
    color: CohabiColors.navy,
    fontSize: 28,
    fontWeight: FontWeight.w800,
  );

  static const TextStyle sectionTitle = TextStyle(
    color: CohabiColors.navy,
    fontSize: 20,
    fontWeight: FontWeight.w800,
  );

  static const TextStyle cardTitle = TextStyle(
    color: CohabiColors.navy,
    fontSize: 16,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle body = TextStyle(
    color: CohabiColors.textSecondary,
    fontSize: 14,
    height: 1.45,
  );

  static const TextStyle label = TextStyle(
    color: CohabiColors.navy,
    fontSize: 13,
    fontWeight: FontWeight.w700,
  );
}
