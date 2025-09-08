# Windows PowerShell 스크립트 - 개발 환경 시작
# 실행 방법: PowerShell에서 .\scripts\start-dev.ps1

Write-Host "🚀 VisitKorea 개발 환경을 시작합니다..." -ForegroundColor Green

# 1. 환경변수 파일 확인 및 생성
$envPath = "apps\backend\.env"
if (!(Test-Path $envPath)) {
    Write-Host "📝 환경변수 파일이 없습니다. 생성합니다..." -ForegroundColor Yellow
    & ".\scripts\setup-env.ps1"
} else {
    Write-Host "✅ 환경변수 파일이 존재합니다." -ForegroundColor Green
}

# 2. Docker 서비스 시작
Write-Host "🐳 Docker 서비스를 시작합니다..." -ForegroundColor Cyan

Write-Host "  - 데이터베이스 시작 중..." -ForegroundColor White
docker compose up -d db

Write-Host "  - 백엔드 이미지 빌드 중..." -ForegroundColor White
docker compose build backend

Write-Host "  - Prisma 클라이언트 생성 중..." -ForegroundColor White
docker compose run --rm backend npx prisma generate --schema packages/db/prisma/schema.prisma

Write-Host "  - 데이터베이스 마이그레이션 실행 중..." -ForegroundColor White
docker compose run --rm backend npx prisma migrate deploy --schema packages/db/prisma/schema.prisma

Write-Host "  - 백엔드 서비스 시작 중..." -ForegroundColor White
docker compose up -d backend

# 3. 서비스 상태 확인
Write-Host ""
Write-Host "🔍 서비스 상태를 확인합니다..." -ForegroundColor Cyan
Start-Sleep -Seconds 3
docker compose ps

Write-Host ""
Write-Host "🎉 개발 환경이 준비되었습니다!" -ForegroundColor Green
Write-Host "📍 Backend API: http://localhost:3002" -ForegroundColor Cyan
Write-Host "📍 Health Check: http://localhost:3002/health" -ForegroundColor Cyan
Write-Host ""
Write-Host "💡 로그 확인: docker compose logs -f backend" -ForegroundColor Yellow

# 최종 알림
Write-Host "✅ 백엔드 및 DB 서비스가 켜져있습니다!" -ForegroundColor Green