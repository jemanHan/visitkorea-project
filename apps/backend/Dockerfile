# apps/backend/Dockerfile
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
# Prisma가 있다면 generate는 컨테이너 시작 전 compose에서 수행 가능
RUN npm run build
EXPOSE 3002
CMD ["npm", "run", "start"]