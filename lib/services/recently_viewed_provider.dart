import 'package:flutter/foundation.dart';

/// 최근 조회한 상품 id를 최신순으로 관리한다 (My Page에서 사용).
class RecentlyViewedProvider extends ChangeNotifier {
  static const int _maxItems = 20;
  final List<String> _ids = [];

  /// 최신순 (가장 최근에 본 상품이 0번 인덱스)
  List<String> get ids => List.unmodifiable(_ids);

  void addView(String productId) {
    _ids.remove(productId);
    _ids.insert(0, productId);
    if (_ids.length > _maxItems) {
      _ids.removeRange(_maxItems, _ids.length);
    }
    notifyListeners();
  }
}
