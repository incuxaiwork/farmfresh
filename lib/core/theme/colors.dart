// This file defines the centralized color palette for the farm products marketplace.
// It includes primary greens, secondary colors, backgrounds, and text colors.
import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors - Updated Dark Theme Palette
  static const Color primaryGreen = Color(0xFF4ADE80); // Primary accent green
  static const Color lightGreen = Color(0xFF6EE7B7);
  static const Color darkGreen = Color(0xFF1F5B3A); // Dimmed green for chips/backgrounds

  static const Color accentOrange = Color(0xFFF59E0B);

  // Background Colors - Dark Theme
  static const Color backgroundLight = Color(0xFF0B0D0C); // Near-black background
  static const Color surfaceLight = Color(0xFF131614); // Card background
  static const Color surfaceContainerHighest = Color(0xFF1A1D1B); // For input fields

  // Background Colors - Dark (kept for compatibility)
  static const Color backgroundDark = Color(0xFF0B0D0C);
  static const Color surfaceDark = Color(0xFF131614);
  static const Color surfaceContainerHighestDark = Color(0xFF1A1D1B);

  // Text Colors
  static const Color textPrimaryLight = Color(0xFFFFFFFF);
  static const Color textSecondaryLight = Color(0xFF7C877D); // Muted text

  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFF7C877D);

  // Border
  static const Color borderLight = Color(0xFF232823);
  static const Color borderDark = Color(0xFF232823);

  // Status Colors
  static const Color error = Color(0xFFEF6B6B); // Danger/alert red
  static const Color success = Color(0xFF4ADE80);

  // Chip backgrounds
  static const Color chipBackgroundLight = Color(0xFF1F5B3A);
  static const Color chipBackgroundDark = Color(0xFF1F5B3A);
}
