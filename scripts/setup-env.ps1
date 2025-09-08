# Windows PowerShell 스크립트 - 환경변수 파일 생성
# 실행 방법: PowerShell에서 .\scripts\setup-env.ps1

Write-Host "VisitKorea 프로젝트 환경변수 파일을 생성합니다..." -ForegroundColor Green

# .env 파일 경로
$envPath = "apps\backend\.env"

# .env 파일 내용
$envContent = @"
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
"@

# 디렉토리가 없으면 생성
$envDir = Split-Path $envPath -Parent
if (!(Test-Path $envDir)) {
    New-Item -ItemType Directory -Path $envDir -Force
}

# .env 파일 생성
Set-Content -Path $envPath -Value $envContent -Encoding UTF8

Write-Host "✅ 환경변수 파일이 생성되었습니다: $envPath" -ForegroundColor Green
Write-Host "⚠️  Google Places API 키를 실제 키로 변경해주세요!" -ForegroundColor Yellow
Write-Host "   파일 위치: $envPath" -ForegroundColor Cyan

