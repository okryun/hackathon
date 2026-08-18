/// 앱 전역에서 사용하는 라우트 경로 상수.
/// 화면이 추가될 때마다 이 파일에만 경로를 추가하면 된다.
class RouteNames {
  RouteNames._();

  static const String splash = '/';
  static const String login = '/login';
  static const String personalProfile = '/personal-profile';
  static const String home = '/home';
  static const String explore = '/explore';
  static const String productDetail = '/product/:id';

  static const String arTryOn = '/ar/try-on/:id';
  static const String saved = '/saved';
  static const String myPage = '/my';
  static const String reservation = '/reservation';
  static const String reservationHistory = '/reservation-history';

  static String productDetailPath(String id) => '/product/$id';

  static String arTryOnPath(String id) => '/ar/try-on/$id';
}
