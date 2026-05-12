import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App color palette - premium modern dark theme
class AppColors {
  AppColors._();

  // Primary palette (Imperial Navy)
  static const Color primary = Color(0xFF1E293B);
  static const Color primaryLight = Color(0xFF334155);
  static const Color primaryDark = Color(0xFF0F172A);

  // Accent (Luminous Teal)
  static const Color accent = Color(0xFF2DD4BF);
  static const Color accentLight = Color(0xFF5EEAD4);
  static const Color accentDark = Color(0xFF14B8A6);

  // Brand Accent (Rose Gold)
  static const Color brand = Color(0xFFFDA4AF);
  static const Color brandLuminous = Color(0xFFFFF1F2);

  // Background
  static const Color background = Color(0xFF020617);
  static const Color surface = Color(0xFF0F172A);
  static const Color surfaceLight = Color(0xFF1E293B);
  static const Color card = Color(0xFF1B2436);

  // Text - Improved Clarity
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFFCBD5E1); // Brighter than 94A3B8
  static const Color textHint = Color(0xFF94A3B8);      // Brighter than 64748B

  // Status
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Premium Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF334155), Color(0xFF1E293B), Color(0xFF0F172A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    colors: [surface, Color(0xFF1E293B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient brandGradient = LinearGradient(
    colors: [accent, Color(0xFF22D3EE), Color(0xFF0891B2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, Color(0xFF06B6D4), Color(0xFF0891B2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient luminousGradient = LinearGradient(
    colors: [accent, Color(0xFF5EEAD4), Colors.white],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient chartGradient = LinearGradient(
    colors: [primary, accent],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  );

  static const LinearGradient glassGradient = LinearGradient(
    colors: [
      Color(0x4DFFFFFF),
      Color(0x1AFFFFFF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Glow & Shadows (Updated with new primary/accent)
  static List<BoxShadow> primaryGlow = [
    BoxShadow(
      color: primary.withValues(alpha: 0.3),
      blurRadius: 15,
      offset: const Offset(0, 5),
      spreadRadius: 1,
    ),
  ];

  static List<BoxShadow> accentGlow = [
    BoxShadow(
      color: accent.withValues(alpha: 0.3),
      blurRadius: 15,
      offset: const Offset(0, 5),
      spreadRadius: 1,
    ),
  ];

  // Shimmer colors - Improved contrast
  static const Color shimmerBase = Color(0xFF1E293B);
  static const Color shimmerHighlight = Color(0xFF475569);
}

/// App-wide text styles using Google Fonts (Outfit)
class AppTextStyles {
  AppTextStyles._();

  static TextStyle get outfit => GoogleFonts.outfit();

  static TextStyle heading1 = GoogleFonts.outfit(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  );

  static TextStyle heading2 = GoogleFonts.outfit(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
  );

  static TextStyle heading3 = GoogleFonts.outfit(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  static TextStyle subtitle = GoogleFonts.outfit(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.5,
  );

  static TextStyle body = GoogleFonts.outfit(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static TextStyle bodySmall = GoogleFonts.outfit(
    fontSize: 12,
    fontWeight: FontWeight.w500, // Medium for better visibility
  );

  static TextStyle caption = GoogleFonts.outfit(
    fontSize: 11,
    fontWeight: FontWeight.w500, // Medium for better visibility
  );

  static TextStyle amount = GoogleFonts.outfit(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.accent, // Improved from textPrimary
    letterSpacing: -0.5,
  );

  static TextStyle amountLarge = GoogleFonts.outfit(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: AppColors.accent, // Using Accent for prominence
    letterSpacing: -1,
  );

  static TextStyle amountHero = GoogleFonts.outfit(
    fontSize: 48,
    fontWeight: FontWeight.w900,
    color: AppColors.brand, // Improved from textPrimary to use brand color
    letterSpacing: -1.5,
  );
}

/// App-wide constants
class AppConstants {
  AppConstants._();

  static const double borderRadius = 16.0;
  static const double borderRadiusSmall = 12.0;
  static const double borderRadiusLarge = 24.0;
  static const double padding = 16.0;
  static const double paddingSmall = 8.0;
  static const double paddingLarge = 24.0;

  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration animationDurationFast = Duration(milliseconds: 150);

  static const String currencySymbol = '₫';
  static const String currencyLocale = 'vi_VN';
}
