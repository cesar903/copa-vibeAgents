import '../../matches/domain/match_model.dart';

class PredictionUser {
  const PredictionUser({required this.id, required this.name, this.avatar});

  final String id;
  final String name;
  final String? avatar;

  factory PredictionUser.fromJson(Map<String, dynamic> json) {
    return PredictionUser(
      id: json['id'] as String,
      name: json['name'] as String,
      avatar: json['avatar'] as String?,
    );
  }
}

class PredictionModel {
  const PredictionModel({
    required this.id,
    required this.matchId,
    required this.homeGoals,
    required this.awayGoals,
    required this.locked,
    this.match,
    this.user,
  });

  final String id;
  final String matchId;
  final int homeGoals;
  final int awayGoals;
  final bool locked;
  final MatchModel? match;
  final PredictionUser? user;

  factory PredictionModel.fromJson(Map<String, dynamic> json) {
    final matchJson = json['match'];
    final userJson = json['user'];
    return PredictionModel(
      id: json['id'] as String,
      matchId: json['matchId'] as String,
      homeGoals: json['homeGoals'] as int,
      awayGoals: json['awayGoals'] as int,
      locked: json['locked'] as bool? ?? false,
      match: matchJson is Map<String, dynamic>
          ? MatchModel.fromJson(matchJson)
          : null,
      user: userJson is Map<String, dynamic>
          ? PredictionUser.fromJson(userJson)
          : null,
    );
  }
}
