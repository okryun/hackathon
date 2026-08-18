import 'package:flutter/material.dart';

import 'package:qr_flutter/qr_flutter.dart';

import '../../data/mock_reservation.dart';

import '../../services/current_store_store.dart';

/// 08. 매장 체크인
/// 하단 네비게이션의 세 번째 탭 (기존 AR 탭 자리).
///
/// 흐름 (백엔드 없이 프론트에서만 구현):
/// NFC/QR 태그 → 매장 ID 인식(mock: storeId='hongdae') →
/// 앱에 현재 매장 저장(CurrentStoreStore) → 완료 팝업 표시
class StoreCheckinScreen extends StatefulWidget {
  final VoidCallback onExploreTap;

  const StoreCheckinScreen({super.key, required this.onExploreTap});

  @override
  State<StoreCheckinScreen> createState() => _StoreCheckinScreenState();
}

enum _CheckinState { idle, scanning }

/// 목업 매장 정보. 실제로는 NFC 태그/QR에 인코딩된 값을 파싱해서 얻는다.
const _mockStoreId = 'hongdae';
const _mockStoreName = 'A-LAND 홍대점';

class _StoreCheckinScreenState extends State<StoreCheckinScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ringController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat();

  _CheckinState _state = _CheckinState.idle;

  @override
  void dispose() {
    _ringController.dispose();
    super.dispose();
  }

  Future<void> _runCheckinSequence() async {
    if (_state != _CheckinState.idle) return;

    setState(() => _state = _CheckinState.scanning);

    // 1. NFC/QR 태그 인식 시뮬레이션
    await Future.delayed(const Duration(milliseconds: 1600));
    if (!mounted) return;

    // 2. 매장 ID 인식 (mock)
    const storeId = _mockStoreId;
    const storeName = _mockStoreName;

    // 3. 백엔드 기록은 생략 (백엔드 없음)

    // 4. 앱에 현재 매장 저장
    CurrentStoreStore.instance.checkIn(
      storeId: storeId,
      storeName: storeName,
    );

    setState(() => _state = _CheckinState.idle);

    // 5. 완료 팝업 표시
    if (!mounted) return;
    _showCheckinCompleteDialog(storeName);
  }

  void _cancel() {
    if (_state == _CheckinState.idle) return;
    setState(() => _state = _CheckinState.idle);
  }

  void _showCheckinCompleteDialog(String storeName) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  '체크인 완료',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  '$storeName에\n오신 것을 환영합니다!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '이제 매장 상품을 AR로\n체험해보세요.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF777777),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      widget.onExploreTap();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      '둘러보기',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _checkinWithQr() async {
    await showModalBottomSheet(
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
                  '예약 QR로 체크인',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '아래 QR 코드를 매장 리더기에 보여주세요',
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
                    data: upcomingReservation.code,
                    version: QrVersions.auto,
                    size: 200,
                    backgroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  '${upcomingReservation.date} · ${upcomingReservation.time}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  upcomingReservation.store,
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

    // QR을 보여준 것으로 간주하고 동일한 체크인 흐름을 진행한다.
    if (mounted) {
      _runCheckinSequence();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0E0E),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: CurrentStoreStore.instance,
          builder: (context, _) {
            final currentStore = CurrentStoreStore.instance;

            return Column(
              children: [
                const SizedBox(height: 24),
                const Text(
                  '매장 체크인',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _statusSubtitle(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFB5B5B5),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                if (currentStore.hasActiveCheckin) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1C1E),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF333333)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.storefront_outlined,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '현재 매장: ${currentStore.storeName}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const Spacer(),
                GestureDetector(
                  onTap: _runCheckinSequence,
                  child: SizedBox(
                    width: 260,
                    height: 260,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (_state == _CheckinState.scanning)
                          AnimatedBuilder(
                            animation: _ringController,
                            builder: (context, child) {
                              return CustomPaint(
                                size: const Size(260, 260),
                                painter: _ScanRingPainter(
                                  progress: _ringController.value,
                                ),
                              );
                            },
                          ),
                        Container(
                          width: 190,
                          height: 190,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                Color(0xFF262626),
                                Color(0xFF141414),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black54,
                                blurRadius: 30,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              'NFC',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: _cancel,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFF3A3A3A)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        '취소하기',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                TextButton(
                  onPressed: _checkinWithQr,
                  child: const Text(
                    'QR코드로 체크인',
                    style: TextStyle(
                      color: Color(0xFF9A9A9A),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            );
          },
        ),
      ),
    );
  }

  String _statusSubtitle() {
    switch (_state) {
      case _CheckinState.idle:
        return 'NFC 태그 또는 QR코드를\n리더기에 태그해주세요';
      case _CheckinState.scanning:
        return '체크인 중입니다...\n잠시만 기다려주세요';
    }
  }
}

/// NFC 스캔 중임을 나타내는 회전하는 원호(arc) 페인터.
class _ScanRingPainter extends CustomPainter {
  final double progress;

  _ScanRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;

    final basePaint = Paint()
      ..color = const Color(0xFF2E2E2E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.drawCircle(center, radius, basePaint);

    final arcPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final startAngle = progress * 6.28318; // 2*pi
    const sweepAngle = 1.6; // 라디안, 약 90도 조금 넘게

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScanRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
