# Windows PowerShell 스크립트 - 환경변수 파일 생성
# 실행 방법: PowerShell에서 .\scripts\setup-env.ps1

Write-Host "🚀 VisitKorea 프로젝트 환경변수 파일을 생성합니다..." -ForegroundColor Green

# .env 파일 경로
$envPath = "apps\backend\.env"

# 기존 파일이 있으면 백업
if (Test-Path $envPath) {
    $backupPath = "$envPath.backup.$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    Copy-Item $envPath $backupPath
    Write-Host "📁 기존 .env 파일을 백업했습니다: $backupPath" -ForegroundColor Yellow
}

# .env 파일 내용
$envContent = @"
# Database Configuration
DATABASE_URL="postgresql://vk:vk@db:5432/vk?schema=public"

# Server Configuration
PORT=3002
NODE_ENV=development

# Google Places API (⚠️ 필수: 실제 키로 변경하세요!)
GOOGLE_PLACES_BACKEND_KEY="your_google_places_api_key_here"

# JWT Configuration
JWT_SECRET="your_jwt_secret_here_$(Get-Random -Minimum 1000 -Maximum 9999)"

# CORS Configuration
CORS_ORIGIN="http://localhost:3000"

# Cache Configuration (7 days)
DETAIL_TTL_MS=604800000
"@

# 디렉토리가 없으면 생성
$envDir = Split-Path $envPath -Parent
if (!(Test-Path $envDir)) {
    New-Item -ItemType Directory -Path $envDir -Force | Out-Null
    Write-Host "📁 디렉토리를 생성했습니다: $envDir" -ForegroundColor Cyan
}

# .env 파일 생성
Set-Content -Path $envPath -Value $envContent -Encoding UTF8

Write-Host ""
Write-Host "✅ 환경변수 파일이 성공적으로 생성되었습니다!" -ForegroundColor Green
Write-Host "📍 파일 위치: $envPath" -ForegroundColor Cyan
Write-Host ""
Write-Host "⚠️  중요: 다음 설정을 확인하세요:" -ForegroundColor Yellow
Write-Host "   1. GOOGLE_PLACES_BACKEND_KEY를 실제 API 키로 변경" -ForegroundColor White
Write-Host "   2. JWT_SECRET이 안전한지 확인" -ForegroundColor White
Write-Host ""
Write-Host "🔗 Google Places API 키 발급: https://console.cloud.google.com/" -ForegroundColor Blue

