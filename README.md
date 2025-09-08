# VisitKorea 프로젝트

## ⚠️ 중요: 환경변수 파일 생성 필수!

프로젝트를 클론한 후 **반드시** `apps/backend/.env` 파일을 생성해야 합니다.

## 🚀 시작하기

```bash
# 1. 프로젝트 클론
git clone https://github.com/jemanHan/visitkorea-project-was.git
cd visitkorea-project-was

# 2. 의존성 설치
npm install

# 3. 환경변수 설정
# Linux (EC2): ./scripts/setup-env.sh
# Windows: cmd.exe /c "powershell -ExecutionPolicy Bypass -File scripts\setup-env.ps1"

# 4. Docker 환경 시작
docker compose up -d db
docker compose run --rm backend npx prisma generate --schema packages/db/prisma/schema.prisma
docker compose run --rm backend npx prisma migrate deploy --schema packages/db/prisma/schema.prisma
docker compose up -d backend
```

## 🔑 Google Places API 키 설정

`apps/backend/.env` 파일의 `GOOGLE_PLACES_BACKEND_KEY` 값을 실제 API 키로 변경하세요.

## 🌐 서비스 확인

- **Backend API**: http://localhost:3002
- **Health Check**: http://localhost:3002/health

## ❓ 문제 해결

- **Prisma 오류**: `docker compose run --rm backend npx prisma generate --schema packages/db/prisma/schema.prisma`
- **환경변수 오류**: 위의 환경변수 설정 단계 실행
- **Docker 충돌**: `docker compose down --volumes --rmi all` 후 재시작