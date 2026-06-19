import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_exception.dart';
import '../data/predictions_repository.dart';
import '../domain/prediction_model.dart';

class PredictionsState extends Equatable {
  const PredictionsState({
    this.byMatchId = const {},
    this.isLoading = false,
    this.submittingMatchId,
    this.errorMessage,
    this.successMessage,
  });

  final Map<String, PredictionModel> byMatchId;
  final bool isLoading;
  final String? submittingMatchId;
  final String? errorMessage;
  final String? successMessage;

  @override
  List<Object?> get props => [
    byMatchId,
    isLoading,
    submittingMatchId,
    errorMessage,
    successMessage,
  ];
}

class PredictionsCubit extends Cubit<PredictionsState> {
  PredictionsCubit(this._repository) : super(const PredictionsState());

  final PredictionsRepository _repository;

  void reset() => emit(const PredictionsState());

  Future<void> loadMine() async {
    emit(PredictionsState(byMatchId: state.byMatchId, isLoading: true));
    try {
      final predictions = await _repository.findMine();
      emit(
        PredictionsState(
          byMatchId: {for (final item in predictions) item.matchId: item},
        ),
      );
    } on ApiException catch (error) {
      emit(
        PredictionsState(
          byMatchId: state.byMatchId,
          errorMessage: error.message,
        ),
      );
    }
  }

  Future<bool> save({
    required String matchId,
    required int homeGoals,
    required int awayGoals,
  }) async {
    emit(
      PredictionsState(byMatchId: state.byMatchId, submittingMatchId: matchId),
    );
    try {
      final prediction = await _repository.save(
        matchId: matchId,
        homeGoals: homeGoals,
        awayGoals: awayGoals,
      );
      emit(
        PredictionsState(
          byMatchId: {...state.byMatchId, matchId: prediction},
          successMessage: 'Palpite salvo com sucesso.',
        ),
      );
      return true;
    } on ApiException catch (error) {
      emit(
        PredictionsState(
          byMatchId: state.byMatchId,
          errorMessage: error.message,
        ),
      );
      return false;
    }
  }
}
