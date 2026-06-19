# Copa — Frontend Flutter

Aplicativo do bolão Copa integrado à API NestJS.

## Executar

Com PostgreSQL e backend ativos:

```powershell
flutter pub get
flutter run --dart-define=API_BASE_URL=http://localhost:3000
```

No emulador Android, o valor padrão já usa `http://10.0.2.2:3000`. Para dispositivo físico, informe o IP da máquina:

```powershell
flutter run --dart-define=API_BASE_URL=http://192.168.0.10:3000
```

## Validar

```powershell
dart analyze
flutter test
flutter build web --dart-define=API_BASE_URL=https://api.exemplo.com
```

## Funcionalidades

- login, cadastro, logout e restauração segura da sessão;
- redirecionamento de rotas conforme autenticação;
- feed de partidas com filtros de status;
- criação e edição de palpites até 15 minutos antes do jogo;
- exibição do palpite atual e placar final;
- ranking global com destaque do usuário autenticado;
- estados de carregamento, vazio, erro e atualização manual.
