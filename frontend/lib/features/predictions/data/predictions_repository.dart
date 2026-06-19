import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../domain/prediction_model.dart';

class PredictionsRepository {
  PredictionsRepository(this._client);

  final ApiClient _client;

  Future<List<PredictionModel>> findMine() async {
    try {
      final response = await _client.dio.get<List<dynamic>>('/predictions');
      return (response.data ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(PredictionModel.fromJson)
          .toList();
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<PredictionModel> save({
    required String matchId,
    required int homeGoals,
    required int awayGoals,
  }) async {
    try {
      final response = await _client.dio.post<Map<String, dynamic>>(
        '/predictions',
        data: {
          'matchId': matchId,
          'homeGoals': homeGoals,
          'awayGoals': awayGoals,
        },
      );
      return PredictionModel.fromJson(response.data!);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }
}
