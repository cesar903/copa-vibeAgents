import 'package:dio/dio.dart';

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  factory ApiException.fromDio(DioException error) {
    final data = error.response?.data;
    String? message;

    if (data is Map<String, dynamic>) {
      final rawMessage = data['message'];
      if (rawMessage is String) {
        message = rawMessage;
      } else if (rawMessage is List) {
        message = rawMessage.whereType<String>().join('\n');
      }
    }

    return ApiException(
      message ?? _fallback(error.type),
      statusCode: error.response?.statusCode,
    );
  }

  static String _fallback(DioExceptionType type) {
    return switch (type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        'A conexão demorou demais. Tente novamente.',
      DioExceptionType.connectionError =>
        'Não foi possível conectar à API. Verifique se o backend está ativo.',
      _ => 'Não foi possível concluir a operação.',
    };
  }

  @override
  String toString() => message;
}
