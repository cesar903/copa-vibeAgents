import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/auth/domain/auth_session.dart';

void main() {
  test('identifies only the configured administrator email', () {
    expect(_sessionFor('cesarreis521@gmail.com').isAdmin, isTrue);
    expect(_sessionFor('usuario@exemplo.com').isAdmin, isFalse);
  });
}

AuthSession _sessionFor(String email) {
  final payload = base64Url.encode(
    utf8.encode(jsonEncode({'sub': 'user-id', 'email': email})),
  );
  return AuthSession.fromToken('header.$payload.signature');
}
