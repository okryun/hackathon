import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? buttonLabel;
  final VoidCallback? onButtonTap;

  const EmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.buttonLabel,
    this.onButtonTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: AppColors.textTertiary),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(color: AppColors.textSecondary),
            ),
            if (buttonLabel != null) ...[
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: onButtonTap,
                child: Text(buttonLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
