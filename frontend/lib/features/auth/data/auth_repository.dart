import 'package:dio/dio.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';
import '../domain/auth_session.dart';

class AuthRepository {
  AuthRepository(this._client, this._tokenStorage);

  final ApiClient _client;
  final TokenStorage _tokenStorage;

  Future<AuthSession?> restoreSession() async {
    final token = await _tokenStorage.read();
    if (token == null) return null;

    try {
      return AuthSession.fromToken(token);
    } on FormatException {
      await _tokenStorage.clear();
      return null;
    }
  }

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    return _authenticate('/auth/login', {'email': email, 'password': password});
  }

  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
  }) async {
    return _authenticate('/auth/register', {
      'name': name,
      'email': email,
      'password': password,
    });
  }

  Future<void> logout() => _tokenStorage.clear();

  Future<AuthSession> _authenticate(
    String path,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _client.dio.post<Map<String, dynamic>>(
        path,
        data: data,
      );
      final token = response.data?['accessToken'];
      if (token is! String) {
        throw const ApiException('A API não retornou um token válido.');
      }
      final session = AuthSession.fromToken(token);
      await _tokenStorage.write(token);
      return session;
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    } on FormatException catch (error) {
      throw ApiException(error.message);
    }
  }
}
