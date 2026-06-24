import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/widgets/account_menu.dart';
import '../data/matches_repository.dart';
import '../domain/match_model.dart';
import '../../ranking/presentation/ranking_cubit.dart';
import 'matches_cubit.dart';

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
    if (value == null || value.trim().isEmpty) return 'Campo obrigatório';
    return null;
  }

  String? _validRound(String? value) {
    final round = int.tryParse(value ?? '');
    if (round == null || round < 1) return 'Informe uma rodada válida';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final showScores = _status != MatchStatus.scheduled;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administração'),
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
                            labelText: 'Competição',
                          ),
                          validator: _required,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _stadiumController,
                          decoration: const InputDecoration(
                            labelText: 'Estádio',
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
                                'Usuários sem pagamento nesta rodada não pontuam.',
                          ),
                          validator: _validRound,
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: _selectDateTime,
                          icon: const Icon(Icons.event_outlined),
                          label: Text(
                            DateFormat(
                              'dd/MM/yyyy • HH:mm',
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
                  _RoundPaymentsPanel(repository: widget.repository),
                ],
              ),
            ),
          ),
        ),
      ),
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
              'Marque quem pagou. Se não pagou, os jogos dessa rodada não entram no ranking do usuário.',
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
              const Text('Nenhum usuário encontrado.')
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
