import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/mock_products.dart';
import '../../models/product.dart';
import '../../services/ar_session_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../utils/formatters.dart';
import '../../widgets/empty_state.dart';

/// Bottom Navigation의 'AR' 탭.
/// 최근 AR로 체험해본 상품들을 모아 보여주고, 다시 체험할 수 있도록 안내한다.
class ArTabScreen extends StatelessWidget {
  final ValueChanged<String> onProductTap;
  final VoidCallback onExploreTap;

  const ArTabScreen({super.key, required this.onProductTap, required this.onExploreTap});

  @override
  Widget build(BuildContext context) {
    final arSession = context.watch<ArSessionProvider>();
    final triedIds = arSession.recentTriedProductIds;
    final triedProducts = triedIds
        .map((id) => findMockProductById(id))
        .whereType<Product>()
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('AR 체험 기록')),
      body: SafeArea(
        child: triedProducts.isEmpty
            ? EmptyState(
                icon: Icons.view_in_ar_outlined,
                message: '아직 AR로 체험해본 상품이 없어요.\n마음에 드는 상품을 AR로 착용해보세요.',
                buttonLabel: '상품 둘러보기',
                onButtonTap: onExploreTap,
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                itemCount: triedProducts.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final product = triedProducts[index];
                  final count = arSession.usageCount(product.id);
                  final total = arSession.totalDuration(product.id);
                  return _ArHistoryTile(
                    product: product,
                    usageCount: count,
                    totalDuration: total,
                    onTap: () => onProductTap(product.id),
                  );
                },
              ),
      ),
    );
  }
}

class _ArHistoryTile extends StatelessWidget {
  final Product product;
  final int usageCount;
  final Duration totalDuration;
  final VoidCallback onTap;

  const _ArHistoryTile({
    required this.product,
    required this.usageCount,
    required this.totalDuration,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                product.image,
                width: 64,
                height: 64,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 64,
                  height: 64,
                  color: AppColors.divider,
                  child: const Icon(Icons.image_outlined, color: AppColors.textTertiary),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.brand, style: AppTypography.label),
                  const SizedBox(height: 2),
                  Text(product.name, style: AppTypography.body, maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(Formatters.price(product.price), style: AppTypography.price),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('AR $usageCount회', style: AppTypography.caption),
                const SizedBox(height: 2),
                Text(Formatters.duration(totalDuration), style: AppTypography.caption),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
