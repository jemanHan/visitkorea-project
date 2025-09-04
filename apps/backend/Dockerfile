# Node.js 20 Alpine 이미지 사용
FROM node:20-alpine

# 작업 디렉토리 설정
WORKDIR /app

# 루트 패키지 파일 복사 (workspace 설정용)
COPY package*.json ./
COPY tsconfig.base.json ./

# packages 디렉토리 복사 (shared-types 등 의존성 패키지)
COPY packages/ ./packages/

# 백엔드 패키지 파일 복사
COPY apps/backend/package*.json ./

# 의존성 설치 (개발 의존성 포함)
RUN npm install

# 소스 코드 복사
COPY apps/backend/ .

# 포트 노출
EXPOSE 3002

# 헬스체크 추가
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3002/health || exit 1

# 애플리케이션 실행 (개발 모드)
CMD ["npm", "run", "dev"]
