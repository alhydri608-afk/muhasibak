import 'package:flutter/material.dart';

class AppColors {
  // خلفيات
  static const Color bgDeep = Color(0xFF0F0F0F);
  static const Color appSurface = Color(0xFF121824);
  static const Color cardSurface = Color(0xFF1E293B);
  static const Color cardDark = Color(0xFF1A2332);

  // ألوان تفاعلية
  static const Color accentGreen = Color(0xFF10B981);
  static const Color accentMint = Color(0xFF4ADE80);
  static const Color accentBlue = Color(0xFF2563EB);
  static const Color accentRed = Color(0xFFEF4444);
  static const Color accentAmber = Color(0xFFF59E0B);

  // نصوص
  static const Color textMain = Color(0xFFF8FAFC);
  static const Color textSub = Color(0xFF94A3B8);

  // حدود
  static const Color borderColor = Color(0xFF334155);

  // للقائمة الرئيسية (فاتح)
  static const Color lightBg = Color(0xFFF8FAFC);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightPrimary = Color(0xFF2A3B50);
  static const Color lightTextMain = Color(0xFF1E293B);
  static const Color lightTextSub = Color(0xFF64748B);
  static const Color lightBorder = Color(0xFFE2E8F0);
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bgDeep,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accentGreen,
        secondary: AppColors.accentBlue,
        surface: AppColors.appSurface,
        error: AppColors.accentRed,
      ),
      fontFamily: 'Cairo',
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.cardDark,
        foregroundColor: AppColors.textMain,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: AppColors.textMain,
        ),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppColors.textMain, fontFamily: 'Cairo'),
        bodyMedium: TextStyle(color: AppColors.textMain, fontFamily: 'Cairo'),
        bodySmall: TextStyle(color: AppColors.textSub, fontFamily: 'Cairo'),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.accentBlue, width: 1.5),
        ),
        hintStyle: const TextStyle(color: AppColors.textSub, fontFamily: 'Cairo'),
        labelStyle: const TextStyle(color: AppColors.textSub, fontFamily: 'Cairo'),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
