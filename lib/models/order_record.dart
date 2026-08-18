/// 완료된 주문 한 건.
class OrderRecord {
  final String orderNumber;
  final String productSummary;
  final int totalPrice;
  final DateTime orderedAt;

  OrderRecord({
    required this.orderNumber,
    required this.productSummary,
    required this.totalPrice,
    required this.orderedAt,
  });
}
