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
}
