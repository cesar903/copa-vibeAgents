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

    final statusCode = error.response?.statusCode;
    return ApiException(
      message ?? _fallback(error.type, statusCode),
      statusCode: statusCode,
    );
  }

  static String _fallback(DioExceptionType type, int? statusCode) {
    if (statusCode == 401 || statusCode == 403) {
      return 'Sua sessão não tem permissão para esta operação. Entre novamente com o administrador.';
    }
    if (statusCode == 404) {
      return 'Recurso não encontrado na API. Confirme se o backend foi atualizado no Render.';
    }
    if (statusCode != null && statusCode >= 500) {
      return 'A API encontrou um erro interno. Verifique os logs do Render.';
    }

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
