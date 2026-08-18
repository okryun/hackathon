import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/ar_session.dart';

/// AR 체험 세션의 시작/종료를 관리하고 히스토리를 기록한다.
///
/// Flow:
///   AR Session Start -> start(productId) 호출 (Timer Start)
///   User exits AR    -> end() 호출 (Timer Stop, sessionEnd/duration 기록)
///
/// 기록된 히스토리는 추후 백엔드로 전송되어
/// "상품별 AR 사용 횟수", "상품별 AR 체험 시간", "AR 체험 대비 구매 전환" 등
/// 분석 데이터로 활용될 예정이다. 지금은 앱 메모리에만 저장되는 Mock 구조이다.
class ArSessionProvider extends ChangeNotifier {
  static const _uuid = Uuid();

  final List<ArSession> _history = [];
  ArSession? _active;

  ArSession? get active => _active;
  bool get hasActiveSession => _active != null;

  /// 최신순 히스토리
  List<ArSession> get history => List.unmodifiable(_history.reversed);

  /// 새 AR 세션을 시작한다. 이미 진행 중인 세션이 있다면 먼저 종료 처리한다.
  ArSession start(String productId) {
    if (_active != null) {
      _endInternal();
    }
    final session = ArSession(
      sessionId: _uuid.v4(),
      productId: productId,
      startTime: DateTime.now(),
    );
    _active = session;
    notifyListeners();
    return session;
  }

  /// 현재 진행 중인 세션을 종료하고 히스토리에 Mock Event로 기록한다.
  void end() {
    if (_active == null) return;
    _endInternal();
    notifyListeners();
  }

  void _endInternal() {
    _active!.end();
    _history.add(_active!);
    if (kDebugMode) {
      debugPrint('[Mock AR Event] ${_active!.toJson()}');
    }
    _active = null;
  }

  /// 최근 AR 체험한 상품 id 목록 (중복 제거, 최신순) - Home/My Page/AR 탭에서 사용
  List<String> get recentTriedProductIds {
    final seen = <String>{};
    final result = <String>[];
    for (final session in history) {
      if (seen.add(session.productId)) {
        result.add(session.productId);
      }
    }
    return result;
  }

  /// 상품별 AR 사용 횟수 (Mock 분석 데이터 예시)
  int usageCount(String productId) =>
      _history.where((s) => s.productId == productId).length;

  /// 상품별 누적 AR 체험 시간 (Mock 분석 데이터 예시)
  Duration totalDuration(String productId) {
    return _history
        .where((s) => s.productId == productId)
        .fold(Duration.zero, (sum, s) => sum + s.duration);
  }
}
