import 'package:go_router/go_router.dart';

import '../screens/splash/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/personal_profile/personal_profile_screen.dart';
import '../screens/home/home_shell.dart';
import '../screens/product_detail/product_detail_screen.dart';
import '../screens/reservation/fitting_reservation_screen.dart';
import '../screens/reservation/reservation_history_screen.dart';
import '../screens/ar/ar_try_on_screen.dart';
import 'route_names.dart';

/// 앱 전역 라우터.
final GoRouter appRouter = GoRouter(
  initialLocation: RouteNames.splash,
  routes: [
    GoRoute(
      path: RouteNames.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: RouteNames.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: RouteNames.personalProfile,
      builder: (context, state) => PersonalProfileScreen(
        onComplete: () => context.go(RouteNames.home),
      ),
    ),
    GoRoute(
      path: RouteNames.home,
      builder: (context, state) => const HomeShell(),
    ),
    GoRoute(
      path: RouteNames.productDetail,
      builder: (context, state) => ProductDetailScreen(
        productId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: RouteNames.arTryOn,
      builder: (context, state) => ArTryOnScreen(
        productId: state.pathParameters['id']!,
        initialColor: state.uri.queryParameters['color'],
      ),
    ),
    GoRoute(
      path: RouteNames.reservation,
      builder: (context, state) => const FittingReservationScreen(),
    ),


    GoRoute(

      path: RouteNames.reservationHistory,

      builder: (context, state) =>

          const ReservationHistoryScreen(),

    ),

  ],
);
