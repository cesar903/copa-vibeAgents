import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/widgets/account_menu.dart';
import '../data/matches_repository.dart';
import '../domain/match_model.dart';
import '../../predictions/domain/prediction_model.dart';
import '../../ranking/domain/ranking_entry.dart';
import '../../ranking/presentation/ranking_cubit.dart';
import 'matches_cubit.dart';
import 'report_exporter_stub.dart'
    if (dart.library.html) 'report_exporter_web.dart';

class MatchAdminPage extends StatefulWidget {
  const MatchAdminPage({required this.repository, super.key});

  final MatchesRepository repository;

  @override
  State<MatchAdminPage> createState() => _MatchAdminPageState();
}

class _MatchAdminPageState extends State<MatchAdminPage> {
  final _formKey = GlobalKey<FormState>();
  final _homeTeamController = TextEditingController();
  final _awayTeamController = TextEditingController();
  final _competitionController = TextEditingController();
  final _stadiumController = TextEditingController();
  final _roundController = TextEditingController(text: '1');
  final _homeGoalsController = TextEditingController();
  final _awayGoalsController = TextEditingController();

  DateTime _startDate = DateTime.now().add(const Duration(days: 1));
  MatchStatus _status = MatchStatus.scheduled;
  bool _isMoneyPool = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _homeTeamController.dispose();
    _awayTeamController.dispose();
    _competitionController.dispose();
    _stadiumController.dispose();
    _roundController.dispose();
    _homeGoalsController.dispose();
    _awayGoalsController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startDate),
    );
    if (time == null) return;

    setState(() {
      _startDate = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      await widget.repository.create(
        homeTeam: _homeTeamController.text.trim(),
        awayTeam: _awayTeamController.text.trim(),
        competition: _competitionController.text.trim(),
        stadium: _stadiumController.text.trim(),
        round: int.parse(_roundController.text),
        isMoneyPool: _isMoneyPool,
        startDate: _startDate,
        status: _status,
        homeGoals: int.tryParse(_homeGoalsController.text),
        awayGoals: int.tryParse(_awayGoalsController.text),
      );
      if (!mounted) return;
      await context.read<MatchesCubit>().load(clearFilter: true);
      if (!mounted) return;
      _formKey.currentState!.reset();
      _homeTeamController.clear();
      _awayTeamController.clear();
      _competitionController.clear();
      _stadiumController.clear();
      _roundController.text = '1';
      _homeGoalsController.clear();
      _awayGoalsController.clear();
      setState(() {
        _status = MatchStatus.scheduled;
        _isMoneyPool = true;
        _startDate = DateTime.now().add(const Duration(days: 1));
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Partida cadastrada com sucesso.')),
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) return 'Campo obrigatÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â³rio';
    return null;
  }

  String? _validRound(String? value) {
    final round = int.tryParse(value ?? '');
    if (round == null || round < 1) return 'Informe uma rodada vÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¡lida';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final showScores = _status != MatchStatus.scheduled;
    return Scaffold(
      appBar: AppBar(
        title: const Text('AdministraÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â§ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â£o'),
        actions: const [AccountMenu()],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 110),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Nova partida',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text('Preencha os dados oficiais do jogo.'),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _homeTeamController,
                          decoration: const InputDecoration(
                            labelText: 'Time da casa',
                          ),
                          validator: _required,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _awayTeamController,
                          decoration: const InputDecoration(
                            labelText: 'Time visitante',
                          ),
                          validator: _required,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _competitionController,
                          decoration: const InputDecoration(
                            labelText: 'CompetiÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â§ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â£o',
                          ),
                          validator: _required,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _stadiumController,
                          decoration: const InputDecoration(
                            labelText: 'EstÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¡dio',
                          ),
                          validator: _required,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _roundController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Rodada',
                            helperText:
                                'UsuÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¡rios sem pagamento nesta rodada nÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â£o pontuam.',
                          ),
                          validator: _validRound,
                        ),
                        const SizedBox(height: 16),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Vale dinheiro'),
                          subtitle: Text(
                            _isMoneyPool
                                ? 'So pontua quem estiver pago na rodada.'
                                : 'Pontuacao conta para todos, sem cobranca.',
                          ),
                          value: _isMoneyPool,
                          onChanged: (value) {
                            setState(() => _isMoneyPool = value);
                          },
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: _selectDateTime,
                          icon: const Icon(Icons.event_outlined),
                          label: Text(
                            DateFormat(
                              'dd/MM/yyyy ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ HH:mm',
                            ).format(_startDate),
                          ),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<MatchStatus>(
                          initialValue: _status,
                          decoration: const InputDecoration(
                            labelText: 'Status',
                          ),
                          items: MatchStatus.values
                              .map(
                                (status) => DropdownMenuItem(
                                  value: status,
                                  child: Text(status.label),
                                ),
                              )
                              .toList(),
                          onChanged: (status) {
                            if (status != null) {
                              setState(() => _status = status);
                            }
                          },
                        ),
                        if (showScores) ...[
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _homeGoalsController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Gols da casa',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _awayGoalsController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Gols visitante',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 24),
                        FilledButton.icon(
                          onPressed: _isSubmitting ? null : _submit,
                          icon: _isSubmitting
                              ? const SizedBox.square(
                                  dimension: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.add_circle_outline),
                          label: Text(
                            _isSubmitting
                                ? 'Cadastrando...'
                                : 'Cadastrar partida',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  _ResultsReportPanel(repository: widget.repository),
                  const SizedBox(height: 32),
                  _MatchesAdminPanel(repository: widget.repository),
                  const SizedBox(height: 32),
                  _RoundPaymentsPanel(repository: widget.repository),
                  const SizedBox(height: 32),
                  _UsersAdminPanel(repository: widget.repository),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultsReportPanel extends StatefulWidget {
  const _ResultsReportPanel({required this.repository});

  final MatchesRepository repository;

  @override
  State<_ResultsReportPanel> createState() => _ResultsReportPanelState();
}

class _ResultsReportPanelState extends State<_ResultsReportPanel> {
  bool _isGenerating = false;

  Future<void> _generateReport() async {
    setState(() => _isGenerating = true);
    try {
      final matches = (await widget.repository.findAll())
          .where((match) => match.status != MatchStatus.scheduled)
          .toList();
      final ranking = await widget.repository.findRanking();
      final predictionsByMatch = <String, List<PredictionModel>>{};

      for (final match in matches) {
        predictionsByMatch[match.id] = await widget.repository
            .findPredictionsByMatch(match.id);
      }

      final html = _ResultsReportHtmlBuilder(
        matches: matches,
        ranking: ranking,
        predictionsByMatch: predictionsByMatch,
      ).build();
      final opened = await openResultsReport(html);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            opened
                ? 'RelatÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â³rio aberto. Use "Salvar como PDF".'
                : 'GeraÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â§ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â£o de PDF disponÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â­vel apenas na versÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â£o web.',
          ),
        ),
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'RelatÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â³rio de resultados',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Gera ranking, partidas ao vivo/finalizadas e palpites de cada usuÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¡rio.',
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _isGenerating ? null : _generateReport,
              icon: _isGenerating
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.picture_as_pdf_outlined),
              label: Text(
                _isGenerating ? 'Gerando relatÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â³rio...' : 'Gerar PDF',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultsReportHtmlBuilder {
  _ResultsReportHtmlBuilder({
    required this.matches,
    required this.ranking,
    required this.predictionsByMatch,
  });

  final List<MatchModel> matches;
  final List<RankingEntry> ranking;
  final Map<String, List<PredictionModel>> predictionsByMatch;
  final _escape = const HtmlEscape();

  String build() {
    final generatedAt = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());
    final rankingRows = ranking.map(_rankingRow).join();
    final matchSections = matches.map(_matchSection).join();

    return '''
<!doctype html>
<html lang="pt-BR">
<head>
  <meta charset="utf-8">
  <title>Resultados - Copa Amigos</title>
  <style>
    body { font-family: Arial, sans-serif; color: #111827; margin: 32px; }
    h1 { margin-bottom: 4px; }
    h2 { margin-top: 28px; border-bottom: 1px solid #e5e7eb; padding-bottom: 8px; }
    h3 { margin-bottom: 4px; }
    .meta { color: #6b7280; margin-bottom: 24px; }
    table { width: 100%; border-collapse: collapse; margin-top: 12px; }
    th, td { border: 1px solid #e5e7eb; padding: 8px; text-align: left; }
    th { background: #f3f4f6; }
    .score { font-weight: 700; white-space: nowrap; }
    .empty { color: #6b7280; font-style: italic; }
    .match { break-inside: avoid; margin-bottom: 24px; }
    @media print { body { margin: 16px; } }
  </style>
  <script>
    window.addEventListener('load', function () {
      setTimeout(function () { window.print(); }, 400);
    });
  </script>
</head>
<body>
  <h1>Resultados - Copa Amigos</h1>
  <div class="meta">Gerado em $generatedAt</div>
  <h2>Ranking</h2>
  <table>
    <thead>
      <tr>
        <th>PosiÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â§ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â£o</th>
        <th>UsuÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¡rio</th>
        <th>Pontos</th>
        <th>Placares exatos</th>
        <th>Resultados corretos</th>
      </tr>
    </thead>
    <tbody>
      ${rankingRows.isEmpty ? '<tr><td colspan="5" class="empty">Ranking vazio.</td></tr>' : rankingRows}
    </tbody>
  </table>
  <h2>Partidas e palpites</h2>
  ${matchSections.isEmpty ? '<p class="empty">Nenhuma partida ao vivo ou finalizada.</p>' : matchSections}
</body>
</html>
''';
  }

  String _rankingRow(RankingEntry entry) {
    return '''
<tr>
  <td>${entry.position}</td>
  <td>${_escape.convert(entry.user.name)}</td>
  <td>${entry.points}</td>
  <td>${entry.exactScores}</td>
  <td>${entry.correctWinners}</td>
</tr>
''';
  }

  String _matchSection(MatchModel match) {
    final predictions = predictionsByMatch[match.id] ?? const [];
    final predictionRows = predictions.map(_predictionRow).join();
    final date = DateFormat('dd/MM/yyyy HH:mm').format(match.startDate);
    final moneyLabel = match.isMoneyPool ? 'Vale grana' : 'Sem grana';
    final score = match.status == MatchStatus.scheduled
        ? 'Aguardando'
        : '${match.homeGoals ?? '-'} x ${match.awayGoals ?? '-'}';

    return '''
<section class="match">
  <h3>${_escape.convert(match.homeTeam)} x ${_escape.convert(match.awayTeam)}</h3>
  <div class="meta">
    ${_escape.convert(match.competition)} - Rodada ${match.round} - $moneyLabel - ${match.status.label} - $date
  </div>
  <div>Placar: <span class="score">$score</span></div>
  <table>
    <thead>
      <tr>
        <th>UsuÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¡rio</th>
        <th>Palpite</th>
      </tr>
    </thead>
    <tbody>
      ${predictionRows.isEmpty ? '<tr><td colspan="2" class="empty">Nenhum palpite encontrado.</td></tr>' : predictionRows}
    </tbody>
  </table>
</section>
''';
  }

  String _predictionRow(PredictionModel prediction) {
    final name = prediction.user?.name ?? 'UsuÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¡rio';
    return '''
<tr>
  <td>${_escape.convert(name)}</td>
  <td class="score">${prediction.homeGoals} ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â ${prediction.awayGoals}</td>
</tr>
''';
  }
}

class _MatchesAdminPanel extends StatefulWidget {
  const _MatchesAdminPanel({required this.repository});

  final MatchesRepository repository;

  @override
  State<_MatchesAdminPanel> createState() => _MatchesAdminPanelState();
}

class _MatchesAdminPanelState extends State<_MatchesAdminPanel> {
  List<MatchModel> _matches = const [];
  bool _isLoading = false;
  String? _savingMatchId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final matches = await widget.repository.findAll();
      if (!mounted) return;
      setState(() => _matches = matches);
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _editMatch(MatchModel match) async {
    final result = await showDialog<_MatchUpdateResult>(
      context: context,
      builder: (_) => _MatchStatusDialog(match: match),
    );

    if (result == null) return;

    setState(() => _savingMatchId = match.id);
    try {
      await widget.repository.update(
        id: match.id,
        status: result.status,
        isMoneyPool: result.isMoneyPool,
        homeGoals: result.homeGoals,
        awayGoals: result.awayGoals,
      );
      await _load();
      if (!mounted) return;
      await context.read<MatchesCubit>().load(clearFilter: true);
      if (!mounted) return;
      await context.read<RankingCubit>().load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Partida atualizada com sucesso.')),
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => _savingMatchId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Partidas cadastradas',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _isLoading ? null : _load,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Use esta ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¡rea para colocar o jogo ao vivo ou finalizar com placar.',
            ),
            const SizedBox(height: 16),
            if (_isLoading && _matches.isEmpty)
              const Center(child: CircularProgressIndicator())
            else if (_matches.isEmpty)
              const Text('Nenhuma partida cadastrada.')
            else
              ..._matches.map(
                (match) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('${match.homeTeam} ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â ${match.awayTeam}'),
                  subtitle: Text(_matchSubtitle(match)),
                  trailing: _savingMatchId == match.id
                      ? const SizedBox.square(
                          dimension: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : OutlinedButton.icon(
                          onPressed: () => _editMatch(match),
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text('Editar'),
                        ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _matchSubtitle(MatchModel match) {
    final date = DateFormat('dd/MM HH:mm').format(match.startDate);
    final moneyLabel = match.isMoneyPool ? 'Vale grana' : 'Sem grana';
    return 'Rodada ${match.round} - $moneyLabel - ${match.status.label} - $date';
  }
}
class _MatchUpdateResult {
  const _MatchUpdateResult({
    required this.status,
    required this.isMoneyPool,
    this.homeGoals,
    this.awayGoals,
  });

  final MatchStatus status;
  final bool isMoneyPool;
  final int? homeGoals;
  final int? awayGoals;
}

class _MatchStatusDialog extends StatefulWidget {
  const _MatchStatusDialog({required this.match});

  final MatchModel match;

  @override
  State<_MatchStatusDialog> createState() => _MatchStatusDialogState();
}

class _MatchStatusDialogState extends State<_MatchStatusDialog> {
  final _formKey = GlobalKey<FormState>();
  late MatchStatus _status;
  late bool _isMoneyPool;
  late final TextEditingController _homeGoalsController;
  late final TextEditingController _awayGoalsController;

  @override
  void initState() {
    super.initState();
    _status = widget.match.status;
    _isMoneyPool = widget.match.isMoneyPool;
    _homeGoalsController = TextEditingController(
      text: widget.match.homeGoals?.toString() ?? '',
    );
    _awayGoalsController = TextEditingController(
      text: widget.match.awayGoals?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _homeGoalsController.dispose();
    _awayGoalsController.dispose();
    super.dispose();
  }

  String? _scoreValidator(String? value) {
    if (_status != MatchStatus.finished) return null;
    final goals = int.tryParse(value ?? '');
    if (goals == null || goals < 0) return 'Informe os gols';
    return null;
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.of(context).pop(
      _MatchUpdateResult(
        status: _status,
        isMoneyPool: _isMoneyPool,
        homeGoals: _status == MatchStatus.scheduled
            ? null
            : int.tryParse(_homeGoalsController.text),
        awayGoals: _status == MatchStatus.scheduled
            ? null
            : int.tryParse(_awayGoalsController.text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final showScores = _status != MatchStatus.scheduled;
    return AlertDialog(
      title: Text('${widget.match.homeTeam} ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â ${widget.match.awayTeam}'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<MatchStatus>(
                initialValue: _status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: MatchStatus.values
                    .map(
                      (status) => DropdownMenuItem(
                        value: status,
                        child: Text(status.label),
                      ),
                    )
                    .toList(),
                onChanged: (status) {
                  if (status != null) setState(() => _status = status);
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Vale dinheiro'),
                subtitle: Text(
                  _isMoneyPool
                      ? 'So pontua quem estiver pago na rodada.'
                      : 'Pontuacao conta para todos, sem cobranca.',
                ),
                value: _isMoneyPool,
                onChanged: (value) {
                  setState(() => _isMoneyPool = value);
                },
              ),
              if (showScores) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _homeGoalsController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Gols ${widget.match.homeTeam}',
                        ),
                        validator: _scoreValidator,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _awayGoalsController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Gols ${widget.match.awayTeam}',
                        ),
                        validator: _scoreValidator,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _status == MatchStatus.finished
                      ? 'Ao salvar como finalizada, o ranking serÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¡ recalculado.'
                      : 'Ao vivo libera a visualizaÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â§ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â£o dos palpites dos outros usuÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¡rios.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _save, child: const Text('Salvar')),
      ],
    );
  }
}

class _RoundPaymentsPanel extends StatefulWidget {
  const _RoundPaymentsPanel({required this.repository});

  final MatchesRepository repository;

  @override
  State<_RoundPaymentsPanel> createState() => _RoundPaymentsPanelState();
}

class _RoundPaymentsPanelState extends State<_RoundPaymentsPanel> {
  final _roundController = TextEditingController(text: '1');
  List<RoundPaymentModel> _payments = const [];
  bool _isLoading = false;
  String? _savingUserId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _roundController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final round = int.tryParse(_roundController.text);
    if (round == null || round < 1) return;

    setState(() => _isLoading = true);
    try {
      final payments = await widget.repository.findRoundPayments(round: round);
      if (!mounted) return;
      setState(() => _payments = payments);
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _togglePayment(RoundPaymentModel payment, bool paid) async {
    setState(() => _savingUserId = payment.userId);
    try {
      await widget.repository.setRoundPayment(
        userId: payment.userId,
        round: payment.round,
        paid: paid,
      );
      await _load();
      if (!mounted) return;
      await context.read<RankingCubit>().load();
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => _savingUserId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Pagamentos da rodada',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Marque quem pagou. Se nÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â£o pagou, os jogos dessa rodada nÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â£o entram no ranking do usuÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¡rio.',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _roundController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Rodada'),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: _isLoading ? null : _load,
                  icon: _isLoading
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.search),
                  label: const Text('Buscar'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isLoading && _payments.isEmpty)
              const Center(child: CircularProgressIndicator())
            else if (_payments.isEmpty)
              const Text('Nenhum usuÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¡rio encontrado.')
            else
              ..._payments.map(
                (payment) => SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(payment.userName),
                  subtitle: Text(payment.userEmail),
                  value: payment.paid,
                  onChanged: _savingUserId == null
                      ? (paid) => _togglePayment(payment, paid)
                      : null,
                  secondary: _savingUserId == payment.userId
                      ? const SizedBox.square(
                          dimension: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          payment.paid
                              ? Icons.check_circle_outline
                              : Icons.cancel_outlined,
                        ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _UsersAdminPanel extends StatefulWidget {
  const _UsersAdminPanel({required this.repository});

  final MatchesRepository repository;

  @override
  State<_UsersAdminPanel> createState() => _UsersAdminPanelState();
}

class _UsersAdminPanelState extends State<_UsersAdminPanel> {
  List<AdminUserModel> _users = const [];
  bool _isLoading = false;
  String? _busyUserId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final users = await widget.repository.findUsers();
      if (!mounted) return;
      setState(() => _users = users);
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _changePassword(AdminUserModel user) async {
    final controller = TextEditingController();
    final password = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Alterar senha de ${user.name}'),
        content: TextField(
          controller: controller,
          autofocus: true,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Nova senha',
            helperText: 'MÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â­nimo de 8 caracteres.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
    controller.dispose();

    if (password == null) return;
    if (password.length < 8) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A senha precisa ter no mÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â­nimo 8 caracteres.')),
      );
      return;
    }

    setState(() => _busyUserId = user.id);
    try {
      await widget.repository.changeUserPassword(
        userId: user.id,
        password: password,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Senha de ${user.name} alterada.')),
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => _busyUserId = null);
    }
  }

  Future<void> _editUser(AdminUserModel user) async {
    final result = await showDialog<_UserUpdateResult>(
      context: context,
      builder: (_) => _UserEditDialog(user: user),
    );

    if (result == null) return;

    setState(() => _busyUserId = user.id);
    try {
      await widget.repository.updateUser(
        userId: user.id,
        name: result.name,
        email: result.email,
      );
      await _load();
      if (!mounted) return;
      await context.read<RankingCubit>().load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Conta de ${result.name} atualizada.')),
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => _busyUserId = null);
    }
  }

  Future<void> _deleteUser(AdminUserModel user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Excluir ${user.name}?'),
        content: Text(
          'Esta aÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â§ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â£o remove a conta, palpites, pagamentos e ranking deste usuÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¡rio. NÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â£o ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â© possÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â­vel desfazer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _busyUserId = user.id);
    try {
      await widget.repository.deleteUser(userId: user.id);
      await _load();
      if (!mounted) return;
      await context.read<RankingCubit>().load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${user.name} foi excluÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â­do.')),
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => _busyUserId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'UsuÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¡rios',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _isLoading ? null : _load,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text('Altere senhas ou exclua contas quando necessÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¡rio.'),
            const SizedBox(height: 16),
            if (_isLoading && _users.isEmpty)
              const Center(child: CircularProgressIndicator())
            else if (_users.isEmpty)
              const Text('Nenhum usuÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¡rio encontrado.')
            else
              ..._users.map(
                (user) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(user.name),
                  subtitle: Text(user.email),
                  trailing: _busyUserId == user.id
                      ? const SizedBox.square(
                          dimension: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Wrap(
                          spacing: 8,
                          children: [
                            IconButton(
                              tooltip: 'Alterar conta',
                              onPressed: () => _editUser(user),
                              icon: const Icon(Icons.edit_outlined),
                            ),
                            IconButton(
                              tooltip: 'Alterar senha',
                              onPressed: () => _changePassword(user),
                              icon: const Icon(Icons.lock_reset),
                            ),
                            IconButton(
                              tooltip: 'Excluir usuÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¡rio',
                              onPressed: () => _deleteUser(user),
                              icon: const Icon(Icons.delete_outline),
                            ),
                          ],
                        ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _UserUpdateResult {
  const _UserUpdateResult({required this.name, required this.email});

  final String name;
  final String email;
}

class _UserEditDialog extends StatefulWidget {
  const _UserEditDialog({required this.user});

  final AdminUserModel user;

  @override
  State<_UserEditDialog> createState() => _UserEditDialogState();
}

class _UserEditDialogState extends State<_UserEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) return 'Campo obrigatÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â³rio';
    return null;
  }

  String? _email(String? value) {
    final requiredError = _required(value);
    if (requiredError != null) return requiredError;
    final email = value!.trim();
    if (!email.contains('@') || !email.contains('.')) {
      return 'Informe um e-mail vÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¡lido';
    }
    return null;
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      _UserUpdateResult(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Alterar conta'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nome'),
              validator: _required,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'E-mail'),
              validator: _email,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _save, child: const Text('Salvar')),
      ],
    );
  }
}
