import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../matches/domain/match_model.dart';
import '../domain/prediction_model.dart';
import 'predictions_cubit.dart';

class PredictionSheet extends StatefulWidget {
  const PredictionSheet({required this.match, this.prediction, super.key});

  final MatchModel match;
  final PredictionModel? prediction;

  static Future<void> show(
    BuildContext context, {
    required MatchModel match,
    PredictionModel? prediction,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => BlocProvider.value(
        value: context.read<PredictionsCubit>(),
        child: PredictionSheet(match: match, prediction: prediction),
      ),
    );
  }

  @override
  State<PredictionSheet> createState() => _PredictionSheetState();
}

class _PredictionSheetState extends State<PredictionSheet> {
  late final TextEditingController _homeController;
  late final TextEditingController _awayController;

  @override
  void initState() {
    super.initState();
    _homeController = TextEditingController(
      text: widget.prediction?.homeGoals.toString() ?? '0',
    );
    _awayController = TextEditingController(
      text: widget.prediction?.awayGoals.toString() ?? '0',
    );
  }

  @override
  void dispose() {
    _homeController.dispose();
    _awayController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final home = int.tryParse(_homeController.text);
    final away = int.tryParse(_awayController.text);
    if (home == null || away == null || home < 0 || away < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe placares válidos.')),
      );
      return;
    }

    final success = await context.read<PredictionsCubit>().save(
      matchId: widget.match.id,
      homeGoals: home,
      awayGoals: away,
    );
    if (success && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 42,
            height: 4,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          Text(
            widget.prediction == null
                ? 'Faça seu palpite'
                : 'Edite seu palpite',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text('${widget.match.homeTeam} × ${widget.match.awayTeam}'),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: _ScoreField(
                  label: widget.match.homeTeam,
                  controller: _homeController,
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(14, 28, 14, 0),
                child: Text('×', style: TextStyle(fontSize: 28)),
              ),
              Expanded(
                child: _ScoreField(
                  label: widget.match.awayTeam,
                  controller: _awayController,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          BlocBuilder<PredictionsCubit, PredictionsState>(
            builder: (context, state) {
              final isSubmitting = state.submittingMatchId == widget.match.id;
              return FilledButton.icon(
                onPressed: isSubmitting ? null : _save,
                icon: isSubmitting
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check),
                label: const Text('Salvar palpite'),
              );
            },
          ),
          BlocBuilder<PredictionsCubit, PredictionsState>(
            builder: (context, state) {
              if (state.errorMessage == null) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  state.errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ScoreField extends StatelessWidget {
  const _ScoreField({required this.label, required this.controller});

  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      style: Theme.of(
        context,
      ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
      decoration: InputDecoration(labelText: label),
    );
  }
}
