import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import 'package:provider/provider.dart';

import '../../models/order_record.dart';

import '../../models/product.dart';

import '../../services/cart_store.dart';

import '../../services/order_history_store.dart';

import '../../services/product_service.dart';

import '../../services/recently_viewed_provider.dart';

import '../../services/wishlist_provider.dart';

import '../../theme/app_colors.dart';

import '../../theme/app_typography.dart';

import '../../utils/formatters.dart';

import '../../utils/route_names.dart';

import '../ai_chat/ai_chat_screen.dart';

import '../order/order_complete_screen.dart';

import '../review/review_screen.dart';

/// 04. Product Detail

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({
    super.key,
    required this.productId,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Future<Product?> _future;

  String? _selectedColor;

  @override
  void initState() {
    super.initState();

    final service = context.read<ProductService>();

    _future = service.fetchProductById(widget.productId).then((product) {
      if (product != null) {
        _selectedColor = product.colors.first;

        if (mounted) {
          context.read<RecentlyViewedProvider>().addView(product.id);
        }
      }

      return product;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FutureBuilder<Product?>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final product = snapshot.data;

          if (product == null) {
            return const Center(
              child: Text(
                '상품 정보를 찾을 수 없습니다.',
              ),
            );
          }

          return _DetailBody(
            product: product,
            selectedColor: _selectedColor ?? product.colors.first,
            onColorSelected: (color) {
              setState(() {
                _selectedColor = color;
              });
            },
          );
        },
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  final Product product;

  final String selectedColor;

  final ValueChanged<String> onColorSelected;

  const _DetailBody({
    required this.product,
    required this.selectedColor,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isFavorite = context.select<WishlistProvider, bool>(
      (wishlist) => wishlist.isFavorite(product.id),
    );

    return Column(
      children: [
        Expanded(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: AppColors.background,
                surfaceTintColor: Colors.transparent,
                pinned: true,
                expandedHeight: 440,
                leading: const _CircleIconButton(
                  icon: Icons.arrow_back,
                  isBack: true,
                ),
                actions: [
                  _CircleIconButton(
                    icon: Icons.share_outlined,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            '공유 기능은 준비 중입니다 (Mock)',
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  _CircleIconButton(
                    icon: isFavorite ? Icons.favorite : Icons.favorite_border,
                    iconColor: isFavorite ? AppColors.error : null,
                    onTap: () {
                      context.read<WishlistProvider>().toggle(product.id);
                    },
                  ),
                  const SizedBox(width: 12),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    color: AppColors.divider,
                    child: Image.network(
                      product.image,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            size: 48,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    20,
                    20,
                    24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.brand,
                                  style: AppTypography.label,
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                                Text(
                                  product.name,
                                  style: AppTypography.h1,
                                ),
                              ],
                            ),
                          ),
                          if (product.arAvailable)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.ink,
                                borderRadius: BorderRadius.circular(
                                  20,
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.view_in_ar,
                                    size: 13,
                                    color: AppColors.textOnDark,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'AR',
                                    style: TextStyle(
                                      color: AppColors.textOnDark,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Text(
                            Formatters.price(
                              product.price,
                            ),
                            style: AppTypography.display.copyWith(
                              fontSize: 22,
                            ),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ReviewScreen(product: product),
                                ),
                              );
                            },
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  size: 16,
                                  color: AppColors.accent,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '${product.rating} (${product.reviewCount})',
                                  style: AppTypography.caption.copyWith(
                                    decoration: TextDecoration.underline,
                                    decorationColor: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                const Icon(
                                  Icons.chevron_right,
                                  size: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        '컬러',
                        style: AppTypography.h2,
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        children: [
                          for (final color in product.colors)
                            _ColorChip(
                              label: color,
                              selected: color == selectedColor,
                              onTap: () => onColorSelected(
                                color,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        '상품 설명',
                        style: AppTypography.h2,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.description,
                        style: AppTypography.body.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        _BottomCta(
          product: product,
          selectedColor: selectedColor,
        ),
      ],
    );
  }
}

class _BottomCta extends StatelessWidget {
  final Product product;

  final String selectedColor;

  const _BottomCta({
    required this.product,
    required this.selectedColor,
  });

  void _openPurchaseSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _PurchaseSheet(
          product: product,
          initialColor: selectedColor,
          parentContext: context,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          20,
          14,
          20,
          14,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(
              color: AppColors.divider,
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 보조 액션: AR 착용 / AI 상담
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: Icon(
                      Icons.view_in_ar,
                      size: 18,
                      color: !product.arAvailable
                          ? AppColors.textTertiary
                          : AppColors.textPrimary,
                    ),
                    label: const Text('AR로 착용해보기'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      textStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: !product.arAvailable
                        ? null
                        : () {
                            context.push(
                              Uri(
                                path: RouteNames.arTryOnPath(
                                  product.id,
                                ),
                                queryParameters: {
                                  'color': selectedColor,
                                },
                              ).toString(),
                            );
                          },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(
                      Icons.smart_toy_outlined,
                      size: 18,
                    ),
                    label: const Text('AI에게 물어보기'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      textStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => AiChatScreen(
                            productId: product.id,
                            initialColor: selectedColor,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // 메인 액션: 구매하기
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed:
                    !product.inStock ? null : () => _openPurchaseSheet(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.divider,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  product.inStock ? '구매하기' : '일시 품절',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 구매 옵션 바텀시트: 컬러/수량 선택 + 장바구니 담기 / 바로 구매하기
class _PurchaseSheet extends StatefulWidget {
  final Product product;
  final String initialColor;

  /// 시트를 닫은 뒤에도 유효한, 상품 상세 화면의 BuildContext.
  /// (스낵바 표시와 화면 전환에 사용)
  final BuildContext parentContext;

  const _PurchaseSheet({
    required this.product,
    required this.initialColor,
    required this.parentContext,
  });

  @override
  State<_PurchaseSheet> createState() => _PurchaseSheetState();
}

class _PurchaseSheetState extends State<_PurchaseSheet> {
  late String _color = widget.initialColor;
  int _quantity = 1;

  int get _totalPrice => widget.product.price * _quantity;

  void _incrementQuantity() {
    setState(() => _quantity++);
  }

  void _decrementQuantity() {
    if (_quantity <= 1) return;
    setState(() => _quantity--);
  }

  void _addToCart() {
    CartStore.instance.add(
      widget.product,
      color: _color,
      quantity: _quantity,
    );

    Navigator.of(context).pop();

    ScaffoldMessenger.of(widget.parentContext).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        content: Text('${widget.product.name}을(를) 장바구니에 담았어요.'),
      ),
    );
  }

  String _buildOrderNumber() {
    final now = DateTime.now();
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    final hh = now.hour.toString().padLeft(2, '0');
    final mm = now.minute.toString().padLeft(2, '0');
    return 'MCM$y$m$d-$hh$mm';
  }

  Future<void> _buyNow() async {
    // 백엔드(/api/v1/orders)에 실제로 주문을 생성한다. (비회원이면 로컬에서만 처리됨)
    final order = await CartStore.instance.checkout(
      product: widget.product,
      color: _color,
      quantity: _quantity,
    );

    if (!mounted) return;

    final orderNumber = order['orderNumber'] as String;
    final productSummary = order['productSummary'] as String;
    final total = order['totalPrice'] as int;

    OrderHistoryStore.instance.add(
      OrderRecord(
        orderNumber: orderNumber,
        productSummary: productSummary,
        totalPrice: total,
        orderedAt: DateTime.now(),
      ),
    );
    // 로그인 상태라면 서버에 실제로 저장된 주문 내역으로 다시 한번 갱신한다.
    OrderHistoryStore.instance.loadFromServer();

    Navigator.of(context).pop();

    Navigator.of(widget.parentContext).push(
      MaterialPageRoute(
        builder: (context) => OrderCompleteScreen(
          orderNumber: orderNumber,
          productSummary: productSummary,
          totalPrice: total,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 18),
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        product.image,
                        width: 64,
                        height: 76,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 64,
                          height: 76,
                          color: AppColors.divider,
                          child: const Icon(Icons.image_not_supported_outlined),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(product.brand, style: AppTypography.label),
                          const SizedBox(height: 2),
                          Text(
                            product.name,
                            style: AppTypography.body.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            Formatters.price(product.price),
                            style: AppTypography.price,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text('컬러', style: AppTypography.h2),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final color in product.colors)
                      _ColorChip(
                        label: color,
                        selected: color == _color,
                        onTap: () => setState(() => _color = color),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('수량', style: AppTypography.h2),
                    _QuantityStepper(
                      quantity: _quantity,
                      onIncrement: _incrementQuantity,
                      onDecrement: _decrementQuantity,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '총 상품금액',
                      style: AppTypography.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      Formatters.price(_totalPrice),
                      style: AppTypography.display.copyWith(fontSize: 19),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: OutlinedButton(
                          onPressed: _addToCart,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textPrimary,
                            side: const BorderSide(color: AppColors.border),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            '장바구니 담기',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _buyNow,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            '바로 구매하기',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _QuantityStepper({
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepButton(icon: Icons.remove, onTap: onDecrement),
          SizedBox(
            width: 32,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          _StepButton(icon: Icons.add, onTap: onIncrement),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _StepButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 34,
        height: 34,
        child: Icon(icon, size: 16, color: AppColors.textPrimary),
      ),
    );
  }
}

class _ColorChip extends StatelessWidget {
  final String label;

  final bool selected;

  final VoidCallback onTap;

  const _ColorChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 9,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.ink : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.ink : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.body.copyWith(
            color: selected ? AppColors.textOnDark : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;

  final VoidCallback? onTap;

  final bool isBack;

  final Color? iconColor;

  const _CircleIconButton({
    required this.icon,
    this.onTap,
    this.isBack = false,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: GestureDetector(
        onTap: isBack ? () => Navigator.of(context).maybePop() : onTap,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(
              alpha: 0.9,
            ),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: Icon(
            icon,
            size: 18,
            color: iconColor ?? AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
