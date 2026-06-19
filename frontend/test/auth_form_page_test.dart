import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/auth/data/auth_repository.dart';
import 'package:frontend/features/auth/domain/auth_session.dart';
import 'package:frontend/features/auth/presentation/auth_cubit.dart';
import 'package:frontend/features/auth/presentation/auth_form_page.dart';

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<AuthSession> login({required String email, required String password}) {
    throw UnimplementedError();
  }

  @override
  Future<void> logout() async {}

  @override
  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<AuthSession?> restoreSession() async => null;
}

void main() {
  testWidgets('login form does not overflow on a narrow viewport', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(150, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      BlocProvider(
        create: (_) => AuthCubit(_FakeAuthRepository()),
        child: const MaterialApp(home: AuthFormPage.login()),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.byIcon(Icons.sports_soccer), findsOneWidget);
  });
}
