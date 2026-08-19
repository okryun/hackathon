import 'package:flutter/foundation.dart';

import 'api_client.dart';

/// 최근 조회한 상품 id를 최신순으로 관리한다.
///
/// 화면은 즉시 업데이트되고(낙관적 업데이트), 로그인 상태라면
/// 서버(/api/v1/recently-viewed)에도 조용히 기록을 남긴다.
class RecentlyViewedProvider extends ChangeNotifier {
  static const int _maxItems = 20;

  final ApiClient _client = ApiClient.instance;
  final List<String> _ids = [];

  /// 최신순 (가장 최근에 본 상품이 0번 인덱스)
  List<String> get ids => List.unmodifiable(_ids);

  /// 로그인 직후 호출해서, 서버에 저장된 최근 본 상품 목록을 불러와 동기화한다.
  Future<void> loadFromServer() async {
    if (!_client.hasToken) return;
    try {
      final data = await _client.get('/recently-viewed') as List;
      _ids
        ..clear()
        ..addAll(data.map((e) => (e as Map<String, dynamic>)['id'] as String));
      notifyListeners();
    } catch (_) {
      // 못 불러와도 조용히 무시한다.
    }
  }

  void addView(String productId) {
    _ids.remove(productId);
    _ids.insert(0, productId);
    if (_ids.length > _maxItems) {
      _ids.removeRange(_maxItems, _ids.length);
    }
    notifyListeners();

    if (!_client.hasToken) return; // 비회원은 메모리에만 기록

    _client.post('/recently-viewed/$productId').catchError((_) {
      // 서버 기록이 실패해도 화면은 이미 업데이트된 상태로 둔다.
    });
  }
}
