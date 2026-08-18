/// 예약 확정 건의 목업 데이터.
/// 예약 내역 화면(QR 확인)과 매장 체크인 화면(QR코드로 체크인)이
/// 동일한 예약 정보를 공유해서 보여줄 때 사용한다.
class MockReservation {
  final String code;
  final String date;
  final String time;
  final String store;

  const MockReservation({
    required this.code,
    required this.date,
    required this.time,
    required this.store,
  });
}

const upcomingReservation = MockReservation(
  code: 'MIRA-20260824-1500-001',
  date: '2026년 8월 24일',
  time: '오후 3:00',
  store: 'MIRA 컨셉스토어',
);
