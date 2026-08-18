import 'package:flutter/material.dart';
import 'app_colors.dart';

/// 간결하고 절제된 패션 에디토리얼 타이포그래피.
/// 폰트는 시스템 기본(추후 Pretendard 등 커스텀 폰트로 교체 예정 - assets/fonts 추가 후
/// pubspec.yaml의 fonts 섹션만 채우면 됨).
class AppTypography {
  AppTypography._();

  static const String? fontFamily = null; // TODO: 커스텀 폰트 연결 지점

  static const TextStyle display = TextStyle(
    fontSize: 28,
    height: 1.25,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
  );

  static const TextStyle h1 = TextStyle(
    fontSize: 22,
    height: 1.3,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    color: AppColors.textPrimary,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 18,
    height: 1.3,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    height: 1.5,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    height: 1.5,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    height: 1.4,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const TextStyle label = TextStyle(
    fontSize: 12,
    height: 1.2,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
    color: AppColors.textSecondary,
  );

  static const TextStyle price = TextStyle(
    fontSize: 15,
    height: 1.3,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle button = TextStyle(
    fontSize: 15,
    height: 1.2,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );
}

/// 8pt 그리드 기반 간격 토큰
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
}
