import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// 백엔드 서버와 통신하는 공통 도구.
///
/// Api*Service들은 전부 이 클래스를 통해 요청을 보낸다.
/// 로그인 토큰은 SharedPreferences에 저장해서, 앱을 껐다 켜도
/// (웹이면 새로고침해도) 로그인 상태를 이어서 쓸 수 있게 한다.
class ApiClient {
  ApiClient._internal();
  static final ApiClient instance = ApiClient._internal();

  /// 로컬에서 `npm run dev`로 실행 중인 백엔드 서버 주소.
  /// 서버를 다른 곳(클라우드 등)에 배포하면 이 값만 바꾸면 된다.
  static const String baseUrl = 'http://localhost:4000/api/v1';

  static const _tokenKey = 'auth_token';

  String? _token;

  bool get hasToken => _token != null;

  /// 앱 시작 시 한 번 호출해서, 저장돼 있던 로그인 토큰을 불러온다.
  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
  }

  Future<void> setToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  Uri _uri(String path, [Map<String, String>? query]) {
    return Uri.parse('$baseUrl$path').replace(queryParameters: query);
  }

  Future<dynamic> get(String path, {Map<String, String>? query}) async {
    final response = await http.get(_uri(path, query), headers: _headers);
    return _handle(response);
  }

  Future<dynamic> post(String path, {Object? body}) async {
    final response = await http.post(
      _uri(path),
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return _handle(response);
  }

  Future<dynamic> patch(String path, {Object? body}) async {
    final response = await http.patch(
      _uri(path),
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return _handle(response);
  }

  Future<dynamic> delete(String path) async {
    final response = await http.delete(_uri(path), headers: _headers);
    return _handle(response);
  }

  dynamic _handle(http.Response response) {
    final isEmpty = response.bodyBytes.isEmpty;

    if (response.statusCode >= 400) {
      String message = '서버 오류가 발생했습니다 (${response.statusCode}).';
      if (!isEmpty) {
        try {
          final decoded = jsonDecode(utf8.decode(response.bodyBytes));
          if (decoded is Map && decoded['error'] != null) {
            message = decoded['error'].toString();
          }
        } catch (_) {
          // 응답이 JSON이 아니면 기본 메시지를 그대로 사용
        }
      }
      throw ApiException(message);
    }

    if (isEmpty) return null;
    return jsonDecode(utf8.decode(response.bodyBytes));
  }
}

/// 백엔드가 4xx/5xx로 응답했을 때 던지는 예외.
/// [message]는 화면에 그대로 보여줘도 되는 한국어 문구다.
class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}
