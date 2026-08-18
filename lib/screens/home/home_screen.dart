import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/mock_products.dart';
import '../../models/product.dart';
import '../../services/ar_session_provider.dart';
import '../../services/cart_store.dart';
import '../../services/product_service.dart';
import '../../services/wishlist_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../utils/formatters.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/product_card.dart';
import '../../widgets/section_header.dart';
import '../cart/cart_screen.dart';

/// 02. Home
/// 개인화 추천 히어로 / 인기 상품 / 추천 상품 / 최근 많이 AR 체험한 상품 / 카테고리를 보여준다.
class HomeScreen extends StatefulWidget {
  final ValueChanged<String> onProductTap;
  final VoidCallback onSearchTap;
  final ValueChanged<String> onCategoryTap;

  const HomeScreen({
    super.key,
    required this.onProductTap,
    required this.onSearchTap,
    required this.onCategoryTap,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final ProductService _productService;
  late Future<_HomeData> _future;

  @override
  void initState() {
    super.initState();
    _productService = context.read<ProductService>();
    _future = _load();
  }

  Future<_HomeData> _load() async {
    final popular = await _productService.fetchPopular();
    final recommended = await _productService.fetchRecommended();
    final categories = await _productService.fetchCategories();
    return _HomeData(popular: popular, recommended: recommended, categories: categories);
  }

  Future<void> _onRefresh() async {
    final next = _load();
    setState(() => _future = next);
    await next;
  }

  void _openCart() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const CartScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final arSession = context.watch<ArSessionProvider>();
    final recentTriedIds = arSession.recentTriedProductIds.take(6).toList();
    final recentTriedProducts = recentTriedIds
        .map((id) => findMockProductById(id))
        .whereType<Product>()
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FutureBuilder<_HomeData>(
          future: _future,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final data = snapshot.data!;
            final heroProduct =
                data.recommended.isNotEmpty ? data.recommended.first : null;
            final coordiProducts = data.recommended
                .where((p) => heroProduct == null || p.id != heroProduct.id)
                .take(4)
                .toList();

            return RefreshIndicator(
              onRefresh: _onRefresh,
              child: ListView(
                padding: const EdgeInsets.only(bottom: 32),
                children: [
                  _HomeAppBar(
                    onSearchTap: widget.onSearchTap,
                    onCartTap: _openCart,
                  ),
                  const SizedBox(height: 20),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '안녕하세요, 지민님',
                      style: AppTypography.h1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '오늘 당신을 위한 추천',
                      style: AppTypography.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  if (heroProduct != null) ...[
                    const SizedBox(height: 16),
                    _RecommendationHero(
                      product: heroProduct,
                      onTap: () => widget.onProductTap(heroProduct.id),
                    ),
                  ],
                  if (coordiProducts.isNotEmpty) ...[
                    const SizedBox(height: 28),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('맞춤 코디 제안', style: AppTypography.h2),
                    ),
                    const SizedBox(height: 12),
                    _CoordiRow(
                      products: coordiProducts,
                      onProductTap: widget.onProductTap,
                    ),
                  ],
                  const SizedBox(height: 28),
                  if (recentTriedProducts.isNotEmpty) ...[
                    _ProductRowSection(
                      title: '최근 많이 AR 체험한 상품',
                      subtitle: '지금 매장에서 인기 있는 AR 체험이에요',
                      products: recentTriedProducts,
                      onProductTap: widget.onProductTap,
                    ),
                    const SizedBox(height: 28),
                  ],
                  _ProductRowSection(
                    title: '인기 상품',
                    subtitle: '지금 가장 많이 찾는 상품이에요',
                    products: data.popular,
                    onProductTap: widget.onProductTap,
                  ),
                  const SizedBox(height: 28),
                  _ProductRowSection(
                    title: '추천 상품',
                    subtitle: '취향에 맞춰 골라봤어요',
                    products: data.recommended,
                    onProductTap: widget.onProductTap,
                  ),
                  const SizedBox(height: 28),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('카테고리', style: AppTypography.h2),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final category in data.categories)
                          CategoryChip(
                            label: category,
                            selected: false,
                            onTap: () => widget.onCategoryTap(category),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HomeData {
  final List<Product> popular;
  final List<Product> recommended;
  final List<String> categories;
  const _HomeData({
    required this.popular,
    required this.recommended,
    required this.categories,
  });
}

class _HomeAppBar extends StatelessWidget {
  final VoidCallback onSearchTap;
  final VoidCallback onCartTap;

  const _HomeAppBar({
    required this.onSearchTap,
    required this.onCartTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'MIRA',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              color: AppColors.textPrimary,
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: onSearchTap,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(Icons.search, size: 20, color: AppColors.textPrimary),
                ),
              ),
              const SizedBox(width: 8),
              AnimatedBuilder(
                animation: CartStore.instance,
                builder: (context, _) {
                  final count = CartStore.instance.totalCount;
                  return GestureDetector(
                    onTap: onCartTap,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Icon(
                            Icons.shopping_bag_outlined,
                            size: 20,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (count > 0)
                          Positioned(
                            right: -2,
                            top: -2,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: AppColors.error,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 18,
                                minHeight: 18,
                              ),
                              child: Text(
                                count > 9 ? '9+' : '$count',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 오늘의 추천 상품 히어로 카드 (하트로 위시리스트 토글 가능)
class _RecommendationHero extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const _RecommendationHero({
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isFavorite = context.select<WishlistProvider, bool>(
      (wishlist) => wishlist.isFavorite(product.id),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            children: [
              AspectRatio(
                aspectRatio: 1.05,
                child: Container(
                  color: AppColors.divider,
                  child: Image.network(
                    product.image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Center(
                      child: Icon(Icons.image_not_supported_outlined, size: 40),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: GestureDetector(
                  onTap: () {
                    context.read<WishlistProvider>().toggle(product.id);
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      size: 18,
                      color: isFavorite ? AppColors.error : AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.55),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        Formatters.price(product.price),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 맞춤 코디 제안 - 정사각형 썸네일 가로 스크롤
class _CoordiRow extends StatelessWidget {
  final List<Product> products;
  final ValueChanged<String> onProductTap;

  const _CoordiRow({
    required this.products,
    required this.onProductTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: products.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final product = products[index];
          return GestureDetector(
            onTap: () => onProductTap(product.id),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: 110,
                height: 110,
                color: AppColors.divider,
                child: Image.network(
                  product.image,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Center(
                    child: Icon(Icons.image_not_supported_outlined, size: 28),
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

class _ProductRowSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Product> products;
  final ValueChanged<String> onProductTap;

  const _ProductRowSection({
    required this.title,
    required this.subtitle,
    required this.products,
    required this.onProductTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SectionHeader(title: title, subtitle: subtitle),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 340,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final product = products[index];
              return SizedBox(
                width: 150,
                child: ProductCard(
                  product: product,
                  onTap: () => onProductTap(product.id),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
