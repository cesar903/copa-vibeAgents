class RankingUser {
  const RankingUser({required this.id, required this.name, this.avatar});

  final String id;
  final String name;
  final String? avatar;

  factory RankingUser.fromJson(Map<String, dynamic> json) {
    return RankingUser(
      id: json['id'] as String,
      name: json['name'] as String,
      avatar: json['avatar'] as String?,
    );
  }
}

class RankingEntry {
  const RankingEntry({
    required this.id,
    required this.userId,
    required this.points,
    required this.position,
    required this.exactScores,
    required this.correctWinners,
    required this.user,
  });

  final String id;
  final String userId;
  final int points;
  final int position;
  final int exactScores;
  final int correctWinners;
  final RankingUser user;

  factory RankingEntry.fromJson(Map<String, dynamic> json) {
    return RankingEntry(
      id: json['id'] as String,
      userId: json['userId'] as String,
      points: json['points'] as int,
      position: json['position'] as int,
      exactScores: json['exactScores'] as int,
      correctWinners: json['correctWinners'] as int,
      user: RankingUser.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}
