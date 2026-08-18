import 'package:flutter/foundation.dart';

/// 로그인 여부만 흉내내는 Mock Auth Provider.
/// 실제 인증(Firebase Auth 등)은 이후 단계에서 이 클래스 내부만 교체하면 된다.
class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String userName = '지민';

  bool get isLoggedIn => _isLoggedIn;

  void login({String name = '지민'}) {
    _isLoggedIn = true;
    userName = name;
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    notifyListeners();
  }
}
