import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_exception.dart';
import '../data/ranking_repository.dart';
import '../domain/ranking_entry.dart';

enum RankingStatus { initial, loading, success, failure }

class RankingState extends Equatable {
  const RankingState({
    this.status = RankingStatus.initial,
    this.entries = const [],
    this.errorMessage,
  });

  final RankingStatus status;
  final List<RankingEntry> entries;
  final String? errorMessage;

  @override
  List<Object?> get props => [status, entries, errorMessage];
}

class RankingCubit extends Cubit<RankingState> {
  RankingCubit(this._repository) : super(const RankingState());

  final RankingRepository _repository;

  void reset() => emit(const RankingState());

  Future<void> load() async {
    emit(RankingState(status: RankingStatus.loading, entries: state.entries));
    try {
      emit(
        RankingState(
          status: RankingStatus.success,
          entries: await _repository.findAll(),
        ),
      );
    } on ApiException catch (error) {
      emit(
        RankingState(
          status: RankingStatus.failure,
          entries: state.entries,
          errorMessage: error.message,
        ),
      );
    }
  }
}
