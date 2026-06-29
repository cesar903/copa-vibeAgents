enum MatchStatus {
  scheduled,
  live,
  finished;

  factory MatchStatus.fromJson(String value) => switch (value) {
    'LIVE' => MatchStatus.live,
    'FINISHED' => MatchStatus.finished,
    _ => MatchStatus.scheduled,
  };

  String get apiValue => name.toUpperCase();

  String get label => switch (this) {
    MatchStatus.scheduled => 'Agendada',
    MatchStatus.live => 'Ao vivo',
    MatchStatus.finished => 'Finalizada',
  };
}

class MatchModel {
  const MatchModel({
    required this.id,
    required this.homeTeam,
    required this.awayTeam,
    required this.competition,
    required this.stadium,
    required this.round,
    required this.isMoneyPool,
    required this.startDate,
    required this.status,
    this.homeGoals,
    this.awayGoals,
  });

  final String id;
  final String homeTeam;
  final String awayTeam;
  final String competition;
  final String stadium;
  final int round;
  final bool isMoneyPool;
  final DateTime startDate;
  final MatchStatus status;
  final int? homeGoals;
  final int? awayGoals;

  bool get acceptsPrediction =>
      status == MatchStatus.scheduled &&
      DateTime.now().isBefore(startDate.subtract(const Duration(minutes: 15)));

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    return MatchModel(
      id: json['id'] as String,
      homeTeam: json['homeTeam'] as String,
      awayTeam: json['awayTeam'] as String,
      competition: json['competition'] as String,
      stadium: json['stadium'] as String,
      round: json['round'] as int? ?? 1,
      isMoneyPool: json['isMoneyPool'] as bool? ?? true,
      startDate: DateTime.parse(json['startDate'] as String).toLocal(),
      status: MatchStatus.fromJson(json['status'] as String),
      homeGoals: json['homeGoals'] as int?,
      awayGoals: json['awayGoals'] as int?,
    );
  }
}
