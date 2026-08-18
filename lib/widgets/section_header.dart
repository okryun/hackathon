import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onSeeAll;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.h2),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(subtitle!, style: AppTypography.caption),
              ],
            ],
          ),
        ),
        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('더보기', style: AppTypography.caption),
                Icon(Icons.chevron_right, size: 16, color: AppColors.textSecondary),
              ],
            ),
          ),
      ],
    );
  }
}
