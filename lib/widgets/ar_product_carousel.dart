import 'package:flutter/material.dart';
import '../models/product.dart';
import '../theme/app_colors.dart';

/// AR Try-On 화면 하단에서 다른 AR 지원 상품으로 빠르게 전환할 수 있는
/// 작은 썸네일 캐러셀.
class ArProductCarousel extends StatelessWidget {
  final List<Product> products;
  final String currentProductId;
  final ValueChanged<Product> onSelect;

  const ArProductCarousel({
    super.key,
    required this.products,
    required this.currentProductId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: products.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final product = products[index];
          final isSelected = product.id == currentProductId;
          return GestureDetector(
            onTap: () => onSelect(product),
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? Colors.white : Colors.white24,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: Image.network(
                  product.image,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const ColoredBox(
                    color: AppColors.overlayChip,
                    child: Icon(Icons.image_outlined, color: Colors.white70),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
