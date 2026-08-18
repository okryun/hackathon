import 'package:flutter/material.dart';

import '../../services/order_history_store.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../utils/formatters.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF9F6),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          '주문 내역',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
      ),
      body: AnimatedBuilder(
        animation: OrderHistoryStore.instance,
        builder: (context, _) {
          final orders = OrderHistoryStore.instance.orders;

          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 56,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '주문 내역이 없어요',
                    style: AppTypography.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final order = orders[index];
              return _OrderCard(order: order);
            },
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final dynamic order; // OrderRecord

  const _OrderCard({required this.order});

  String _formatDate(DateTime date) {
    return '${date.year}년 ${date.month}월 ${date.day}일 · '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE7E3DC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF0EEE9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '구매 완료',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF777777),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            order.productSummary as String,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _formatDate(order.orderedAt as DateTime),
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF777777),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '주문번호 ${order.orderNumber}',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF999999),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              Formatters.price(order.totalPrice as int),
              style: AppTypography.price,
            ),
          ),
        ],
      ),
    );
  }
}
