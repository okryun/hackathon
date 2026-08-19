import 'package:flutter/foundation.dart';

import 'api_client.dart';

/// 앱 전역 "현재 체크인한 매장" 상태.
///
/// 화면은 즉시 업데이트되고(낙관적 업데이트), 로그인 상태라면
/// 서버(/api/v1/store)에도 조용히 기록을 남긴다. 비회원은 이 세션
/// 동안만 메모리에 저장되는 기존 Mock 동작 그대로 유지된다.
class CurrentStoreStore extends ChangeNotifier {
  CurrentStoreStore._internal();
  static final CurrentStoreStore instance = CurrentStoreStore._internal();

  final ApiClient _client = ApiClient.instance;

  String? _storeId;
  String? _storeName;
  DateTime? _checkedInAt;

  String? get storeId => _storeId;
  String? get storeName => _storeName;
  DateTime? get checkedInAt => _checkedInAt;

  bool get hasActiveCheckin => _storeId != null;

  void checkIn({required String storeId, required String storeName}) {
    _storeId = storeId;
    _storeName = storeName;
    _checkedInAt = DateTime.now();
    notifyListeners();

    if (!_client.hasToken) return;
    _client.post('/store/checkin', body: {
      'storeId': storeId,
      'storeName': storeName,
    }).catchError((_) {});
  }

  void checkOut() {
    _storeId = null;
    _storeName = null;
    _checkedInAt = null;
    notifyListeners();

    if (!_client.hasToken) return;
    _client.post('/store/checkout').catchError((_) {});
  }
}
