import 'package:flutter/foundation.dart';

import '../models/cart_item.dart';
import '../models/product.dart';

/// 앱 전역 장바구니 상태.
/// Provider 등록 없이 싱글턴으로 어디서든 CartStore.instance 로 접근한다.
class CartStore extends ChangeNotifier {
  CartStore._internal();
  static final CartStore instance = CartStore._internal();

  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get totalCount =>
      _items.fold(0, (sum, item) => sum + item.quantity);

  int get totalPrice =>
      _items.fold(0, (sum, item) => sum + item.subtotal);

  bool get isEmpty => _items.isEmpty;

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
    }

    notifyListeners();
  }

  void removeAt(int index) {
    _items.removeAt(index);
    notifyListeners();
  }

  void updateQuantity(int index, int quantity) {
    if (quantity <= 0) {
      removeAt(index);
      return;
    }
    _items[index].quantity = quantity;
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
