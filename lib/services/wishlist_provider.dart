import 'package:flutter/foundation.dart';

/// 찜한 상품 id 목록을 전역으로 관리한다.
/// 로그인 여부와 무관하게 앱 실행 중에는 동작하며(비로그인 사용자도 찜 가능),
/// 추후 로그인 연동 시 서버 동기화 로직만 이 클래스 내부에 추가하면 된다.
class WishlistProvider extends ChangeNotifier {
  final Set<String> _favoriteIds = {};

  Set<String> get favoriteIds => Set.unmodifiable(_favoriteIds);

  bool isFavorite(String productId) => _favoriteIds.contains(productId);

  void toggle(String productId) {
    if (_favoriteIds.contains(productId)) {
      _favoriteIds.remove(productId);
    } else {
      _favoriteIds.add(productId);
    }
    notifyListeners();
  }

  int get count => _favoriteIds.length;
}
