# Auditoria Completa do Backend

**Data:** 18/06/2026  
**Escopo:** `backend/` (NestJS 11, TypeScript 5.9, Prisma 7.8)  
**Natureza:** auditoria somente; nenhum código-fonte, DTO, módulo, provider ou configuração foi corrigido.

## Status após correções — 18/06/2026

Os achados desta auditoria foram tratados em uma etapa posterior. Esta seção preserva o diagnóstico original e registra o estado atual:

- **C-01 resolvido:** `tsconfig.build.json` limita a compilação a `src/**/*.ts`; o build agora gera `dist/main.js`, compatível com `start:prod`.
- **C-02 resolvido:** `PrismaService` usa `@prisma/adapter-pg` e exige `DATABASE_URL` válida.
- **A-01 e A-02 resolvidos:** `ValidationPipe` global foi habilitado com transformação, whitelist e rejeição de campos extras; DTOs de autenticação agora possuem validação.
- **A-03 resolvido:** o `.env` é carregado no runtime e não existe mais fallback JWT fixo; ausência de `JWT_SECRET` interrompe a inicialização explicitamente.
- **M-01 a M-04 resolvidos:** DTOs expostos receberam contratos, UUIDs deixaram de ser convertidos para número, ranking ganhou DTO de paginação e contexto JWT/request foi tipado.
- **M-05 parcialmente resolvido:** dependências diretas obrigatórias foram declaradas e uma instalação limpa funciona. `npm ls --all` ainda acusa peers opcionais WASI de uma dependência transitiva; `npm ls --depth=0 --omit=optional` passa.
- **M-06 resolvido:** migration inicial adicionada em `backend/prisma/migrations/20260618095000_init/`.
- **B-01 e B-02 resolvidos:** lint de produção e testes passa; e2e não depende de banco real para testar a rota raiz e faz teardown seguro.

### Validação pós-correção

| Gate                        | Estado                             |
| --------------------------- | ---------------------------------- |
| TypeScript (`tsc --noEmit`) | Passou                             |
| Build NestJS                | Passou                             |
| ESLint                      | Passou, sem erros ou avisos        |
| Testes unitários            | Passou: 35/35                      |
| Teste e2e                   | Passou: 1/1                        |
| Prisma schema               | Válido                             |
| Entry point de produção     | `dist/main.js` gerado corretamente |

### Riscos residuais

- O PostgreSQL local não estava ativo durante a validação final; conexão real e aplicação da migration permanecem como próximo passo operacional.
- `npm audit --omit=dev` reporta 9 vulnerabilidades transitivas (5 moderadas e 4 altas) sem correção disponível nas versões atuais, principalmente em Prisma tooling, Swagger/js-yaml e Nest platform-express/multer.
- Users e Notifications continuam com services de scaffold; seus contratos foram corrigidos, mas a persistência dessas rotas ainda precisa ser implementada.

## Resumo executivo

O código TypeScript compila e o comando `nest build` termina com sucesso, porém o backend **não pode ser iniciado**. Foram confirmados dois bloqueios críticos independentes:

1. o script de produção procura `dist/main`, mas o build gera `dist/src/main.js`;
2. ao executar o arquivo realmente gerado, o NestJS falha ao construir `PrismaService`, porque o Prisma Client 7 exige `adapter` ou `accelerateUrl` e nenhum deles é fornecido.

Além disso, a aplicação não registra `ValidationPipe`; portanto, os decorators de `class-validator` e as transformações dos DTOs não são aplicados às requisições. O linter encontrou 45 erros e 10 avisos. Os 35 testes unitários passam, mas o teste e2e falha antes de inicializar a aplicação.

### Totais por severidade

| Severidade | Quantidade de achados |
| ---------- | --------------------: |
| CRÍTICO    |                     2 |
| ALTO       |                     3 |
| MÉDIO      |                     6 |
| BAIXO      |                     2 |

## Evidências executadas

| Verificação                                               | Resultado                                                 |
| --------------------------------------------------------- | --------------------------------------------------------- |
| `tsc --noEmit --incremental false -p tsconfig.build.json` | **Passou**, sem erros TypeScript                          |
| `nest build`                                              | **Passou**, mas emitiu o entrypoint em `dist/src/main.js` |
| `node dist/main.js`                                       | **Falhou** com `MODULE_NOT_FOUND`                         |
| `node dist/src/main.js`                                   | **Falhou** com `PrismaClientInitializationError`          |
| `prisma validate`                                         | **Passou**; schema válido                                 |
| Jest unitário                                             | **Passou**: 7 suítes, 35 testes                           |
| Jest e2e                                                  | **Falhou**: 1 suíte, 1 teste                              |
| ESLint sem `--fix`                                        | **Falhou**: 45 erros e 10 avisos                          |
| `npm ls --depth=0 --omit=optional`                        | **Passou**, com um pacote extraneous                      |
| `npm ls --all`                                            | **Falhou** com `ELSPROBLEMS`                              |

## Problemas identificados

### CRÍTICO — C-01: script de produção aponta para um artefato inexistente

**Arquivos:** `backend/package.json:12`, `backend/tsconfig.build.json:1`, `backend/prisma.config.ts:1`

O script `start:prod` executa `node dist/main`, mas o build atual gera `dist/src/main.js`. A configuração TypeScript não limita o build a `src/`; ela inclui também `prisma.config.ts`. Com isso, a raiz comum de emissão passa a ser o diretório do backend e a pasta `src` é preservada dentro de `dist`.

**Impacto:** qualquer implantação que use `npm run start:prod` encerra imediatamente com `MODULE_NOT_FOUND`, antes de o NestJS iniciar.

**Evidência:** `nest build` retornou código 0; a listagem de `dist` contém `dist/src/main.js` e não contém `dist/main.js`; `node dist/main.js` falhou.

### CRÍTICO — C-02: `PrismaService` é incompatível com o Prisma Client 7

**Arquivos:** `backend/src/prisma/prisma.service.ts:5`, `backend/package.json:25`, `backend/package.json:48`

`PrismaService` chama implicitamente `super()` sem opções. No Prisma Client 7.8, `PrismaClientOptions` exige uma das opções mutuamente exclusivas `adapter` ou `accelerateUrl`. O projeto não instancia um adapter e também não declara `@prisma/adapter-pg` entre as dependências.

O `datasource.url` de `prisma.config.ts` configura comandos da CLI, mas não fornece as opções exigidas pelo Prisma Client em runtime.

**Impacto:** o provider global `PrismaService` não pode ser construído. Toda a aplicação NestJS cai durante a resolução de dependências, antes de aceitar requisições.

**Evidência:** tanto o teste e2e quanto `node dist/src/main.js` falharam com `PrismaClientInitializationError: PrismaClient needs to be constructed with a non-empty, valid PrismaClientOptions`.

### ALTO — A-01: validação e transformação global de DTOs não estão habilitadas

**Arquivo:** `backend/src/main.ts:5`

Não existe registro de `ValidationPipe` na inicialização. Em consequência:

- os decorators de `class-validator` em DTOs de partidas e palpites não rejeitam payloads inválidos;
- `@Type(() => Number)` em `MatchQueryDto` não converte query strings;
- opções usuais como `whitelist`, `forbidNonWhitelisted` e `transform` não são aplicadas.

Um caso concreto ocorre em `MatchQueryDto`: `page` e `limit` chegam via HTTP como strings. Operações aritméticas podem coagir parcialmente os valores, mas `take: limit` é encaminhado ao Prisma sem garantia de ser `number`, podendo gerar erro de validação do Prisma em runtime.

**Impacto:** contratos HTTP declarados pelos DTOs não são efetivos e entradas malformadas alcançam services e Prisma.

### ALTO — A-02: DTOs de autenticação não possuem validação

**Arquivo:** `backend/src/auth/dto/auth.dto.ts:3`

`RegisterDto` e `LoginDto` usam apenas `@ApiProperty`, que documenta o Swagger, mas não valida dados. Não há `@IsEmail`, `@IsString`, limites de tamanho, regras de senha ou obrigatoriedade via `class-validator`.

Mesmo que um `ValidationPipe` fosse registrado, esses DTOs continuariam aceitando valores ausentes ou de tipos incorretos.

**Impacto:** entradas inválidas podem chegar a `bcrypt` e Prisma, resultando em erros internos ou dados fora do contrato esperado.

### ALTO — A-03: segredo JWT possui fallback fixo e o `.env` não é carregado pela aplicação

**Arquivos:** `backend/src/auth/auth.module.ts:14`, `backend/src/auth/jwt.strategy.ts:12`, `backend/src/main.ts:1`, `backend/prisma.config.ts:3`

Auth module e strategy usam o fallback literal `super-secret-jwt-key`. Existe uma chave `JWT_SECRET` no arquivo `.env`, porém o runtime NestJS não importa `dotenv/config` nem usa um módulo de configuração. O import de dotenv está somente em `prisma.config.ts`, módulo carregado pela CLI do Prisma e não pelo entrypoint da aplicação.

**Impacto:** se o ambiente do processo não injetar explicitamente `JWT_SECRET`, tokens são assinados e validados com um segredo público e previsível.

### MÉDIO — M-01: DTOs vazios não definem contratos de entrada

**Arquivos:**

- `backend/src/users/dto/create-user.dto.ts:1`
- `backend/src/notifications/dto/create-notification.dto.ts:1`
- `backend/src/auth/dto/create-auth.dto.ts:1`
- `backend/src/ranking/dto/create-ranking.dto.ts:1`

Essas classes estão vazias, e seus respectivos `Update*Dto` derivados também ficam sem campos ou validações. Nos módulos de usuários e notificações, os DTOs vazios são expostos diretamente pelos controllers.

**Impacto:** não há contrato de tipo útil nem validação de payload para essas rotas. Os services correspondentes ainda são scaffolds e ignoram os argumentos recebidos.

### MÉDIO — M-02: IDs UUID são convertidos para `number` em usuários e notificações

**Arquivos:** `backend/src/users/users.controller.ts:29`, `backend/src/notifications/notifications.controller.ts:29`, `backend/prisma/schema.prisma:16`, `backend/prisma/schema.prisma:68`

O schema Prisma define os IDs de `User` e `Notification` como `String @default(uuid())`. Entretanto, os controllers aplicam `+id` e os services tipam os IDs como `number`. Um UUID é convertido para `NaN`.

**Impacto:** a tipagem das camadas HTTP/service contradiz o modelo persistido; a implementação atual de scaffold oculta o erro porque ainda não consulta o Prisma.

### MÉDIO — M-03: paginação do ranking não usa DTO validado

**Arquivos:** `backend/src/ranking/ranking.controller.ts:9`, `backend/src/ranking/ranking.service.ts:111`

A query é tipada apenas com um tipo inline `{ page?: number; limit?: number }`. Tipos TypeScript não transformam dados HTTP. O service usa `Number(...) || default`, mas não impõe inteiros positivos nem limite máximo.

**Impacto:** valores negativos, fracionários ou excessivos podem alcançar `skip` e `take`, provocando erro Prisma ou consultas desnecessariamente grandes.

### MÉDIO — M-04: tipagem insegura no contexto autenticado

**Arquivos:** `backend/src/auth/current-user.decorator.ts:5`, `backend/src/auth/jwt.strategy.ts:16`

O decorator lê um request inferido como `any`, e `JwtStrategy.validate` recebe `payload: any`. O ESLint confirmou cinco erros `no-unsafe-assignment`, `no-unsafe-return` e `no-unsafe-member-access` nesses arquivos.

**Impacto:** o compilador não garante a estrutura do payload JWT nem a presença/tipagem de `request.user`, permitindo falhas silenciosas no contrato de autenticação.

### MÉDIO — M-05: dependências locais apresentam inconsistência e dependência direta ausente

**Arquivos:** `backend/package.json:1`, `backend/prisma.config.ts:3`, `backend/package-lock.json:1`

Há três condições distintas:

1. `@prisma/adapter-pg` não está declarado, embora seja necessário para a estratégia PostgreSQL esperada pelo Prisma Client 7 (parte da causa crítica C-02);
2. `prisma.config.ts` importa `dotenv/config`, mas `dotenv` não é dependência direta; atualmente funciona apenas porque `dotenv` está içado como dependência transitiva de `prisma`;
3. `npm ls --all` retorna `ELSPROBLEMS`: `@emnapi/wasi-threads@1.2.2` está extraneous e faltam `@emnapi/core` e `@emnapi/runtime` requeridos por `@napi-rs/wasm-runtime` na árvore instalada. Com dependências opcionais omitidas, a árvore de pacotes diretos passa.

**Impacto:** a instalação atual não é integralmente consistente/reprodutível e depende de resolução transitiva não declarada.

### MÉDIO — M-06: não existe histórico de migrations Prisma no repositório

**Arquivo:** `backend/prisma/schema.prisma:1`

O schema é válido, mas não existe o diretório `prisma/migrations`, apesar de `prisma.config.ts` configurar esse caminho.

**Impacto:** não há artefato versionado para reproduzir ou evoluir a estrutura do banco por `prisma migrate deploy`. A auditoria não verificou o estado de um banco externo.

### BAIXO — B-01: imports e parâmetros não utilizados quebram o lint

**Arquivos e ocorrências de produção:**

- `backend/src/matches/matches.controller.ts:15`: `ApiQuery` não usado;
- `backend/src/predictions/dto/create-prediction.dto.ts:2`: `IsString` não usado;
- `backend/src/predictions/predictions.service.ts:5`: `ConflictException` não usada;
- `backend/src/prisma/prisma.service.ts:1`: `INestApplication` não usado;
- `backend/src/users/users.service.ts:7` e `:19`: parâmetros DTO não usados;
- `backend/src/notifications/notifications.service.ts:7` e `:19`: parâmetros DTO não usados.

**Impacto:** falha na política atual do ESLint e sinalização de código scaffold/incompleto, sem impedir o `nest build`.

### BAIXO — B-02: testes acumulam violações de lint e o e2e gera erro secundário

**Arquivos:** specs de matches, predictions e ranking; `backend/test/app.e2e-spec.ts:26`

O ESLint reportou 32 ocorrências de `unbound-method` em expectativas Jest e 10 avisos de argumentos `any` nos testes. Além disso, quando o `beforeEach` e2e falha ao construir o Prisma, `afterEach` tenta executar `app.close()` com `app` indefinido, gerando um segundo erro que polui o diagnóstico principal.

**Impacto:** qualidade estática reduzida nos testes e saída e2e menos clara; não é a causa do crash da aplicação.

## Itens auditados sem problema confirmado

### Compilação e TypeScript

- Não há erro de compilação TypeScript no estado atual.
- O import de `User` em `predictions.controller.ts` já usa `import type`; o erro TS1272 descrito no relatório antigo não existe mais.
- O build NestJS termina com código 0. O problema está no layout emitido e no script de execução, descrito em C-01.

### Imports

- Não foram encontrados imports relativos apontando para arquivos inexistentes.
- Não foram encontrados imports de pacotes ausentes que impeçam a compilação atual.
- Os imports inválidos por uso são os imports não utilizados listados em B-01.

### NestJS, módulos, providers e injeção

- Controllers e services estão registrados nos módulos correspondentes.
- `RankingService` é exportado por `RankingModule`, e `MatchesModule` importa esse módulo corretamente.
- `PrismaService` está registrado e exportado por `PrismaModule`, marcado como global.
- `AuthService` e `JwtStrategy` estão registrados em `AuthModule`; `JwtModule` e `PassportModule` estão importados.
- Não foi identificado provider ausente ou token de injeção sem registro na estrutura estática.
- A falha de DI observada não é provider não registrado: ela ocorre dentro do construtor herdado de `PrismaClient` (C-02).

### Prisma

- `prisma validate` confirmou que enums, models, relações, índices e datasource são sintaticamente válidos.
- O client gerado está presente e na mesma versão da CLI (`7.8.0`).
- A auditoria não conectou nem alterou um banco externo e não executou migrations.

## Cobertura e limitações

- Foram revisados todos os arquivos TypeScript de produção em `backend/src`, os DTOs, módulos, controllers, services, schema/configuração Prisma, manifests e testes.
- Nenhuma correção, refatoração, funcionalidade ou alteração arquitetural foi aplicada.
- O diretório `dist` foi regenerado pelo comando de build para verificar a compilação; ele é artefato de build, não código-fonte.
- O estado real do PostgreSQL não foi auditado porque o backend falha antes da conexão e não há migrations versionadas para comparação.
