import 'package:flutter/foundation.dart';

import '../models/cart_item.dart';
import '../models/product.dart';
import 'api_client.dart';

/// 앱 전역 장바구니 상태.
/// Provider 등록 없이 싱글턴으로 어디서든 CartStore.instance 로 접근한다.
///
/// 화면은 항상 즉시 업데이트되고(낙관적 업데이트), 로그인 상태라면
/// 그 뒤에 서버(/api/v1/cart)에도 조용히 반영한다. 비회원은 이 세션
/// 동안만 메모리에 저장되는 기존 Mock 동작 그대로 유지된다.
class CartStore extends ChangeNotifier {
  CartStore._internal();
  static final CartStore instance = CartStore._internal();

  final ApiClient _client = ApiClient.instance;

  final List<CartItem> _items = [];
  // _items와 같은 순서로, 서버에 저장된 장바구니 항목의 id를 기억해둔다.
  // (아직 서버와 동기화 전인 항목은 null)
  final List<String?> _serverIds = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get totalCount => _items.fold(0, (sum, item) => sum + item.quantity);

  int get totalPrice => _items.fold(0, (sum, item) => sum + item.subtotal);

  bool get isEmpty => _items.isEmpty;

  /// 로그인 직후 호출해서, 서버에 저장된 장바구니를 불러와 동기화한다.
  Future<void> loadFromServer() async {
    if (!_client.hasToken) return;
    try {
      final data = await _client.get('/cart') as Map<String, dynamic>;
      final serverItems = data['items'] as List;

      _items.clear();
      _serverIds.clear();
      for (final raw in serverItems) {
        final map = raw as Map<String, dynamic>;
        _items.add(
          CartItem(
            product: Product.fromJson(map['product'] as Map<String, dynamic>),
            selectedColor: map['selectedColor'] as String?,
            quantity: map['quantity'] as int,
          ),
        );
        _serverIds.add(map['id'] as String);
      }
      notifyListeners();
    } catch (_) {
      // 못 불러와도 조용히 무시한다.
    }
  }

  void add(Product product, {String? color, int quantity = 1}) {
    final index = _items.indexWhere(
      (item) => item.product.id == product.id && item.selectedColor == color,
    );

    if (index != -1) {
      _items[index].quantity += quantity;
    } else {
      _items.add(
        CartItem(product: product, selectedColor: color, quantity: quantity),
      );
      _serverIds.add(null);
    }

    notifyListeners();

    if (!_client.hasToken) return;
    _client.post('/cart/items', body: {
      'productId': product.id,
      if (color != null) 'color': color,
      'quantity': quantity,
    }).then((_) => loadFromServer()).catchError((_) {});
  }

  void removeAt(int index) {
    final serverId = index < _serverIds.length ? _serverIds[index] : null;

    _items.removeAt(index);
    if (index < _serverIds.length) _serverIds.removeAt(index);
    notifyListeners();

    if (_client.hasToken && serverId != null) {
      _client.delete('/cart/items/$serverId').catchError((_) {});
    }
  }

  void updateQuantity(int index, int quantity) {
    if (quantity <= 0) {
      removeAt(index);
      return;
    }
    _items[index].quantity = quantity;
    notifyListeners();

    final serverId = index < _serverIds.length ? _serverIds[index] : null;
    if (_client.hasToken && serverId != null) {
      _client.patch('/cart/items/$serverId', body: {'quantity': quantity}).catchError((_) {});
    }
  }

  void clear() {
    _items.clear();
    _serverIds.clear();
    notifyListeners();

    if (_client.hasToken) {
      _client.delete('/cart').catchError((_) {});
    }
  }

  String _buildLocalOrderNumber() {
    final now = DateTime.now();
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    final hh = now.hour.toString().padLeft(2, '0');
    final mm = now.minute.toString().padLeft(2, '0');
    return 'MCM$y$m$d-$hh$mm';
  }

  /// 주문을 생성한다.
  ///
  /// [product]를 넘기면 장바구니와 무관하게 그 상품 하나만 바로 주문한다 ("바로구매").
  /// [product]를 안 넘기면 지금 장바구니에 담긴 것을 전부 주문하고 장바구니를 비운다.
  ///
  /// 로그인 상태라면 서버에 실제 주문을 생성하고, 비회원이면 기존처럼
  /// 이 세션에서만 유효한 주문 번호를 즉석에서 만들어서 반환한다.
  /// 반환값은 항상 `{orderNumber, productSummary, totalPrice}` 형태다.
  Future<Map<String, dynamic>> checkout({
    Product? product,
    String? color,
    int quantity = 1,
  }) async {
    if (_client.hasToken) {
      final body = product != null
          ? {
              'productId': product.id,
              if (color != null) 'color': color,
              'quantity': quantity,
            }
          : null;
      final order = await _client.post('/orders', body: body) as Map<String, dynamic>;
      if (product == null) {
        _items.clear();
        _serverIds.clear();
        notifyListeners();
      }
      return order;
    }

    // 비회원: 서버 없이 로컬에서만 처리 (기존 Mock 동작과 동일)
    final orderNumber = _buildLocalOrderNumber();

    if (product != null) {
      final summary =
          '${product.name}${color != null ? ' ($color)' : ''}${quantity > 1 ? ' 외 ${quantity - 1}개' : ''}';
      return {
        'orderNumber': orderNumber,
        'productSummary': summary,
        'totalPrice': product.price * quantity,
      };
    }

    final first = _items.isNotEmpty ? _items.first : null;
    final total = totalPrice;
    final summary = first == null
        ? ''
        : (_items.length == 1
            ? '${first.product.name}${first.selectedColor != null ? ' (${first.selectedColor})' : ''}'
            : '${first.product.name}${first.selectedColor != null ? ' (${first.selectedColor})' : ''} 외 ${_items.length - 1}건');
    clear();

    return {
      'orderNumber': orderNumber,
      'productSummary': summary,
      'totalPrice': total,
    };
  }
}
