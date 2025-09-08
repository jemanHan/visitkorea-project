# Node.js 20 Alpine 이미지 사용
FROM node:20-alpine

# 작업 디렉토리 설정
WORKDIR /app

# 루트 패키지 파일 복사
COPY package*.json ./
COPY tsconfig.base.json ./

# packages 디렉토리 복사
COPY packages/ ./packages/

# 백엔드 패키지 파일 복사
COPY apps/backend/package*.json ./

# 의존성 설치
RUN npm install

# Prisma 클라이언트 생성
RUN npx prisma generate --schema packages/db/prisma/schema.prisma

# 소스 코드 복사
COPY apps/backend/ .

# 포트 노출
EXPOSE 3002

# 애플리케이션 실행
CMD ["npm", "start"]