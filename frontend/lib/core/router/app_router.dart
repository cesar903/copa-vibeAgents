import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/auth_cubit.dart';
import '../../features/auth/presentation/auth_form_page.dart';
import '../../features/matches/presentation/matches_page.dart';
import '../../features/matches/presentation/match_admin_page.dart';
import '../../features/matches/data/matches_repository.dart';
import '../../features/ranking/presentation/ranking_page.dart';
import 'app_shell.dart';

class AuthRefreshNotifier extends ChangeNotifier {
  AuthRefreshNotifier(AuthCubit authCubit) {
    _subscription = authCubit.stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

GoRouter createAppRouter(
  AuthCubit authCubit,
  AuthRefreshNotifier refreshNotifier,
  MatchesRepository matchesRepository,
) {
  return GoRouter(
    initialLocation: '/matches',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final status = authCubit.state.status;
      final isAuthRoute =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';
      final isAdminRoute = state.matchedLocation.startsWith('/admin');

      if (status == AuthStatus.loading) return '/splash';
      if (status == AuthStatus.unauthenticated) {
        return isAuthRoute ? null : '/login';
      }
      if (isAdminRoute && !(authCubit.state.session?.isAdmin ?? false)) {
        return '/matches';
      }
      if (isAuthRoute || state.matchedLocation == '/splash') return '/matches';
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (_, _) =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      GoRoute(path: '/login', builder: (_, _) => const AuthFormPage.login()),
      GoRoute(
        path: '/register',
        builder: (_, _) => const AuthFormPage.register(),
      ),
      ShellRoute(
        builder: (_, _, child) => AppShell(child: child),
        routes: [
          GoRoute(path: '/matches', builder: (_, _) => const MatchesPage()),
          GoRoute(path: '/ranking', builder: (_, _) => const RankingPage()),
          GoRoute(
            path: '/admin/matches',
            builder: (_, _) => MatchAdminPage(repository: matchesRepository),
          ),
        ],
      ),
    ],
  );
}
