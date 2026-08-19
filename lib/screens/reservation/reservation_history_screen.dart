import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import 'package:qr_flutter/qr_flutter.dart';

import '../../services/api_client.dart';

import '../../utils/route_names.dart';

class ReservationHistoryScreen extends StatefulWidget {
  const ReservationHistoryScreen({super.key});

  @override
  State<ReservationHistoryScreen> createState() =>
      _ReservationHistoryScreenState();
}

class _ReservationHistoryScreenState extends State<ReservationHistoryScreen> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = _fetchReservations();
  }

  /// 백엔드(/api/v1/reservations)에서 실제 예약 목록을 가져온다.
  /// (비회원이거나 서버 오류면 빈 목록을 보여준다.)
  Future<List<Map<String, dynamic>>> _fetchReservations() async {
    try {
      final data = await ApiClient.instance.get('/reservations') as List;
      return data.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  Future<void> _refresh() async {
    final future = _fetchReservations();
    setState(() {
      _future = future;
    });
    await future;
  }

  Future<void> _cancel(String id) async {
    try {
      await ApiClient.instance.post('/reservations/$id/cancel');
    } catch (_) {
      // 실패해도 조용히 무시 (목록은 새로고침해서 실제 상태를 다시 보여준다)
    }
    if (!mounted) return;
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF9F6),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          '예약',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final reservations = snapshot.data ?? [];
          final upcoming =
              reservations.where((r) => r['status'] == 'upcoming').toList();
          final past =
              reservations.where((r) => r['status'] != 'upcoming').toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
            children: [
              // 새 예약 만들기 진입점
              GestureDetector(
                onTap: () async {
                  await context.push(RouteNames.reservation);
                  if (!mounted) return;
                  _refresh();
                },
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.add_circle_outline,
                        color: Colors.white,
                        size: 22,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '새 피팅 예약하기',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '매장에서 원하는 상품을 미리 피팅해보세요',
                              style: TextStyle(
                                color: Color(0xFFCFCFCF),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                '예정된 예약',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              if (upcoming.isEmpty)
                const _EmptyReservationState(text: '예정된 예약이 없어요.')
              else
                for (final reservation in upcoming) ...[
                  _ReservationCard(
                    status: '예약 확정',
                    date: reservation['date'] as String,
                    time: reservation['time'] as String,
                    store: reservation['storeName'] as String,
                    itemCount: reservation['itemCount'] as int? ?? 0,
                    reservationCode: reservation['code'] as String,
                    onCancel: () => _cancel(reservation['id'] as String),
                  ),
                  const SizedBox(height: 14),
                ],
              const SizedBox(height: 18),
              const Text(
                '지난 예약',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              if (past.isEmpty)
                const _EmptyReservationState(text: '지난 예약이 없어요.')
              else
                for (final reservation in past) ...[
                  _ReservationCard(
                    status: reservation['status'] == 'cancelled'
                        ? '예약 취소'
                        : '이용 완료',
                    date: reservation['date'] as String,
                    time: reservation['time'] as String,
                    store: reservation['storeName'] as String,
                    itemCount: reservation['itemCount'] as int? ?? 0,
                    reservationCode: reservation['code'] as String,
                    isPast: true,
                  ),
                  const SizedBox(height: 14),
                ],
            ],
          );
        },
      ),
    );
  }
}

class _EmptyReservationState extends StatelessWidget {
  final String text;

  const _EmptyReservationState({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE7E3DC)),
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(fontSize: 13, color: Color(0xFF888888)),
        ),
      ),
    );
  }
}

class _ReservationCard extends StatelessWidget {

  final String status;

  final String date;

  final String time;

  final String store;

  final int itemCount;

  final String reservationCode;

  final bool isPast;

  final VoidCallback? onCancel;

  const _ReservationCard({

    required this.status,

    required this.date,

    required this.time,

    required this.store,

    required this.itemCount,

    required this.reservationCode,

    this.isPast = false,

    this.onCancel,

  });

  void _showQrSheet(BuildContext context) {

    showModalBottomSheet(

      context: context,

      backgroundColor: Colors.white,

      shape: const RoundedRectangleBorder(

        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),

      ),

      builder: (context) {

        return SafeArea(

          child: Padding(

            padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),

            child: Column(

              mainAxisSize: MainAxisSize.min,

              children: [

                const Text(

                  '예약 확인',

                  style: TextStyle(

                    fontSize: 18,

                    fontWeight: FontWeight.w700,

                  ),

                ),

                const SizedBox(height: 8),

                const Text(

                  '아래 QR 코드로 매장에서 체크인해주세요',

                  style: TextStyle(

                    fontSize: 13,

                    color: Color(0xFF777777),

                  ),

                ),

                const SizedBox(height: 24),

                Container(

                  padding: const EdgeInsets.all(20),

                  decoration: BoxDecoration(

                    color: Colors.white,

                    borderRadius: BorderRadius.circular(16),

                    border: Border.all(

                      color: const Color(0xFFE7E3DC),

                    ),

                  ),

                  child: QrImageView(

                    data: reservationCode,

                    version: QrVersions.auto,

                    size: 200,

                    backgroundColor: Colors.white,

                  ),

                ),

                const SizedBox(height: 20),

                Text(

                  '$date · $time',

                  style: const TextStyle(

                    fontSize: 15,

                    fontWeight: FontWeight.w700,

                  ),

                ),

                const SizedBox(height: 4),

                Text(

                  store,

                  style: const TextStyle(

                    fontSize: 13,

                    color: Color(0xFF777777),

                  ),

                ),

              ],

            ),

          ),

        );

      },

    );

  }

  @override

  Widget build(BuildContext context) {

    return Container(

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius: BorderRadius.circular(14),

        border: Border.all(

          color: const Color(0xFFE7E3DC),

        ),

      ),

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Row(

            children: [

              Container(

                padding: const EdgeInsets.symmetric(

                  horizontal: 10,

                  vertical: 6,

                ),

                decoration: BoxDecoration(

                  color: isPast

                      ? const Color(0xFFF0EEE9)

                      : Colors.black,

                  borderRadius: BorderRadius.circular(20),

                ),

                child: Text(

                  status,

                  style: TextStyle(

                    fontSize: 11,

                    fontWeight: FontWeight.w700,

                    color: isPast

                        ? const Color(0xFF777777)

                        : Colors.white,

                  ),

                ),

              ),

            ],

          ),

          const SizedBox(height: 16),

          Text(

            '$date · $time',

            style: const TextStyle(

              fontSize: 16,

              fontWeight: FontWeight.w700,

            ),

          ),

          const SizedBox(height: 6),

          Text(

            store,

            style: const TextStyle(

              fontSize: 13,

              color: Color(0xFF777777),

            ),

          ),

          const SizedBox(height: 4),

          Text(

            '피팅 상품 $itemCount개',

            style: const TextStyle(

              fontSize: 13,

              color: Color(0xFF777777),

            ),

          ),

          if (!isPast) ...[

            const SizedBox(height: 16),

            Row(

              children: [

                Expanded(

                  child: SizedBox(

                    height: 44,

                    child: ElevatedButton(

                      onPressed: () => _showQrSheet(context),

                      style: ElevatedButton.styleFrom(

                        backgroundColor: Colors.black,

                        foregroundColor: Colors.white,

                        elevation: 0,

                        shape: RoundedRectangleBorder(

                          borderRadius: BorderRadius.circular(8),

                        ),

                      ),

                      child: const Text(

                        '예약 확인',

                        style: TextStyle(

                          fontSize: 13,

                          fontWeight: FontWeight.w600,

                        ),

                      ),

                    ),

                  ),

                ),

                if (onCancel != null) ...[

                  const SizedBox(width: 10),

                  Expanded(

                    child: SizedBox(

                      height: 44,

                      child: OutlinedButton(

                        onPressed: onCancel,

                        style: OutlinedButton.styleFrom(

                          foregroundColor: Colors.black,

                          side: const BorderSide(

                            color: Color(0xFFD8D4CD),

                          ),

                          shape: RoundedRectangleBorder(

                            borderRadius: BorderRadius.circular(8),

                          ),

                        ),

                        child: const Text(

                          '예약 취소',

                          style: TextStyle(

                            fontSize: 13,

                            fontWeight: FontWeight.w600,

                          ),

                        ),

                      ),

                    ),

                  ),

                ],

              ],

            ),

          ],

        ],

      ),

    );

  }

}
