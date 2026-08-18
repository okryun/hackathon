import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import 'package:provider/provider.dart';

import '../../data/mock_products.dart';

import '../../models/product.dart';

import '../../services/ar_session_provider.dart';

import '../../utils/formatters.dart';

import '../../utils/route_names.dart';

import '../order/order_history_screen.dart';

class MyPageScreen extends StatelessWidget {
  final VoidCallback? onSavedTap;

  const MyPageScreen({
    super.key,
    this.onSavedTap,
  });

  void _showLogoutConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            '로그아웃',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          content: const Text('정말 로그아웃 하시겠어요?'),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(
                '취소',
                style: TextStyle(color: Color(0xFF777777)),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.go(RouteNames.login);
              },
              child: const Text(
                '로그아웃',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final recentProducts = mockProducts.take(3).toList();

    final reportProduct = mockProducts.isNotEmpty ? mockProducts.first : null;

    // AR로 착용해본 상품 (최근 순, 최대 6개)
    final arSession = context.watch<ArSessionProvider>();
    final arTriedProducts = arSession.recentTriedProductIds
        .take(6)
        .map((id) => findMockProductById(id))
        .whereType<Product>()
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            20,
            28,
            20,
            40,
          ),
          children: [
            const Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Color(0xFFE2DDD4),
                  child: Icon(
                    Icons.person,
                    size: 34,
                    color: Color(0xFF888888),
                  ),
                ),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '지민님',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Welcome to MIRA',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF777777),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // 주문 내역 (기존 "피팅 예약" 자리를 대체)

                _MyMenuItem(
                  icon: Icons.receipt_long_outlined,
                  label: '주문 내역',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const OrderHistoryScreen(),
                      ),
                    );
                  },
                ),

                // 예약: 예정된 예약 / 지난 예약 / 새 예약하기가

                // 모두 ReservationHistoryScreen 하나로 통합됨

                _MyMenuItem(
                  icon: Icons.calendar_month_outlined,
                  label: '예약',
                  onTap: () {
                    context.push(
                      RouteNames.reservationHistory,
                    );
                  },
                ),

                // Saved는 HomeShell 내부 탭이므로

                // /saved 라우트로 직접 이동하지 않고

                // onSavedTap 콜백으로 탭 인덱스를 전환한다.

                _MyMenuItem(
                  icon: Icons.favorite_border,
                  label: '관심 상품',
                  onTap: () {
                    if (onSavedTap != null) {
                      onSavedTap!();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            '관심 상품은 하단 Saved 탭에서 확인해주세요.',
                          ),
                        ),
                      );
                    }
                  },
                ),

                // AI 퍼스널 프로필

                _MyMenuItem(
                  icon: Icons.auto_awesome_outlined,
                  label: 'AI 스타일',
                  onTap: () {
                    context.push(
                      RouteNames.personalProfile,
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF3EFE7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'AI 스타일 리포트',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: () {},
                          child: const Text(
                            '상세 보기',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF555555),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          '당신의 스타일 컬러 리포트가\n업데이트 되었어요.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF777777),
                            height: 1.55,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  if (reportProduct != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        reportProduct.image,
                        width: 92,
                        height: 108,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) {
                          return Container(
                            width: 92,
                            height: 108,
                            color: const Color(0xFFE4DED3),
                            child: const Icon(
                              Icons.shopping_bag_outlined,
                              size: 40,
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
            if (arTriedProducts.isNotEmpty) ...[
              const SizedBox(height: 30),
              const Text(
                'AR로 체험해본 상품',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 168,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: arTriedProducts.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final product = arTriedProducts[index];
                    return GestureDetector(
                      onTap: () {
                        context.push(
                          RouteNames.productDetailPath(product.id),
                        );
                      },
                      child: SizedBox(
                        width: 118,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                AspectRatio(
                                  aspectRatio: 1,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                      color: const Color(0xFFF1EEE8),
                                      child: Image.network(
                                        product.image,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) {
                                          return const Center(
                                            child: Icon(
                                              Icons.shopping_bag_outlined,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 6,
                                  bottom: 6,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 7,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.85),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.view_in_ar,
                                          size: 10,
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: 3),
                                        Text(
                                          'AR',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              product.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              Formatters.price(product.price),
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF777777),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 30),
            const Text(
              '최근 본 제품',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                for (int i = 0; i < recentProducts.length; i++) ...[
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        context.push(
                          RouteNames.productDetailPath(
                            recentProducts[i].id,
                          ),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AspectRatio(
                            aspectRatio: 1,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                color: const Color(0xFFF1EEE8),
                                child: Image.network(
                                  recentProducts[i].image,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) {
                                    return const Center(
                                      child: Icon(
                                        Icons.shopping_bag_outlined,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            recentProducts[i].name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            Formatters.price(
                              recentProducts[i].price,
                            ),
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF777777),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (i != recentProducts.length - 1) const SizedBox(width: 10),
                ],
              ],
            ),
            const SizedBox(height: 36),
            const Text(
              '계정',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            _AccountMenuList(
              items: [
                _AccountMenuData(
                  icon: Icons.person_outline,
                  label: '프로필 수정',
                ),
                _AccountMenuData(
                  icon: Icons.location_on_outlined,
                  label: '배송지 관리',
                ),
                _AccountMenuData(
                  icon: Icons.notifications_none,
                  label: '알림 설정',
                ),
                _AccountMenuData(
                  icon: Icons.headset_mic_outlined,
                  label: '고객센터',
                ),
                _AccountMenuData(
                  icon: Icons.description_outlined,
                  label: '이용약관 및 개인정보처리방침',
                ),
              ],
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () => _showLogoutConfirm(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF999999),
                  side: const BorderSide(color: Color(0xFFE0DCD3)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  '로그아웃',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountMenuData {
  final IconData icon;
  final String label;

  const _AccountMenuData({required this.icon, required this.label});
}

class _AccountMenuList extends StatelessWidget {
  final List<_AccountMenuData> items;

  const _AccountMenuList({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE7E3DC)),
      ),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            _AccountMenuRow(data: items[i]),
            if (i != items.length - 1)
              const Divider(height: 1, color: Color(0xFFF0EEE9)),
          ],
        ],
      ),
    );
  }
}

class _AccountMenuRow extends StatelessWidget {
  final _AccountMenuData data;

  const _AccountMenuRow({required this.data});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${data.label} 기능은 준비 중입니다 (Mock)'),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(data.icon, size: 20, color: const Color(0xFF555555)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                data.label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 18,
              color: Color(0xFFBBBBBB),
            ),
          ],
        ),
      ),
    );
  }
}

class _MyMenuItem extends StatelessWidget {
  final IconData icon;

  final String label;

  final VoidCallback onTap;

  const _MyMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: const BoxDecoration(
              color: Color(0xFFF3F0EA),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 23,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
