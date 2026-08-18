import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import 'package:qr_flutter/qr_flutter.dart';

import '../../data/mock_reservation.dart';

import '../../utils/route_names.dart';

class ReservationHistoryScreen extends StatelessWidget {

  const ReservationHistoryScreen({super.key});

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

      body: ListView(

        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),

        children: [

          // 새 예약 만들기 진입점

          GestureDetector(

            onTap: () => context.push(RouteNames.reservation),

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

          _ReservationCard(

            status: '예약 확정',

            date: upcomingReservation.date,

            time: upcomingReservation.time,

            store: upcomingReservation.store,

            itemCount: 2,

            reservationCode: upcomingReservation.code,

            onCancel: () {

              ScaffoldMessenger.of(context).showSnackBar(

                const SnackBar(

                  content: Text(

                    '예약 취소 기능은 추후 연결 예정입니다.',

                  ),

                ),

              );

            },

          ),

          const SizedBox(height: 32),

          const Text(

            '지난 예약',

            style: TextStyle(

              fontSize: 17,

              fontWeight: FontWeight.w700,

            ),

          ),

          const SizedBox(height: 14),

          const _ReservationCard(

            status: '이용 완료',

            date: '2026년 7월 18일',

            time: '오후 1:30',

            store: 'MIRA 컨셉스토어',

            itemCount: 3,

            reservationCode: 'MIRA-20260718-1330-002',

            isPast: true,

          ),

        ],

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
