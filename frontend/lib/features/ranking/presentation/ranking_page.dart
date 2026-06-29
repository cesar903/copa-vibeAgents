import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/account_menu.dart';
import '../../auth/presentation/auth_cubit.dart';
import '../domain/ranking_entry.dart';
import 'ranking_cubit.dart';

class RankingPage extends StatefulWidget {
  const RankingPage({super.key});

  @override
  State<RankingPage> createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> {
  @override
  void initState() {
    super.initState();
    if (context.read<RankingCubit>().state.status == RankingStatus.initial) {
      context.read<RankingCubit>().load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = context.select(
      (AuthCubit cubit) => cubit.state.session?.userId,
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ranking'),
        actions: [
          IconButton(
            tooltip: 'Regras de pontuacao',
            onPressed: () => _showRankingRules(context),
            icon: const Icon(Icons.help_outline),
          ),
          IconButton(
            tooltip: 'Atualizar',
            onPressed: () => context.read<RankingCubit>().load(),
            icon: const Icon(Icons.refresh),
          ),
          const AccountMenu(),
        ],
      ),
      body: BlocBuilder<RankingCubit, RankingState>(
        builder: (context, state) {
          if (state.status == RankingStatus.loading && state.entries.isEmpty) {
            return const AppLoadingView();
          }
          if (state.status == RankingStatus.failure && state.entries.isEmpty) {
            return AppMessageView(
              icon: Icons.leaderboard_outlined,
              title: 'Ranking indisponível',
              message: state.errorMessage ?? 'Tente novamente.',
              onAction: () => context.read<RankingCubit>().load(),
            );
          }
          if (state.entries.isEmpty) {
            return const AppMessageView(
              icon: Icons.emoji_events_outlined,
              title: 'Ranking vazio',
              message: 'As posições aparecerão após os primeiros resultados.',
            );
          }
          return RefreshIndicator(
            onRefresh: context.read<RankingCubit>().load,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
              itemCount: state.entries.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final entry = state.entries[index];
                return _RankingTile(
                  entry: entry,
                  isCurrentUser: entry.userId == currentUserId,
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _showRankingRules(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Regras do ranking'),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _RuleLine(text: 'Placar exato: 10 pontos.'),
                _RuleLine(text: 'Resultado correto: 5 pontos.'),
                _RuleLine(text: 'Gols do mandante corretos: 2 pontos.'),
                _RuleLine(text: 'Gols do visitante corretos: 2 pontos.'),
                _RuleLine(
                  text:
                      'Partidas que valem dinheiro so contam para quem pagou a rodada.',
                ),
                _RuleLine(
                  text:
                      'Partidas sem grana contam para todos os usuarios com palpite.',
                ),
                _RuleLine(
                  text:
                      'O ranking e acumulativo e soma todos os jogos finalizados.',
                ),
                _RuleLine(
                  text:
                      'Desempate: pontos, placares exatos, resultados corretos e ordem de cadastro.',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }
}

class _RuleLine extends StatelessWidget {
  const _RuleLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 18,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _RankingTile extends StatelessWidget {
  const _RankingTile({required this.entry, required this.isCurrentUser});

  final RankingEntry entry;
  final bool isCurrentUser;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isCurrentUser
          ? Theme.of(context).colorScheme.primaryContainer
          : null,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            SizedBox(
              width: 34,
              child: Text(
                entry.position > 0 ? '${entry.position}º' : '—',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
            ),
            _Avatar(user: entry.user),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isCurrentUser
                        ? '${entry.user.name} (você)'
                        : entry.user.name,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${entry.exactScores} exatos • ${entry.correctWinners} resultados',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${entry.points}',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                const Text('pontos', style: TextStyle(fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.user});

  final RankingUser user;

  @override
  Widget build(BuildContext context) {
    final avatar = user.avatar;
    if (avatar != null && avatar.isNotEmpty) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: avatar,
          width: 42,
          height: 42,
          fit: BoxFit.cover,
          errorWidget: (_, _, _) => _InitialAvatar(name: user.name),
        ),
      );
    }
    return _InitialAvatar(name: user.name);
  }
}

class _InitialAvatar extends StatelessWidget {
  const _InitialAvatar({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 21,
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      child: Text(
        name.isEmpty ? '?' : name.characters.first.toUpperCase(),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
