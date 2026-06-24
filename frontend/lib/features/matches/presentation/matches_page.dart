import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/account_menu.dart';
import '../../predictions/domain/prediction_model.dart';
import '../../predictions/presentation/prediction_sheet.dart';
import '../../predictions/presentation/predictions_cubit.dart';
import '../domain/match_model.dart';
import 'matches_cubit.dart';

class MatchesPage extends StatefulWidget {
  const MatchesPage({super.key});

  @override
  State<MatchesPage> createState() => _MatchesPageState();
}

class _MatchesPageState extends State<MatchesPage> {
  @override
  void initState() {
    super.initState();
    if (context.read<MatchesCubit>().state.status ==
        MatchesLoadStatus.initial) {
      context.read<MatchesCubit>().load();
    }
    if (context.read<PredictionsCubit>().state.byMatchId.isEmpty) {
      context.read<PredictionsCubit>().loadMine();
    }
  }

  Future<void> _refresh() async {
    await Future.wait([
      context.read<MatchesCubit>().load(),
      context.read<PredictionsCubit>().loadMine(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Partidas'),
            Text(
              'Escolha seu jogo e palpite',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: const [AccountMenu()],
      ),
      body: Column(
        children: [
          const _MatchFilters(),
          Expanded(
            child: BlocBuilder<MatchesCubit, MatchesState>(
              builder: (context, state) {
                if (state.status == MatchesLoadStatus.loading &&
                    state.matches.isEmpty) {
                  return const AppLoadingView();
                }
                if (state.status == MatchesLoadStatus.failure &&
                    state.matches.isEmpty) {
                  return AppMessageView(
                    icon: Icons.cloud_off_outlined,
                    title: 'Não foi possível carregar',
                    message: state.errorMessage ?? 'Tente novamente.',
                    onAction: () => context.read<MatchesCubit>().load(),
                  );
                }
                if (state.matches.isEmpty) {
                  return const AppMessageView(
                    icon: Icons.event_busy_outlined,
                    title: 'Nenhuma partida',
                    message: 'Não há partidas para este filtro.',
                  );
                }
                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
                    itemCount: state.matches.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final match = state.matches[index];
                      return BlocBuilder<PredictionsCubit, PredictionsState>(
                        buildWhen: (previous, current) =>
                            previous.byMatchId[match.id] !=
                            current.byMatchId[match.id],
                        builder: (context, predictionsState) => _MatchCard(
                          match: match,
                          prediction: predictionsState.byMatchId[match.id],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MatchFilters extends StatelessWidget {
  const _MatchFilters();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MatchesCubit, MatchesState>(
      buildWhen: (previous, current) => previous.filter != current.filter,
      builder: (context, state) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              ChoiceChip(
                label: const Text('Todas'),
                selected: state.filter == null,
                onSelected: (_) =>
                    context.read<MatchesCubit>().load(clearFilter: true),
              ),
              const SizedBox(width: 8),
              for (final status in MatchStatus.values) ...[
                ChoiceChip(
                  label: Text(status.label),
                  selected: state.filter == status,
                  onSelected: (_) =>
                      context.read<MatchesCubit>().load(filter: status),
                ),
                const SizedBox(width: 8),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _MatchCard extends StatelessWidget {
  const _MatchCard({required this.match, this.prediction});

  final MatchModel match;
  final PredictionModel? prediction;

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('dd/MM • HH:mm').format(match.startDate);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${match.competition} • Rodada ${match.round}',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
                _StatusBadge(status: match.status),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(child: _TeamName(name: match.homeTeam)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    match.status == MatchStatus.finished
                        ? '${match.homeGoals ?? 0}  ×  ${match.awayGoals ?? 0}'
                        : '×',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Expanded(
                  child: _TeamName(name: match.awayTeam, alignRight: true),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                const Icon(Icons.schedule, size: 18),
                const SizedBox(width: 6),
                Text(date),
                const Spacer(),
                Flexible(
                  child: Text(
                    match.stadium,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
            if (prediction != null) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Seu palpite: ${prediction!.homeGoals} × ${prediction!.awayGoals}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
            if (match.acceptsPrediction) ...[
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: () => PredictionSheet.show(
                  context,
                  match: match,
                  prediction: prediction,
                ),
                icon: const Icon(Icons.edit_note),
                label: Text(
                  prediction == null ? 'Fazer palpite' : 'Editar palpite',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TeamName extends StatelessWidget {
  const _TeamName({required this.name, this.alignRight = false});

  final String name;
  final bool alignRight;

  @override
  Widget build(BuildContext context) {
    return Text(
      name,
      textAlign: alignRight ? TextAlign.end : TextAlign.start,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final MatchStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      MatchStatus.live => Colors.red,
      MatchStatus.finished => Colors.blueGrey,
      MatchStatus.scheduled => Theme.of(context).colorScheme.primary,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        status.label,
        style: TextStyle(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}
