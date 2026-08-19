import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/ar_session.dart';
import 'api_client.dart';

/// AR 체험 세션의 시작/종료를 관리하고 히스토리를 기록한다.
///
/// Flow:
///   AR Session Start -> start(productId) 호출 (Timer Start)
///   User exits AR    -> end() 호출 (Timer Stop, sessionEnd/duration 기록)
///
/// 화면에 보이는 통계(사용 횟수, 체험 시간 등)는 예전처럼 앱 메모리의
/// 히스토리로 즉시 계산한다. 그와 별개로, 서버(/api/v1/ar-sessions)에도
/// 조용히 같은 기록을 남겨서 "상품별 AR 체험 대비 구매 전환" 같은
/// 매장 운영 분석에 쓸 수 있게 한다 (로그인 여부와 무관하게 기록 가능).
class ArSessionProvider extends ChangeNotifier {
  static const _uuid = Uuid();
  final ApiClient _client = ApiClient.instance;

  final List<ArSession> _history = [];
  ArSession? _active;
  String? _activeServerSessionId;

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
    _activeServerSessionId = null;
    notifyListeners();

    _client.post('/ar-sessions/start', body: {'productId': productId}).then((data) {
      if (_active?.sessionId == session.sessionId) {
        _activeServerSessionId = (data as Map<String, dynamic>)['id'] as String;
      }
    }).catchError((_) {});

    return session;
  }

  /// 현재 진행 중인 세션을 종료하고 히스토리에 기록한다.
  void end() {
    if (_active == null) return;
    _endInternal();
    notifyListeners();
  }

  void _endInternal() {
    _active!.end();
    _history.add(_active!);
    if (kDebugMode) {
      debugPrint('[AR Event] ${_active!.toJson()}');
    }

    final serverSessionId = _activeServerSessionId;
    if (serverSessionId != null) {
      _client.post('/ar-sessions/$serverSessionId/end').catchError((_) {});
    }

    _active = null;
    _activeServerSessionId = null;
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
