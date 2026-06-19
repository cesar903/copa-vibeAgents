import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../domain/ranking_entry.dart';

class RankingRepository {
  RankingRepository(this._client);

  final ApiClient _client;

  Future<List<RankingEntry>> findAll() async {
    try {
      final response = await _client.dio.get<Map<String, dynamic>>(
        '/ranking',
        queryParameters: const {'page': 1, 'limit': 100},
      );
      final data = response.data?['data'];
      if (data is! List) return const [];
      return data
          .whereType<Map<String, dynamic>>()
          .map(RankingEntry.fromJson)
          .toList();
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }
}
