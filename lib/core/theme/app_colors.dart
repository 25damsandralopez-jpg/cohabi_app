import 'package:flutter/material.dart';

class CohabiColors {
  // Marca
  static const Color navy = Color(0xFF071747);
  static const Color turquoise = Color(0xFF10B9B4);
  static const Color blue = Color(0xFF4285E8);
  static const Color purple = Color(0xFF7439F5);

  // Colores funcionales
  static const Color orange = Color(0xFFFF9A3C);
  static const Color coral = Color(0xFFFF5364);
  static const Color pink = Color(0xFFEF6F9A);
  static const Color success = Color(0xFF13AD91);

  // Textos
  static const Color textPrimary = navy;
  static const Color textSecondary = Color(0xFF667085);
  static const Color textMuted = Color(0xFF98A2B3);

  // Superficies
  static const Color background = Color(0xFFFAFBFF);
  static const Color surface = Colors.white;
  static const Color border = Color(0xFFE7EAF2);

  // Fondos suaves para iconos/tarjetas
  static const Color turquoiseSoft = Color(0xFFE4F8F6);
  static const Color purpleSoft = Color(0xFFF1EAFF);
  static const Color orangeSoft = Color(0xFFFFF1E4);
  static const Color coralSoft = Color(0xFFFFE9ED);

  // Gradiente principal de Cohabi
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      turquoise,
      blue,
      purple,
    ],
  );
}