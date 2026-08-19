import 'package:flutter/material.dart';

import '../../models/order_record.dart';
import '../../services/cart_store.dart';
import '../../services/order_history_store.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../utils/formatters.dart';
import '../order/order_complete_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          '장바구니',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
      ),
      body: AnimatedBuilder(
        animation: CartStore.instance,
        builder: (context, _) {
          final items = CartStore.instance.items;

          if (items.isEmpty) {
            return const _EmptyCart();
          }

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _CartItemCard(
                      index: index,
                      item: item,
                    );
                  },
                ),
              ),
              _CartSummary(
                totalPrice: CartStore.instance.totalPrice,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 56,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            '장바구니가 비어있어요',
            style: AppTypography.body.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final int index;
  final dynamic item; // CartItem

  const _CartItemCard({
    required this.index,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final product = item.product;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              product.image,
              width: 84,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 84,
                height: 100,
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
                Text(
                  product.brand,
                  style: AppTypography.label,
                ),
                const SizedBox(height: 4),
                Text(
                  product.name,
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.selectedColor != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '컬러: ${item.selectedColor}',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _QuantityStepper(
                      quantity: item.quantity,
                      onChanged: (next) {
                        CartStore.instance.updateQuantity(index, next);
                      },
                    ),
                    Text(
                      Formatters.price(item.subtotal as int),
                      style: AppTypography.price,
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18, color: AppColors.textSecondary),
            onPressed: () => CartStore.instance.removeAt(index),
          ),
        ],
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  final int quantity;
  final ValueChanged<int> onChanged;

  const _QuantityStepper({
    required this.quantity,
    required this.onChanged,
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
          _StepButton(
            icon: Icons.remove,
            onTap: () => onChanged(quantity - 1),
          ),
          SizedBox(
            width: 28,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          _StepButton(
            icon: Icons.add,
            onTap: () => onChanged(quantity + 1),
          ),
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
        width: 30,
        height: 30,
        child: Icon(icon, size: 15, color: AppColors.textPrimary),
      ),
    );
  }
}

class _CartSummary extends StatelessWidget {
  final int totalPrice;

  const _CartSummary({required this.totalPrice});

  String _buildOrderNumber() {
    final now = DateTime.now();
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    final hh = now.hour.toString().padLeft(2, '0');
    final mm = now.minute.toString().padLeft(2, '0');
    return 'MCM$y$m$d-$hh$mm';
  }

  String _buildProductSummary() {
    final items = CartStore.instance.items;
    if (items.isEmpty) return '';
    final first = items.first;
    final colorSuffix =
        first.selectedColor != null ? ' (${first.selectedColor})' : '';
    if (items.length == 1) {
      return '${first.product.name}$colorSuffix';
    }
    return '${first.product.name}$colorSuffix 외 ${items.length - 1}건';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.divider)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '총 결제금액',
                  style: AppTypography.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  Formatters.price(totalPrice),
                  style: AppTypography.display.copyWith(fontSize: 20),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  // 백엔드(/api/v1/orders)에 실제로 장바구니 → 주문 전환을 요청한다.
                  // (비회원이면 로컬에서만 처리됨)
                  final order = await CartStore.instance.checkout();
                  if (!context.mounted) return;

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
                  OrderHistoryStore.instance.loadFromServer();

                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => OrderCompleteScreen(
                        orderNumber: orderNumber,
                        productSummary: productSummary,
                        totalPrice: total,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  '주문하기',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
