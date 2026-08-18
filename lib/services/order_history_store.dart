import 'package:flutter/foundation.dart';

import '../models/order_record.dart';

/// 앱 전역 주문 내역 상태.
/// Provider 등록 없이 싱글턴으로 어디서든 OrderHistoryStore.instance 로 접근한다.
class OrderHistoryStore extends ChangeNotifier {
  OrderHistoryStore._internal();
  static final OrderHistoryStore instance = OrderHistoryStore._internal();

  final List<OrderRecord> _orders = [];

  /// 최신 주문이 먼저 오도록 정렬해서 반환.
  List<OrderRecord> get orders =>
      List.unmodifiable(_orders.reversed);

  bool get isEmpty => _orders.isEmpty;

  void add(OrderRecord order) {
    _orders.add(order);
    notifyListeners();
  }
}
