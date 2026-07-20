// This file defines the centralized color palette for the farm products marketplace.
// It includes primary greens, secondary colors, backgrounds, and text colors.
import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors - Updated Dark Theme Palette
  static const Color primaryGreen = Color(0xFF4ADE80); // Primary accent green
  static const Color lightGreen = Color(0xFF6EE7B7);
  static const Color darkGreen = Color(0xFF1F5B3A); // Dimmed green for chips/backgrounds
  static const Color farmerPrimary = Color(0xFF2E7D32); // Unified richer green for Farmer Dashboard

  static const Color accentOrange = Color(0xFFF59E0B);

  // Background Colors - Light Theme
  static const Color backgroundLight = Color(0xFFF2F8F4); // Light green background
  static const Color surfaceLight = Color(0xFFFFFFFF); // White card background
  static const Color surfaceContainerHighestLight = Color(0xFFF5F9F6); // Input fill
  
  // Background Colors - Dark Theme
  static const Color backgroundDark = Color(0xFF0F172A); // Slate dark background
  static const Color surfaceDark = Color(0xFF1E293B); // Slate card background
  static const Color surfaceContainerHighestDark = Color(0xFF334155); // Slate input fill

  // Text Colors
  static const Color textPrimaryLight = Color(0xFF0F172A); // Slate dark text
  static const Color textSecondaryLight = Color(0xFF475569); // Muted slate text

  static const Color textPrimaryDark = Color(0xFFF8FAFC); // White/light text
  static const Color textSecondaryDark = Color(0xFF94A3B8); // Muted light text

  // Border
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderDark = Color(0xFF334155);

  // Status Colors
  static const Color error = Color(0xFFEF4444); // Danger/alert red
  static const Color success = Color(0xFF22C55E);

  // Chip backgrounds
  static const Color chipBackgroundLight = Color(0xFFDCFCE7);
  static const Color chipBackgroundDark = Color(0xFF1E293B);
}
