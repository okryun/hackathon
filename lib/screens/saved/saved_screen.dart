import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/mock_products.dart';
import '../../models/product.dart';
import '../../services/wishlist_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/product_card.dart';

/// 05. Saved
/// 사용자가 찜한 상품을 Grid 형태로 보여준다.
class SavedScreen extends StatelessWidget {
  final ValueChanged<String> onProductTap;
  final VoidCallback onExploreTap;

  const SavedScreen({super.key, required this.onProductTap, required this.onExploreTap});

  @override
  Widget build(BuildContext context) {
    final favoriteIds = context.watch<WishlistProvider>().favoriteIds;
    final List<Product> savedProducts =
        mockProducts.where((p) => favoriteIds.contains(p.id)).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Saved${savedProducts.isEmpty ? '' : ' (${savedProducts.length})'}'),
      ),
      body: SafeArea(
        child: savedProducts.isEmpty
            ? EmptyState(
                icon: Icons.favorite_border,
                message: '아직 저장한 상품이 없습니다.',
                buttonLabel: '상품 탐색하러 가기',
                onButtonTap: onExploreTap,
              )
            : GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.6,
                ),
                itemCount: savedProducts.length,
                itemBuilder: (context, index) {
                  final product = savedProducts[index];
                  return ProductCard(
                    product: product,
                    onTap: () => onProductTap(product.id),
                  );
                },
              ),
      ),
    );
  }
}
