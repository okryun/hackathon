import 'package:flutter/material.dart';

/// 패션 에디토리얼 톤의 미니멀 컬러 팔레트.
/// 참고 시안(첨부 이미지)처럼 블랙 & 오프화이트를 중심으로,
/// 과도한 그라데이션/그림자 없이 절제된 톤을 사용한다.
class AppColors {
  AppColors._();

  // Base
  static const Color background = Color(0xFFFAF9F7); // 오프 화이트
  static const Color surface = Color(0xFFFFFFFF);
  static const Color ink = Color(0xFF111111); // 거의 블랙 (버튼/헤드라인)
  static const Color inkSoft = Color(0xFF2B2B2B);

  // Text
  static const Color textPrimary = Color(0xFF141414);
  static const Color textSecondary = Color(0xFF6F6B66);
  static const Color textTertiary = Color(0xFFA6A29B);
  static const Color textOnDark = Color(0xFFFFFFFF);

  // Line / Divider
  static const Color divider = Color(0xFFE7E4DF);
  static const Color border = Color(0xFFDAD6CF);

  // Accent (아주 절제해서 사용 - 강조 포인트, 뱃지 등)
  static const Color accent = Color(0xFFB08D57); // 뮤트 골드
  static const Color success = Color(0xFF3D8B5F);
  static const Color error = Color(0xFFC0402D);

  // Overlay (AR 카메라 화면 등 다크 오버레이 전용)
  static const Color overlayDark = Color(0xCC0A0A0A);
  static const Color overlayChip = Color(0x33FFFFFF);
}
