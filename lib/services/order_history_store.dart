import 'package:flutter/foundation.dart';

import '../models/order_record.dart';
import 'api_client.dart';

/// 앱 전역 주문 내역 상태.
/// Provider 등록 없이 싱글턴으로 어디서든 OrderHistoryStore.instance 로 접근한다.
class OrderHistoryStore extends ChangeNotifier {
  OrderHistoryStore._internal();
  static final OrderHistoryStore instance = OrderHistoryStore._internal();

  final ApiClient _client = ApiClient.instance;
  final List<OrderRecord> _orders = [];

  /// 최신 주문이 먼저 오도록 정렬해서 반환.
  List<OrderRecord> get orders => List.unmodifiable(_orders.reversed);

  bool get isEmpty => _orders.isEmpty;

  void add(OrderRecord order) {
    _orders.add(order);
    notifyListeners();
  }

  /// 로그인 상태일 때 호출해서, 서버에 저장된 실제 주문 내역으로 갱신한다.
  Future<void> loadFromServer() async {
    if (!_client.hasToken) return;
    try {
      final data = await _client.get('/orders') as List; // 서버가 최신순(desc)으로 내려줌
      final newestFirst = data.map((e) {
        final map = e as Map<String, dynamic>;
        return OrderRecord(
          orderNumber: map['orderNumber'] as String,
          productSummary: map['productSummary'] as String,
          totalPrice: map['totalPrice'] as int,
          orderedAt: DateTime.parse(map['orderedAt'] as String),
        );
      }).toList();

      // 이 클래스는 내부적으로 "오래된 순"으로 저장하고 getter에서 뒤집어 보여주므로,
      // 서버가 준 최신순 목록을 다시 뒤집어서 저장한다.
      _orders
        ..clear()
        ..addAll(newestFirst.reversed);
      notifyListeners();
    } catch (_) {
      // 못 불러와도 조용히 무시한다.
    }
  }
}
