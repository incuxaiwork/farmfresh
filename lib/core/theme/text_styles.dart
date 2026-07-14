// This file defines the standardized text styles across the application.
// It utilizes Google Fonts for a clean, professional look.
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class AppTextStyles {
  // Dashboard Hero Numbers - Large, bold stats (32-34px, weight 500)
  static TextStyle get heroNumber => GoogleFonts.inter(
        fontSize: 34,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.5,
      );

  static TextStyle get heroNumberLarge => GoogleFonts.inter(
        fontSize: 40,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.8,
      );

  // Supporting labels for hero numbers (12-13px, secondary color)
  static TextStyle get heroLabel => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.2,
      );

  // Trend indicators (small percentage with arrow)
  static TextStyle get trendPositive => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.success,
      );

  static TextStyle get trendNegative => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.error,
      );

  // Headings
  static TextStyle get displayLarge => GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        letterSpacing: -1.0,
      );

  static TextStyle get displayMedium => GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
      );

  static TextStyle get titleLarge => GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w600,
      );

  // Body Text
  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.normal,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.normal,
      );

  // Captions & Buttons
  static TextStyle get labelLarge => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      );
      
  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.normal,
      );
}
