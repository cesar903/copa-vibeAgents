# Publicação gratuita

Este projeto está preparado para o seguinte cenário:

- PostgreSQL gratuito no Neon;
- API NestJS gratuita no Render;
- Flutter Web gratuito no Firebase Hosting;
- APK Android distribuído diretamente.

Os limites dos planos gratuitos podem mudar. Confirme o plano selecionado antes de concluir o cadastro em cada serviço.

## 1. Repositório

Envie o projeto para um repositório no GitHub. Nunca envie `backend/.env`.

## 2. Banco PostgreSQL

1. Crie um projeto no Neon.
2. Copie a connection string PostgreSQL com `sslmode=require`.
3. Guarde essa URL para a variável `DATABASE_URL` do Render.

## 3. Backend no Render

O arquivo `render.yaml` permite criar o serviço por Blueprint.

1. No Render, selecione **New > Blueprint**.
2. Conecte o repositório.
3. Informe `DATABASE_URL` com a URL do Neon.
4. Informe temporariamente `CORS_ORIGIN` com `https://localhost.invalid`.
5. Conclua o deploy e copie a URL HTTPS da API.
6. Confirme que a raiz da API retorna `Hello World!`.

O deploy executa automaticamente:

```text
npm ci && npm run build
npm run prisma:migrate:deploy && npm run start:prod
```

## 4. Flutter Web

Dentro de `frontend/`, substitua a URL pelo endereço real do Render:

```powershell
flutter pub get
flutter build web --release --dart-define=API_BASE_URL=https://copa-api.onrender.com
```

Instale e configure o Firebase CLI:

```powershell
npm install -g firebase-tools
firebase login
firebase use --add
firebase deploy --only hosting
```

O arquivo `firebase.json` publica `build/web` e redireciona as rotas para o Flutter.

Depois do primeiro deploy, copie a URL `https://SEU-PROJETO.web.app` e atualize `CORS_ORIGIN` no Render. Faça um novo deploy do backend ou reinicie o serviço.

## 5. APK Android

O identificador do aplicativo é `com.copa.amigos`.

```powershell
cd frontend
flutter build apk --release --dart-define=API_BASE_URL=https://copa-api.onrender.com
```

O APK será criado em:

```text
frontend/build/app/outputs/flutter-apk/app-release.apk
```

A configuração atual assina o APK com a chave de desenvolvimento da máquina. Isso é suficiente para distribuição privada, mas a mesma chave deve ser preservada para instalar futuras atualizações sobre o aplicativo existente.

## 6. Validação

1. Abra a URL web em uma janela anônima.
2. Cadastre primeiro `cesarreis521@gmail.com` para reservar o administrador.
3. Entre como administrador e cadastre uma partida.
4. Cadastre um usuário comum e envie um palpite.
5. Teste a URL pelo Safari de um iPhone usando rede móvel.
6. Instale o APK em um Android e valide login, partidas, palpites e ranking.
7. No iPhone, use **Compartilhar > Adicionar à Tela de Início**.

## Atualizações futuras

Para atualizar o backend, envie as alterações ao GitHub. O Render está configurado com deploy automático.

Para atualizar web e APK:

```powershell
flutter build web --release --dart-define=API_BASE_URL=https://SUA-API
firebase deploy --only hosting
flutter build apk --release --dart-define=API_BASE_URL=https://SUA-API
```
