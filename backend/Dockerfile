FROM node:20-slim

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build

EXPOSE 6000

# Run migrations then start server
CMD npx tsx migrate.ts && npm start
