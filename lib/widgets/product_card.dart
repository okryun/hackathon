import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../services/cart_store.dart';
import '../services/wishlist_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../utils/formatters.dart';

/// 상품 이미지 + 브랜드 + 상품명 + 가격 + 찜 버튼 + 장바구니 담기로 구성된 공용 카드.
/// Home의 가로 스크롤 리스트, Explore/Saved의 Grid에서 동일하게 사용된다.
class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;

  const ProductCard({super.key, required this.product, this.onTap});

  void _handleAddToCart(BuildContext context) {
    CartStore.instance.add(product);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        content: Text('${product.name}을(를) 장바구니에 담았어요.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isFavorite = context.select<WishlistProvider, bool>(
      (w) => w.isFavorite(product.id),
    );

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 이미지 영역: 셀에 배정된 남은 공간을 채움 (오버플로우 방지)
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    color: AppColors.divider,
                    child: Image.network(
                      product.image,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => const Center(
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                  ),
                ),
                if (!product.inStock)
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        color: AppColors.overlayDark,
                        alignment: Alignment.center,
                        child: const Text(
                          'SOLD OUT',
                          style: TextStyle(
                            color: AppColors.textOnDark,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                // 찜 버튼: 이미지 하단 우측 (이미지 1 스타일)
                Positioned(
                  right: 10,
                  bottom: 10,
                  child: _FavoriteButton(
                    isFavorite: isFavorite,
                    onTap: () =>
                        context.read<WishlistProvider>().toggle(product.id),
                  ),
                ),
                if (product.arAvailable)
                  const Positioned(
                    left: 10,
                    top: 10,
                    child: _ArBadge(),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Flexible(
                child: Text(
                  product.brand,
                  style: AppTypography.label.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 2),
              const Icon(
                Icons.chevron_right,
                size: 15,
                color: AppColors.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            product.name,
            style: AppTypography.body,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            Formatters.price(product.price),
            style: AppTypography.price,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 38,
            child: OutlinedButton(
              onPressed: product.inStock ? () => _handleAddToCart(context) : null,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(color: AppColors.border),
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                '장바구니 담기',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onTap;

  const _FavoriteButton({required this.isFavorite, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
        ),
        child: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          size: 17,
          color: isFavorite ? AppColors.error : AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _ArBadge extends StatelessWidget {
  const _ArBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.ink.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.view_in_ar, size: 11, color: AppColors.textOnDark),
          SizedBox(width: 3),
          Text(
            'AR',
            style: TextStyle(
              color: AppColors.textOnDark,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
