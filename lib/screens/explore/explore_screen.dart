import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../services/product_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/product_card.dart';

enum SortOption { popular, newest }

/// 03. Explore
/// 검색창 + 필터(Category/Price/Popular/New) + 2열 Grid 상품 리스트.
class ExploreScreen extends StatefulWidget {
  final ValueChanged<String> onProductTap;

  /// Home에서 카테고리를 눌러 진입했을 때 초기 선택 카테고리.
  final String? initialCategory;

  const ExploreScreen({super.key, required this.onProductTap, this.initialCategory});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  late final ProductService _productService;
  final TextEditingController _searchController = TextEditingController();

  List<Product> _allProducts = [];
  List<String> _categories = ['All'];
  bool _isLoading = true;

  String _selectedCategory = 'All';
  SortOption _sort = SortOption.popular;
  bool _priceLowToHigh = false;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _productService = context.read<ProductService>();
    _selectedCategory = widget.initialCategory ?? 'All';
    _load();
  }

  @override
  void didUpdateWidget(covariant ExploreScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialCategory != null &&
        widget.initialCategory != oldWidget.initialCategory) {
      setState(() => _selectedCategory = widget.initialCategory!);
    }
  }

  Future<void> _load() async {
    final products = await _productService.fetchAllProducts();
    final categories = await _productService.fetchCategories();
    if (!mounted) return;
    setState(() {
      _allProducts = products;
      _categories = categories;
      _isLoading = false;
    });
  }

  List<Product> get _filtered {
    final list = _allProducts.where((p) {
      final matchesCategory =
          _selectedCategory == 'All' || p.category == _selectedCategory;
      final matchesQuery = _query.isEmpty ||
          p.name.toLowerCase().contains(_query.toLowerCase()) ||
          p.brand.toLowerCase().contains(_query.toLowerCase());
      return matchesCategory && matchesQuery;
    }).toList();

    if (_sort == SortOption.popular) {
      list.sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
    } else {
      list.sort((a, b) => b.id.compareTo(a.id)); // Mock "신상품" = id desc
    }
    if (_priceLowToHigh) {
      list.sort((a, b) => a.price.compareTo(b.price));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final results = _filtered;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: '브랜드, 상품명을 검색해보세요',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                        ),
                ),
              ),
            ),
            SizedBox(
              height: 42,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  CategoryChip(
                    label: _selectedCategory == 'All' ? 'Category' : _selectedCategory,
                    selected: _selectedCategory != 'All',
                    trailingIcon: Icons.expand_more,
                    onTap: () => _showPickerSheet(
                      title: 'Category',
                      options: _categories,
                      selected: _selectedCategory,
                      onSelected: (v) => setState(() => _selectedCategory = v),
                    ),
                  ),
                  const SizedBox(width: 10),
                  CategoryChip(
                    label: 'Price',
                    selected: _priceLowToHigh,
                    trailingIcon: Icons.swap_vert,
                    onTap: () => setState(() => _priceLowToHigh = !_priceLowToHigh),
                  ),
                  const SizedBox(width: 10),
                  CategoryChip(
                    label: 'Popular',
                    selected: _sort == SortOption.popular,
                    onTap: () => setState(() => _sort = SortOption.popular),
                  ),
                  const SizedBox(width: 10),
                  CategoryChip(
                    label: 'New',
                    selected: _sort == SortOption.newest,
                    onTap: () => setState(() => _sort = SortOption.newest),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : results.isEmpty
                      ? EmptyState(
                          icon: Icons.search_off,
                          message: '조건에 맞는 상품이 없어요.\n다른 검색어나 필터를 시도해보세요.',
                          buttonLabel: '필터 초기화',
                          onButtonTap: () => setState(() {
                            _selectedCategory = 'All';
                            _query = '';
                            _searchController.clear();
                          }),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 28,
                            crossAxisSpacing: 16,
                            childAspectRatio: 0.5,
                          ),
                          itemCount: results.length,
                          itemBuilder: (context, index) {
                            final product = results[index];
                            return ProductCard(
                              product: product,
                              onTap: () => widget.onProductTap(product.id),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPickerSheet({
    required String title,
    required List<String> options,
    required String selected,
    required ValueChanged<String> onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.h2),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final option in options)
                      CategoryChip(
                        label: option,
                        selected: option == selected,
                        onTap: () {
                          onSelected(option);
                          Navigator.pop(context);
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
