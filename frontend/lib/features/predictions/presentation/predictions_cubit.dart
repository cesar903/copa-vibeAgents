import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_exception.dart';
import '../data/predictions_repository.dart';
import '../domain/prediction_model.dart';

class PredictionsState extends Equatable {
  const PredictionsState({
    this.byMatchId = const {},
    this.visibleByMatchId = const {},
    this.loadingVisibleMatchIds = const {},
    this.isLoading = false,
    this.submittingMatchId,
    this.errorMessage,
    this.successMessage,
  });

  final Map<String, PredictionModel> byMatchId;
  final Map<String, List<PredictionModel>> visibleByMatchId;
  final Set<String> loadingVisibleMatchIds;
  final bool isLoading;
  final String? submittingMatchId;
  final String? errorMessage;
  final String? successMessage;

  @override
  List<Object?> get props => [
    byMatchId,
    visibleByMatchId,
    loadingVisibleMatchIds,
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
    emit(
      PredictionsState(
        byMatchId: state.byMatchId,
        visibleByMatchId: state.visibleByMatchId,
        loadingVisibleMatchIds: state.loadingVisibleMatchIds,
        isLoading: true,
      ),
    );
    try {
      final predictions = await _repository.findMine();
      emit(
        PredictionsState(
          byMatchId: {for (final item in predictions) item.matchId: item},
          visibleByMatchId: state.visibleByMatchId,
          loadingVisibleMatchIds: state.loadingVisibleMatchIds,
        ),
      );
    } on ApiException catch (error) {
      emit(
        PredictionsState(
          byMatchId: state.byMatchId,
          visibleByMatchId: state.visibleByMatchId,
          loadingVisibleMatchIds: state.loadingVisibleMatchIds,
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
      PredictionsState(
        byMatchId: state.byMatchId,
        visibleByMatchId: state.visibleByMatchId,
        loadingVisibleMatchIds: state.loadingVisibleMatchIds,
        submittingMatchId: matchId,
      ),
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
          visibleByMatchId: {
            ...state.visibleByMatchId,
            if (state.visibleByMatchId.containsKey(matchId))
              matchId: [
                prediction,
                ...state.visibleByMatchId[matchId]!.where(
                  (item) => item.id != prediction.id,
                ),
              ],
          },
          loadingVisibleMatchIds: state.loadingVisibleMatchIds,
          successMessage: 'Palpite salvo com sucesso.',
        ),
      );
      return true;
    } on ApiException catch (error) {
      emit(
        PredictionsState(
          byMatchId: state.byMatchId,
          visibleByMatchId: state.visibleByMatchId,
          loadingVisibleMatchIds: state.loadingVisibleMatchIds,
          errorMessage: error.message,
        ),
      );
      return false;
    }
  }

  Future<void> loadForMatch(String matchId) async {
    if (state.loadingVisibleMatchIds.contains(matchId)) return;

    emit(
      PredictionsState(
        byMatchId: state.byMatchId,
        visibleByMatchId: state.visibleByMatchId,
        loadingVisibleMatchIds: {...state.loadingVisibleMatchIds, matchId},
      ),
    );
    try {
      final predictions = await _repository.findByMatch(matchId);
      final loadingIds = {...state.loadingVisibleMatchIds}..remove(matchId);
      emit(
        PredictionsState(
          byMatchId: state.byMatchId,
          visibleByMatchId: {
            ...state.visibleByMatchId,
            matchId: predictions,
          },
          loadingVisibleMatchIds: loadingIds,
        ),
      );
    } on ApiException catch (error) {
      final loadingIds = {...state.loadingVisibleMatchIds}..remove(matchId);
      emit(
        PredictionsState(
          byMatchId: state.byMatchId,
          visibleByMatchId: state.visibleByMatchId,
          loadingVisibleMatchIds: loadingIds,
          errorMessage: error.message,
        ),
      );
    }
  }
}
