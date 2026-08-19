import 'package:flutter/foundation.dart';

import 'api_client.dart';

/// 로그인 상태를 관리하는 Auth Provider.
///
/// 백엔드의 /api/v1/auth 엔드포인트를 실제로 호출한다.
/// (이전에는 Mock으로 항상 로그인 성공 처리만 했었다.)
class AuthProvider extends ChangeNotifier {
  final ApiClient _client = ApiClient.instance;

  bool _isLoggedIn = false;
  String userName = '';
  String? errorMessage;
  bool isLoading = false;

  bool get isLoggedIn => _isLoggedIn;

  /// 앱 시작 시 한 번 호출한다. 저장된 로그인 토큰이 있으면
  /// 서버에 확인해서 로그인 상태를 복원한다.
  Future<void> restoreSession() async {
    await _client.loadToken();
    if (!_client.hasToken) return;

    try {
      final data = await _client.get('/auth/me') as Map<String, dynamic>;
      userName = data['name'] as String;
      _isLoggedIn = true;
      notifyListeners();
    } catch (_) {
      // 토큰이 만료됐거나 유효하지 않으면 로그아웃 상태로 둔다.
      await _client.clearToken();
    }
  }

  /// 이메일/비밀번호로 로그인을 시도한다.
  /// 성공하면 true, 실패하면 false를 반환하고 [errorMessage]에 사유가 담긴다.
  Future<bool> login({required String email, required String password}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final data = await _client.post('/auth/login', body: {
        'email': email,
        'password': password,
      }) as Map<String, dynamic>;

      await _client.setToken(data['token'] as String);
      final user = data['user'] as Map<String, dynamic>;
      userName = user['name'] as String;
      _isLoggedIn = true;
      return true;
    } on ApiException catch (e) {
      errorMessage = e.message;
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// 이름/이메일/비밀번호로 회원가입 후 바로 로그인 상태로 전환한다.
  Future<bool> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final data = await _client.post('/auth/signup', body: {
        'name': name,
        'email': email,
        'password': password,
      }) as Map<String, dynamic>;

      await _client.setToken(data['token'] as String);
      final user = data['user'] as Map<String, dynamic>;
      userName = user['name'] as String;
      _isLoggedIn = true;
      return true;
    } on ApiException catch (e) {
      errorMessage = e.message;
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _client.clearToken();
    _isLoggedIn = false;
    userName = '';
    notifyListeners();
  }
}
