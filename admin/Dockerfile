FROM node:20-slim

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build

ENV PORT=3500
EXPOSE 3500

CMD ["sh", "-c", "npx next start -H 0.0.0.0 -p ${PORT}"]
