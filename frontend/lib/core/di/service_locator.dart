import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/presentation/auth_cubit.dart';
import '../../features/matches/data/matches_repository.dart';
import '../../features/matches/presentation/matches_cubit.dart';
import '../../features/predictions/data/predictions_repository.dart';
import '../../features/predictions/presentation/predictions_cubit.dart';
import '../../features/ranking/data/ranking_repository.dart';
import '../../features/ranking/presentation/ranking_cubit.dart';
import '../network/api_client.dart';
import '../router/app_router.dart';
import '../storage/token_storage.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  getIt.registerLazySingleton(() => const FlutterSecureStorage());
  getIt.registerLazySingleton(() => TokenStorage(getIt()));
  getIt.registerLazySingleton(() => ApiClient(getIt()));

  getIt.registerLazySingleton(() => AuthRepository(getIt(), getIt()));
  getIt.registerLazySingleton(() => MatchesRepository(getIt()));
  getIt.registerLazySingleton(() => PredictionsRepository(getIt()));
  getIt.registerLazySingleton(() => RankingRepository(getIt()));

  final authCubit = AuthCubit(getIt());
  getIt.registerSingleton(authCubit);
  getIt<ApiClient>().onUnauthorized = authCubit.expireSession;
  getIt.registerLazySingleton(() => MatchesCubit(getIt()));
  getIt.registerLazySingleton(() => PredictionsCubit(getIt()));
  getIt.registerLazySingleton(() => RankingCubit(getIt()));

  await authCubit.restore();
  final refreshNotifier = AuthRefreshNotifier(authCubit);
  getIt.registerSingleton(refreshNotifier);
  getIt.registerSingleton<GoRouter>(
    createAppRouter(authCubit, refreshNotifier, getIt<MatchesRepository>()),
  );
}
