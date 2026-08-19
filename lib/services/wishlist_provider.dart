import 'package:flutter/foundation.dart';

import 'api_client.dart';

/// 찜한 상품 id 목록을 전역으로 관리한다.
///
/// 화면에서 찜 버튼을 누르면 화면은 즉시 바뀐다(낙관적 업데이트).
/// 로그인 상태라면 그 뒤에 서버(/api/v1/wishlist)에도 조용히 저장한다.
/// 비로그인(비회원) 상태에서는 예전처럼 이 세션 동안만 메모리에 저장된다.
class WishlistProvider extends ChangeNotifier {
  final ApiClient _client = ApiClient.instance;

  final Set<String> _favoriteIds = {};

  Set<String> get favoriteIds => Set.unmodifiable(_favoriteIds);

  bool isFavorite(String productId) => _favoriteIds.contains(productId);

  int get count => _favoriteIds.length;

  /// 로그인 직후 호출해서, 서버에 저장된 찜 목록을 불러와 동기화한다.
  Future<void> loadFromServer() async {
    if (!_client.hasToken) return;
    try {
      final data = await _client.get('/wishlist') as List;
      _favoriteIds
        ..clear()
        ..addAll(data.map((e) => (e as Map<String, dynamic>)['id'] as String));
      notifyListeners();
    } catch (_) {
      // 목록을 못 불러와도 앱은 계속 쓸 수 있게 조용히 무시한다.
    }
  }

  void toggle(String productId) {
    final willBeFavorite = !_favoriteIds.contains(productId);

    if (willBeFavorite) {
      _favoriteIds.add(productId);
    } else {
      _favoriteIds.remove(productId);
    }
    notifyListeners();

    if (!_client.hasToken) return; // 비회원은 서버 저장 없이 메모리만 사용

    final future = willBeFavorite
        ? _client.post('/wishlist/$productId')
        : _client.delete('/wishlist/$productId');
    future.catchError((_) {
      // 서버 저장이 실패해도 화면은 이미 업데이트된 상태로 둔다 (하켓톤 단계라 재시도는 생략).
    });
  }
}
