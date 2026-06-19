import 'dart:convert';

class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.userId,
    required this.email,
  });

  final String accessToken;
  final String userId;
  final String email;

  bool get isAdmin => email.toLowerCase() == 'cesarreis521@gmail.com';

  factory AuthSession.fromToken(String accessToken) {
    final parts = accessToken.split('.');
    if (parts.length != 3) {
      throw const FormatException('Token JWT inválido');
    }

    final payload = jsonDecode(
      utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
    );
    if (payload is! Map<String, dynamic>) {
      throw const FormatException('Payload JWT inválido');
    }

    final userId = payload['sub'];
    final email = payload['email'];
    if (userId is! String || email is! String) {
      throw const FormatException('Token sem identificação do usuário');
    }

    return AuthSession(accessToken: accessToken, userId: userId, email: email);
  }
}
