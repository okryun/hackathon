import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/ar_session_provider.dart';
import 'services/auth_provider.dart';
import 'services/product_service.dart';
import 'services/recently_viewed_provider.dart';
import 'services/wishlist_provider.dart';
import 'theme/app_theme.dart';
import 'utils/app_router.dart';

void main() {
  runApp(const ArFashionApp());
}

/// 오프라인 패션 매장용 AR 쇼핑 앱 (Flutter Frontend MVP)
///
/// 현재 단계: Backend 없음 / Mock Data 사용 / Unity AR 미연동.
/// 추후 API, Unity AR 연동 시 services/ 계층만 교체하면 되도록 구조를 분리했다.
///
/// 전역 상태는 Provider로 관리한다:
/// - ProductService: 상품 데이터 접근 (지금은 MockProductService)
/// - WishlistProvider: 찜한 상품
/// - RecentlyViewedProvider: 최근 본 상품
/// - ArSessionProvider: AR 체험 세션(Mock Timer/Event)
/// - AuthProvider: 로그인 상태 (Mock)
class ArFashionApp extends StatelessWidget {
  const ArFashionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ProductService>(create: (_) => MockProductService()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
        ChangeNotifierProvider(create: (_) => RecentlyViewedProvider()),
        ChangeNotifierProvider(create: (_) => ArSessionProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp.router(
        title: 'AR Fashion',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: appRouter,
      ),
    );
  }
}
