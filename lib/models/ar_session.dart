/// AR 가상 착용 체험 1회를 기록하는 모델.
///
/// AR Try-On 화면 진입 시 [sessionStart]가 기록되고, 종료 시 [sessionEnd]와
/// [duration]이 채워진다. 이 이벤트들은 추후 백엔드로 전송되어
/// "상품별 AR 사용 횟수", "상품별 AR 체험 시간", "시간대별 관심 상품" 등
/// 매장 운영 데이터로 활용될 예정이다.
class ArSession {
  final String sessionId;
  final String productId;
  final DateTime startTime;
  DateTime? endTime;

  ArSession({
    required this.sessionId,
    required this.productId,
    required this.startTime,
    this.endTime,
  });

  /// 세션이 아직 진행 중인지 여부 (종료 시각이 기록되지 않음)
  bool get isActive => endTime == null;

  /// 체험 지속 시간. 종료되지 않았다면 현재 시각 기준으로 계산.
  Duration get duration => (endTime ?? DateTime.now()).difference(startTime);

  /// 세션 종료 처리 (endTime을 현재 시각으로 기록)
  void end() {
    endTime ??= DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'productId': productId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'durationSeconds': duration.inSeconds,
    };
  }

  factory ArSession.fromJson(Map<String, dynamic> json) {
    return ArSession(
      sessionId: json['sessionId'] as String,
      productId: json['productId'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
    );
  }
}
