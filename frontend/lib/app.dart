import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'core/di/service_locator.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/auth_cubit.dart';
import 'features/matches/presentation/matches_cubit.dart';
import 'features/predictions/presentation/predictions_cubit.dart';
import 'features/ranking/presentation/ranking_cubit.dart';

class CopaApp extends StatelessWidget {
  const CopaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: getIt<AuthCubit>()),
        BlocProvider.value(value: getIt<MatchesCubit>()),
        BlocProvider.value(value: getIt<PredictionsCubit>()),
        BlocProvider.value(value: getIt<RankingCubit>()),
      ],
      child: const _AppView(),
    );
  }
}

class _AppView extends StatelessWidget {
  const _AppView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (previous, current) =>
          previous.status != current.status &&
          current.status == AuthStatus.unauthenticated,
      listener: (context, state) {
        context.read<MatchesCubit>().reset();
        context.read<PredictionsCubit>().reset();
        context.read<RankingCubit>().reset();
      },
      child: MaterialApp.router(
        title: 'Copa',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: getIt<GoRouter>(),
      ),
    );
  }
}
