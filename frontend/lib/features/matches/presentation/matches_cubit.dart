import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_exception.dart';
import '../data/matches_repository.dart';
import '../domain/match_model.dart';

enum MatchesLoadStatus { initial, loading, success, failure }

class MatchesState extends Equatable {
  const MatchesState({
    this.status = MatchesLoadStatus.initial,
    this.matches = const [],
    this.filter,
    this.errorMessage,
  });

  final MatchesLoadStatus status;
  final List<MatchModel> matches;
  final MatchStatus? filter;
  final String? errorMessage;

  MatchesState copyWith({
    MatchesLoadStatus? status,
    List<MatchModel>? matches,
    MatchStatus? filter,
    bool clearFilter = false,
    String? errorMessage,
  }) {
    return MatchesState(
      status: status ?? this.status,
      matches: matches ?? this.matches,
      filter: clearFilter ? null : filter ?? this.filter,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, matches, filter, errorMessage];
}

class MatchesCubit extends Cubit<MatchesState> {
  MatchesCubit(this._repository) : super(const MatchesState());

  final MatchesRepository _repository;

  void reset() => emit(const MatchesState());

  Future<void> load({MatchStatus? filter, bool clearFilter = false}) async {
    final selectedFilter = clearFilter ? null : filter ?? state.filter;
    emit(
      state.copyWith(
        status: MatchesLoadStatus.loading,
        filter: selectedFilter,
        clearFilter: clearFilter,
      ),
    );
    try {
      final matches = await _repository.findAll(status: selectedFilter);
      emit(
        state.copyWith(
          status: MatchesLoadStatus.success,
          matches: matches,
          filter: selectedFilter,
          clearFilter: clearFilter,
        ),
      );
    } on ApiException catch (error) {
      emit(
        state.copyWith(
          status: MatchesLoadStatus.failure,
          errorMessage: error.message,
        ),
      );
    }
  }
}
