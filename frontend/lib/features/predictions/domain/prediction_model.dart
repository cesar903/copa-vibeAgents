import '../../matches/domain/match_model.dart';

class PredictionModel {
  const PredictionModel({
    required this.id,
    required this.matchId,
    required this.homeGoals,
    required this.awayGoals,
    required this.locked,
    this.match,
  });

  final String id;
  final String matchId;
  final int homeGoals;
  final int awayGoals;
  final bool locked;
  final MatchModel? match;

  factory PredictionModel.fromJson(Map<String, dynamic> json) {
    final matchJson = json['match'];
    return PredictionModel(
      id: json['id'] as String,
      matchId: json['matchId'] as String,
      homeGoals: json['homeGoals'] as int,
      awayGoals: json['awayGoals'] as int,
      locked: json['locked'] as bool? ?? false,
      match: matchJson is Map<String, dynamic>
          ? MatchModel.fromJson(matchJson)
          : null,
    );
  }
}
