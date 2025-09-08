# apps/backend/Dockerfile
FROM node:20-alpine
WORKDIR /app

# 루트 package.json과 workspace 설정 복사
COPY package*.json ./
COPY tsconfig.base.json ./

# packages 디렉토리 복사 (모노레포 의존성)
COPY packages/ ./packages/

# apps/backend의 package.json 복사
COPY apps/backend/package*.json ./apps/backend/

# 전체 프로젝트 의존성 설치
RUN npm install

# apps/backend 소스 코드 복사
COPY apps/backend/ ./apps/backend/

# 백엔드 빌드
WORKDIR /app/apps/backend
RUN npm run build

EXPOSE 3002
CMD ["npm", "run", "start"]