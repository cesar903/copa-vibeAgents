import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../domain/match_model.dart';

class MatchesRepository {
  MatchesRepository(this._client);

  final ApiClient _client;

  Future<MatchModel> create({
    required String homeTeam,
    required String awayTeam,
    required String competition,
    required String stadium,
    required int round,
    required DateTime startDate,
    required MatchStatus status,
    int? homeGoals,
    int? awayGoals,
  }) async {
    try {
      final response = await _client.dio.post<Map<String, dynamic>>(
        '/matches',
        data: {
          'homeTeam': homeTeam,
          'awayTeam': awayTeam,
          'competition': competition,
          'stadium': stadium,
          'round': round,
          'startDate': startDate.toUtc().toIso8601String(),
          'status': status.apiValue,
          'homeGoals': ?homeGoals,
          'awayGoals': ?awayGoals,
        },
      );
      final data = response.data;
      if (data == null) {
        throw const ApiException('A API não retornou a partida cadastrada.');
      }
      return MatchModel.fromJson(data);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<List<MatchModel>> findAll({MatchStatus? status}) async {
    try {
      final response = await _client.dio.get<Map<String, dynamic>>(
        '/matches',
        queryParameters: {
          'page': 1,
          'limit': 100,
          if (status != null) 'status': status.apiValue,
        },
      );
      final rawData = response.data?['data'];
      if (rawData is! List) return const [];
      return rawData
          .whereType<Map<String, dynamic>>()
          .map(MatchModel.fromJson)
          .toList();
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<List<RoundPaymentModel>> findRoundPayments({required int round}) async {
    try {
      final response = await _client.dio.get<List<dynamic>>(
        '/round-payments',
        queryParameters: {'round': round},
      );
      final data = response.data;
      if (data == null) return const [];
      return data
          .whereType<Map<String, dynamic>>()
          .map(RoundPaymentModel.fromJson)
          .toList();
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<void> setRoundPayment({
    required String userId,
    required int round,
    required bool paid,
  }) async {
    try {
      await _client.dio.patch<Map<String, dynamic>>(
        '/round-payments',
        data: {'userId': userId, 'round': round, 'paid': paid},
      );
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }
}

class RoundPaymentModel {
  const RoundPaymentModel({
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.round,
    required this.paid,
  });

  final String userId;
  final String userName;
  final String userEmail;
  final int round;
  final bool paid;

  factory RoundPaymentModel.fromJson(Map<String, dynamic> json) {
    return RoundPaymentModel(
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userEmail: json['userEmail'] as String,
      round: json['round'] as int,
      paid: json['paid'] as bool,
    );
  }
}
