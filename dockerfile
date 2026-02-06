FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM node:20-alpine AS runtime
WORKDIR /app

# Копируем собранное + необходимое для работы
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/node_modules ./node_modules

# Создаем папку для данных (кэш SQLite, логи, config.yml)
RUN mkdir -p /app/data

EXPOSE 3000

# Отключаем dotenv явно, используем только нативные env vars Docker
ENV NODE_ENV=production
# Запускаем в SSE режиме (HTTP сервер) через npm script
CMD ["npm", "run", "sse"]
