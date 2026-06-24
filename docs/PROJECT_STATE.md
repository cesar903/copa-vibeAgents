# Estado do Projeto Copa

Atualizado em 24/06/2026.

## Atualização de rodadas pagas

- Partidas agora possuem campo `round` para identificar a rodada.
- O backend possui `RoundPayment`, controlado por `GET /round-payments` e `PATCH /round-payments`, protegido para administrador.
- O ranking só considera palpites de partidas finalizadas quando o usuário está marcado como pago naquela rodada.
- A tela administrativa permite cadastrar a rodada da partida e marcar/desmarcar usuários pagos por rodada.
- Backend validado em 24/06/2026 com `npm.cmd run build` e `npm.cmd test -- --runInBand`.
- Validação Flutter local ficou pendente porque os comandos Dart/Flutter permaneceram presos sem saída no ambiente atual.

## Arquitetura

- **Backend:** NestJS 11, Prisma 7.8, PostgreSQL, JWT e Swagger.
- **Frontend:** Flutter 3.38 / Dart 3.10, Cubit/BLoC, GetIt, GoRouter, Dio e Flutter Secure Storage.
- **Infraestrutura local:** PostgreSQL via `docker-compose.yml`.

## Backend

Funcionalidades consumidas pelo aplicativo:

- `POST /auth/register` e `POST /auth/login`;
- `GET /matches` com paginação e filtro por status;
- `GET /predictions` e `POST /predictions` com JWT;
- `GET /ranking` com paginação.

O Prisma usa adapter PostgreSQL e possui migration inicial versionada. Build, lint, testes unitários e e2e estão verdes. Users e Notifications continuam com services scaffold; refresh token ainda não foi implementado.

## Frontend

O aplicativo deixou o estado inicial e agora possui uma jornada funcional completa para o escopo definido:

- sessão JWT persistida em armazenamento seguro;
- interceptor Dio com Bearer token e expiração automática em HTTP 401;
- login e cadastro com validação e feedback de erros;
- GoRouter com proteção e redirecionamento por autenticação;
- feed de partidas filtrável por agendada, ao vivo e finalizada;
- formulário de palpites integrado ao endpoint de upsert;
- sincronização dos palpites do usuário;
- ranking global com destaque da conta autenticada;
- layout responsivo para mobile e web;
- estados de carregamento, vazio, erro e pull-to-refresh.

## Validação atual

- `dart analyze`: sem problemas.
- Testes Flutter: 4 aprovados.
- Build web: aprovado.
- Backend necessário para uso real: PostgreSQL deve estar ativo e migrado.

## Configuração

Backend:

```powershell
cd backend
npm ci
docker compose -f ..\docker-compose.yml up -d db
npm run prisma:migrate:deploy
npm run start:dev
```

Frontend:

```powershell
cd frontend
flutter pub get
flutter run --dart-define=API_BASE_URL=http://localhost:3000
```

O Android Emulator usa `http://10.0.2.2:3000` por padrão. Dispositivos físicos devem receber o IP local da máquina via `API_BASE_URL`.

## Próximos passos

1. Executar smoke test com PostgreSQL real e dados de partidas.
2. Adicionar testes de integração contra uma API dedicada para testes.
3. Implementar refresh token no backend e renovação silenciosa no app.
4. Finalizar persistência de Users e Notifications antes de criar essas telas.
5. Configurar URL HTTPS de produção e remover cleartext HTTP da variante release Android.

## Preparação para publicação

- Blueprint do Render disponível em `render.yaml`.
- Imagem do backend disponível em `backend/Dockerfile`.
- Firebase Hosting configurado em `frontend/firebase.json`.
- Identificadores Android e iOS definidos como `com.copa.amigos`.
- Metadados web/PWA definidos como `Copa Amigos`.
- Guia operacional disponível em `docs/DEPLOYMENT.md`.
- Build web release validado.
- APK release validado para distribuição privada.

Os artefatos locais foram gerados com `https://copa-api.example.com` apenas para validar a compilação. Antes da distribuição, devem ser regenerados usando a URL HTTPS real fornecida pelo Render.
