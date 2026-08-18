import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: AppTypography.fontFamily,
      colorScheme: const ColorScheme.light(
        primary: AppColors.ink,
        onPrimary: AppColors.textOnDark,
        secondary: AppColors.accent,
        onSecondary: AppColors.textOnDark,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: AppTypography.h2,
      ),

      // 시안처럼 채도 낮은 절제된 그림자 / 라운드 사용
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          side: const BorderSide(color: AppColors.divider, width: 1),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.ink,
          foregroundColor: AppColors.textOnDark,
          disabledBackgroundColor: AppColors.textTertiary,
          minimumSize: const Size.fromHeight(52),
          elevation: 0,
          textStyle: AppTypography.button,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          minimumSize: const Size.fromHeight(52),
          side: const BorderSide(color: AppColors.border, width: 1),
          textStyle: AppTypography.button,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          textStyle: AppTypography.button,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 14,
        ),
        hintStyle: AppTypography.body.copyWith(color: AppColors.textTertiary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          borderSide: const BorderSide(color: AppColors.ink, width: 1.4),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.ink,
        unselectedItemColor: AppColors.textTertiary,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        selectedLabelStyle: AppTypography.caption,
        unselectedLabelStyle: AppTypography.caption,
        elevation: 0,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.ink,
        labelStyle: AppTypography.body.copyWith(color: AppColors.textPrimary),
        secondaryLabelStyle: AppTypography.body.copyWith(
          color: AppColors.textOnDark,
        ),
        shape: StadiumBorder(side: const BorderSide(color: AppColors.border)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      ),

      textTheme: const TextTheme(
        displayLarge: AppTypography.display,
        headlineMedium: AppTypography.h1,
        titleMedium: AppTypography.h2,
        bodyLarge: AppTypography.bodyLarge,
        bodyMedium: AppTypography.body,
        bodySmall: AppTypography.caption,
        labelLarge: AppTypography.button,
      ),
    );
  }
}
