#!/bin/bash
# Linux/Mac 스크립트 - 환경변수 파일 생성
# 실행 방법: chmod +x scripts/setup-env.sh && ./scripts/setup-env.sh

echo "🚀 VisitKorea 프로젝트 환경변수 파일을 생성합니다..."

# .env 파일 경로
ENV_PATH="apps/backend/.env"

# 기존 파일이 있으면 백업
if [ -f "$ENV_PATH" ]; then
    BACKUP_PATH="${ENV_PATH}.backup.$(date +%Y%m%d-%H%M%S)"
    cp "$ENV_PATH" "$BACKUP_PATH"
    echo "📁 기존 .env 파일을 백업했습니다: $BACKUP_PATH"
fi

# 디렉토리가 없으면 생성
mkdir -p "$(dirname "$ENV_PATH")"

# 랜덤 JWT 시크릿 생성
JWT_SECRET="jwt_secret_$(shuf -i 1000-9999 -n 1)_$(date +%s)"

# .env 파일 생성
cat > "$ENV_PATH" << EOF
# Database Configuration
DATABASE_URL="postgresql://vk:vk@db:5432/vk?schema=public"

# Server Configuration
PORT=3002
NODE_ENV=development

# Google Places API (⚠️ 필수: 실제 키로 변경하세요!)
GOOGLE_PLACES_BACKEND_KEY="your_google_places_api_key_here"

# JWT Configuration
JWT_SECRET="$JWT_SECRET"

# CORS Configuration
CORS_ORIGIN="http://localhost:3000"

# Cache Configuration (7 days)
DETAIL_TTL_MS=604800000
EOF

echo ""
echo "✅ 환경변수 파일이 성공적으로 생성되었습니다!"
echo "📍 파일 위치: $ENV_PATH"
echo ""
echo "⚠️  중요: 다음 설정을 확인하세요:"
echo "   1. GOOGLE_PLACES_BACKEND_KEY를 실제 API 키로 변경"
echo "   2. JWT_SECRET이 안전한지 확인"
echo ""
echo "🔗 Google Places API 키 발급: https://console.cloud.google.com/"

