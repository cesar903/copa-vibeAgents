import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/matches/domain/match_model.dart';

void main() {
  test('parses API match payload', () {
    final match = MatchModel.fromJson({
      'id': 'match-1',
      'homeTeam': 'Brasil',
      'awayTeam': 'Argentina',
      'competition': 'Copa',
      'stadium': 'Maracanã',
      'startDate': '2030-06-18T18:00:00.000Z',
      'status': 'SCHEDULED',
      'homeGoals': null,
      'awayGoals': null,
    });

    expect(match.status, MatchStatus.scheduled);
    expect(match.homeTeam, 'Brasil');
    expect(match.awayTeam, 'Argentina');
  });

  test('only accepts predictions before the fifteen minute lock', () {
    final openMatch = MatchModel(
      id: 'open',
      homeTeam: 'A',
      awayTeam: 'B',
      competition: 'Copa',
      stadium: 'Arena',
      round: 1,
      startDate: DateTime.now().add(const Duration(hours: 1)),
      status: MatchStatus.scheduled,
    );
    final lockedMatch = MatchModel(
      id: 'locked',
      homeTeam: 'A',
      awayTeam: 'B',
      competition: 'Copa',
      stadium: 'Arena',
      round: 1,
      startDate: DateTime.now().add(const Duration(minutes: 10)),
      status: MatchStatus.scheduled,
    );

    expect(openMatch.acceptsPrediction, isTrue);
    expect(lockedMatch.acceptsPrediction, isFalse);
  });
}
