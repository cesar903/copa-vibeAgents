FROM node:22-bookworm-slim

WORKDIR /app

COPY package.json package-lock.json prisma.config.ts ./
COPY prisma ./prisma

RUN DATABASE_URL=postgresql://postgres:postgres@localhost:5432/postgres npm ci

COPY nest-cli.json tsconfig.json tsconfig.build.json ./
COPY src ./src

RUN npm run build

ENV NODE_ENV=production
EXPOSE 3000

CMD ["sh", "-c", "npm run prisma:migrate:deploy && npm run start:prod"]
