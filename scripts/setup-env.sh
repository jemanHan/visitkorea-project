#!/bin/bash
# Linux/Mac 스크립트 - 환경변수 파일 생성
# 실행 방법: chmod +x scripts/setup-env.sh && ./scripts/setup-env.sh

echo "VisitKorea 프로젝트 환경변수 파일을 생성합니다..."

# .env 파일 경로
ENV_PATH="apps/backend/.env"

# 디렉토리가 없으면 생성
mkdir -p "$(dirname "$ENV_PATH")"

# .env 파일 생성
cat > "$ENV_PATH" << 'EOF'
# Database
DATABASE_URL="postgresql://vk:vk@db:5432/vk?schema=public"

# Server
PORT=3002
NODE_ENV=development

# Google Places API (필수: 실제 키로 변경하세요)
GOOGLE_PLACES_BACKEND_KEY="your_google_places_api_key_here"

# JWT
JWT_SECRET="your_jwt_secret_here"

# CORS
CORS_ORIGIN="http://localhost:3000"

# Cache TTL (7 days)
DETAIL_TTL_MS=604800000
EOF

echo "✅ 환경변수 파일이 생성되었습니다: $ENV_PATH"
echo "⚠️  Google Places API 키를 실제 키로 변경해주세요!"
echo "   파일 위치: $ENV_PATH"

