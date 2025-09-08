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

# Prisma 스키마를 백엔드 디렉토리로 복사 (Prisma 명령어 실행을 위해)
RUN cp /app/packages/db/prisma/schema.prisma ./schema.prisma

# Prisma 스키마를 기본 위치에도 복사 (Prisma가 자동으로 찾을 수 있도록)
RUN mkdir -p ./prisma && cp /app/packages/db/prisma/schema.prisma ./prisma/schema.prisma

EXPOSE 3002
CMD ["npm", "run", "start"]