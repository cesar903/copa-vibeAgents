# AI Handoff — Projeto Copa

Atualizado em 18/06/2026 após a correção da auditoria do backend.

## Visão geral

O projeto Copa é um bolão de futebol em monorepo:

- `backend/`: API REST NestJS 11, Prisma 7.8 e PostgreSQL.
- `frontend/`: aplicativo Flutter.
- `docs/`: estado técnico, auditorias e handoff.

## Estado atual do backend

O backend compila, passa no lint e possui testes unitários/e2e verdes. Os bloqueios de inicialização identificados em `BACKEND_AUDIT.md` foram corrigidos.

## Estado atual do frontend

O frontend Flutter está implementado para todo o escopo definido no checklist:

- autenticação por login/cadastro, armazenamento seguro e restauração do JWT;
- Dio com Bearer interceptor e encerramento da sessão em HTTP 401;
- GetIt para composição de dependências;
- GoRouter com rotas protegidas;
- Cubits para auth, partidas, palpites e ranking;
- feed com filtros `SCHEDULED`, `LIVE` e `FINISHED`;
- criação/edição de palpites e exibição do palpite existente;
- ranking global com destaque do usuário atual;
- análise Dart limpa, 4 testes aprovados e build web aprovado.

A URL da API é configurada com `--dart-define=API_BASE_URL=...`. Sem definição, web/iOS/desktop usam `localhost:3000` e Android Emulator usa `10.0.2.2:3000`.

### Infraestrutura corrigida

- O build compila apenas `src/**/*.ts` e gera `dist/main.js`.
- Prisma Client 7 usa `@prisma/adapter-pg` em `PrismaService`.
- `dotenv` é dependência direta e o runtime carrega `.env`.
- `DATABASE_URL` e `JWT_SECRET` são obrigatórias; não há segredo JWT padrão.
- `prisma generate` roda automaticamente após `npm install`/`npm ci`.
- Existe uma migration inicial versionada em `backend/prisma/migrations/20260618095000_init/`.
- Um `.env.example` documenta as variáveis necessárias sem armazenar segredos reais.

### Validação HTTP e tipagem

- `ValidationPipe` global usa `transform`, `whitelist` e `forbidNonWhitelisted`.
- DTOs de autenticação, usuários e notificações possuem validações.
- Paginação de partidas e ranking é transformada e validada.
- IDs de usuários e notificações permanecem UUID/string em todas as camadas.
- Payload JWT e `CurrentUser` não usam mais `any`.

### Módulos funcionais

- **Auth:** registro, login, bcrypt, JWT strategy, guard e `CurrentUser`.
- **Matches:** CRUD, filtros e paginação; atualização de partida finalizada dispara recálculo do ranking.
- **Predictions:** criação/upsert, consulta, edição e remoção protegidas por JWT e limite de horário.
- **Ranking:** cálculo de pontos, atualização de posições e leitura paginada.
- **Prisma:** schema válido, adapter PostgreSQL e migration inicial.

### Módulos ainda scaffold

- **Users:** controller e DTOs existem, mas o service ainda retorna strings e não persiste dados.
- **Notifications:** controller e DTOs existem, mas o service ainda retorna strings e não persiste dados.
- **RefreshToken:** entidade Prisma existe, mas o fluxo de autenticação ainda entrega somente access token.

## Comandos do backend

Executar dentro de `backend/`:

```powershell
npm ci
docker compose -f ..\docker-compose.yml up -d db
npm run prisma:migrate:deploy
npm run build
npm run lint
npm test -- --runInBand
npm run test:e2e -- --runInBand
npm run start:dev
```

Para produção:

```powershell
npm run build
npm run start:prod
```

## Gates verificados

- TypeScript: passou sem emissão.
- Build NestJS: passou e gerou `dist/main.js`.
- ESLint: passou sem erros ou avisos.
- Testes unitários: 7 suítes, 35 testes aprovados.
- E2E: 1 suíte, 1 teste aprovado com Prisma mockado.
- Prisma schema: válido.
- Dependências diretas sem opcionais: árvore válida.

## Riscos conhecidos

- A conexão real com PostgreSQL não foi validada porque a porta local `5432` estava indisponível.
- `npm audit --omit=dev` registra 9 vulnerabilidades transitivas sem correção disponível: 5 moderadas e 4 altas.
- `npm ls --all` acusa peers opcionais WASI ausentes em uma dependência transitiva; isso não afeta o runtime Windows atual e `npm ls --depth=0 --omit=optional` passa.
- O e2e atual comprova bootstrap HTTP com Prisma substituído; ainda faltam testes de integração com PostgreSQL real.

## Próximos passos recomendados

1. Subir PostgreSQL e executar `npm run prisma:migrate:deploy`.
2. Fazer smoke test real de registro, login, partidas, palpites e ranking contra o banco.
3. Implementar persistência e autorização dos módulos Users e Notifications.
4. Proteger rotas administrativas de Matches e impedir que clientes criem notificações para outros usuários.
5. Implementar refresh token com rotação, revogação e testes.
6. Adicionar testes de integração com banco isolado no pipeline.
7. Monitorar releases de Prisma, NestJS, Swagger e Multer para resolver os advisories transitivos.
8. Executar smoke test do frontend contra PostgreSQL real e popular partidas de teste.

## Referências internas

- `docs/BACKEND_AUDIT.md`: diagnóstico original e status das correções.
- `backend/.env.example`: variáveis obrigatórias.
- `backend/prisma/schema.prisma`: modelo de dados.
- `backend/prisma/migrations/20260618095000_init/migration.sql`: baseline do banco.
- `docs/DEPLOYMENT.md`: publicação gratuita no Neon, Render e Firebase.
- `render.yaml`: Blueprint da API no Render.
- `frontend/firebase.json`: configuração do Flutter Web no Firebase Hosting.
