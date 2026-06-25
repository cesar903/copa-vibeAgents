# Projeto Copa - TODO List

## Atualização 24/06/2026 - Rodadas pagas

- [x] Adicionar campo `round` nas partidas.
- [x] Criar tabela `RoundPayment` para pagamento por usuário/rodada.
- [x] Criar endpoints admin `GET /round-payments` e `PATCH /round-payments`.
- [x] Fazer ranking ignorar rodadas não pagas pelo usuário.
- [x] Adicionar controle admin de pagamentos por rodada no Flutter.
- [x] Recalcular ranking ao marcar/desmarcar pagamento.

## Atualização 24/06/2026 - Administração de usuários

- [x] Proteger endpoints de usuários com JWT e admin.
- [x] Listar usuários sem expor senha.
- [x] Permitir alteração de nome/e-mail pelo admin.
- [x] Permitir troca de senha pelo admin.
- [x] Permitir exclusão de usuários pelo admin.
- [x] Bloquear exclusão da própria conta admin logada.
- [x] Adicionar painel de usuários no Flutter.

## Atualização 25/06/2026 - Edição manual de partidas

- [x] Listar partidas cadastradas na área administrativa.
- [x] Permitir admin mudar partida para `SCHEDULED`, `LIVE` ou `FINISHED`.
- [x] Permitir admin informar placar ao colocar partida ao vivo/finalizada.
- [x] Recarregar partidas e ranking após salvar edição.
- [x] Exibir palpites de todos os usuários quando a partida estiver `LIVE` ou `FINISHED`.
- [x] Adicionar botão admin para gerar PDF/relatório dos resultados.

## Publicação

- [x] Criar `backend/Dockerfile` e `.dockerignore`.
- [x] Criar Blueprint `render.yaml` para a API.
- [x] Criar configuração do Firebase Hosting para Flutter Web.
- [x] Alterar identificadores Android/iOS para `com.copa.amigos`.
- [x] Atualizar metadados PWA para `Copa Amigos`.
- [x] Validar build web release e APK release.
- [ ] Criar banco PostgreSQL no Neon e configurar `DATABASE_URL`.
- [ ] Criar serviço da API no Render pelo Blueprint.
- [ ] Criar projeto Firebase e publicar `frontend/build/web`.
- [ ] Regerar web e APK com a URL HTTPS real da API.
- [ ] Executar smoke test em iPhone e Android físicos.

## Backend (NestJS + Prisma)

- [x] **Infraestrutura e Qualidade da API**
  - [x] JWT Guards aplicados globalmente com suporte a rotas públicas (`@Public`).
  - [x] Roles Guards (`@Roles`) para controle de acesso (Admin/User).
  - [x] Validation Pipes globais para validação automática de DTOs.
  - [x] Tratamento Global de Exceções para respostas de erro padronizadas.
  - [x] Logs Estruturados para requisições HTTP.
  - [x] Rate Limiting (Throttler) para proteção contra abuso de API.
  - [x] Documentação Swagger (`OpenAPI`) atualizada com segurança e respostas de erro.
- [x] **Autenticação**
  - [x] Register / Login com Bcrypt e geração de JWT.
  - [x] Extração do `CurrentUser` do token JWT.
- [x] **Matches**
  - [x] CRUD de Matches com Prisma (protegido por Role de Admin).
  - [x] Paginação e Filtros por Status, Competição e Data.
  - [x] Testes Unitários.
- [x] **Predictions**
  - [x] CRUD de Predictions.
  - [x] Lógica para impedir palpites limitados a 15 mins antes do jogo.
  - [x] Lógica para impedir visualização de palpites de outros usuários antes do jogo.
- [x] **Ranking**
  - [x] Rotina para calcular pontos e atualizar Ranking global após Match `FINISHED`.
  - [x] Paginação e critérios de desempate.
  - [x] Testes Unitários.
- [x] **Notifications**
  - [x] Endpoints para listar e marcar notificações como lidas.
  - [x] Serviço mock para envio de push notifications (preparado para FCM).
  - [x] Lógica para criação de notificações em eventos.
- [ ] **Users**
  - [ ] CRUD de Users (Perfil).
- [ ] **Auth Avançada**
  - [ ] Implementar fluxo de Refresh Token.

## Frontend (Flutter)

- [x] Setup Base (Dio com Interceptors JWT)
- [x] Setup GetIt
- [x] GoRouter Config com proteção de sessão
- [x] Tela de Login / BLoC
- [x] Tela de Cadastro / BLoC
- [x] Feed de Partidas (Agendadas, Ao Vivo, Finalizadas)
- [x] Modal/Tela de Palpites
- [x] Tabela de Ranking
- [x] Persistência segura do token e restauração de sessão
- [x] Estados de loading, vazio, erro e atualização por pull-to-refresh
- [x] Testes de contratos JWT e partidas
- [x] Build web validado
