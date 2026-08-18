import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Explore의 필터, Home의 카테고리 등에서 재사용하는 선택형 Chip.
class CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? trailingIcon;

  const CategoryChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.trailingIcon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.ink : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.ink : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTypography.body.copyWith(
                color: selected ? AppColors.textOnDark : AppColors.textPrimary,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            if (trailingIcon != null) ...[
              const SizedBox(width: 4),
              Icon(
                trailingIcon,
                size: 16,
                color: selected ? AppColors.textOnDark : AppColors.textSecondary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
