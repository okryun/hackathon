import 'package:flutter/foundation.dart';

/// 앱 전역 "현재 체크인한 매장" 상태.
/// 백엔드가 없는 프로토타입 단계라 로컬 메모리에만 저장한다.
/// (앱을 완전히 종료하면 초기화됨 — 실제로는 서버/로컬스토리지 연동 필요)
class CurrentStoreStore extends ChangeNotifier {
  CurrentStoreStore._internal();
  static final CurrentStoreStore instance = CurrentStoreStore._internal();

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
  }

  void checkOut() {
    _storeId = null;
    _storeName = null;
    _checkedInAt = null;
    notifyListeners();
  }
}
