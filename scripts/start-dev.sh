#!/bin/bash
# Linux/Mac 스크립트 - 개발 환경 시작
# 실행 방법: chmod +x scripts/start-dev.sh && ./scripts/start-dev.sh

echo "🚀 VisitKorea 개발 환경을 시작합니다..."

# 1. 환경변수 파일 확인 및 생성
ENV_PATH="apps/backend/.env"
if [ ! -f "$ENV_PATH" ]; then
    echo "📝 환경변수 파일이 없습니다. 생성합니다..."
    ./scripts/setup-env.sh
else
    echo "✅ 환경변수 파일이 존재합니다."
fi

# 2. Docker 서비스 시작
echo "🐳 Docker 서비스를 시작합니다..."

echo "  - 데이터베이스 시작 중..."
docker compose up -d db

echo "  - 백엔드 이미지 빌드 중..."
docker compose build backend

echo "  - Prisma 클라이언트 생성 중..."
docker compose run --rm backend npx prisma generate --schema packages/db/prisma/schema.prisma

echo "  - 데이터베이스 마이그레이션 실행 중..."
docker compose run --rm backend npx prisma migrate deploy --schema packages/db/prisma/schema.prisma

echo "  - 백엔드 서비스 시작 중..."
docker compose up -d backend

# 3. 서비스 상태 확인
echo ""
echo "🔍 서비스 상태를 확인합니다..."
sleep 3
docker compose ps

echo ""
echo "🎉 개발 환경이 준비되었습니다!"
echo "📍 Backend API: http://localhost:3002"
echo "📍 Health Check: http://localhost:3002/health"
echo ""
echo "💡 로그 확인: docker compose logs -f backend"
