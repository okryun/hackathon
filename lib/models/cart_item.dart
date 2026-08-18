import '../models/product.dart';

/// 장바구니에 담긴 한 줄 (상품 + 선택 컬러 + 수량)
class CartItem {
  final Product product;
  final String? selectedColor;
  int quantity;

  CartItem({
    required this.product,
    this.selectedColor,
    this.quantity = 1,
  });

  int get subtotal => product.price * quantity;
}
