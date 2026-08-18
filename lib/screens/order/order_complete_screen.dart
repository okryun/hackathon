import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../utils/formatters.dart';

class OrderCompleteScreen extends StatelessWidget {
  final String orderNumber;
  final String productSummary;
  final int totalPrice;
  final String customerName;

  const OrderCompleteScreen({
    super.key,
    required this.orderNumber,
    required this.productSummary,
    required this.totalPrice,
    this.customerName = '지민',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
          child: Column(
            children: [
              const Text(
                '구매 완료',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 48),
              Container(
                width: 84,
                height: 84,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.fromBorderSide(
                    BorderSide(color: Colors.black, width: 2),
                  ),
                ),
                child: const Icon(
                  Icons.check,
                  size: 40,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                '구매가 완료되었습니다!',
                style: AppTypography.body.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '감사합니다, $customerName님.',
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 40),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE7E3DC)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _OrderInfoRow(label: '주문 번호', value: orderNumber),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Divider(height: 1),
                    ),
                    _OrderInfoRow(label: '구매 제품', value: productSummary),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Divider(height: 1),
                    ),
                    _OrderInfoRow(
                      label: '구매 금액',
                      value: Formatters.price(totalPrice),
                      valueStyle: AppTypography.price,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    context.go('/home?tab=4');
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
                    'MY 페이지로 이동',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
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

class _OrderInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? valueStyle;

  const _OrderInfoRow({
    required this.label,
    required this.value,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: valueStyle ??
              AppTypography.body.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
