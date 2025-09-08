# VisitKorea 프로젝트

## 👥 팀원들을 위한 시작 가이드

### **🚀 EC2와 동일한 환경으로 시작 (권장)**

```bash
# 1. 프로젝트 클론
git clone https://github.com/jemanHan/visitkorea-project-was.git
cd visitkorea-project-was

# 2. 의존성 설치
npm install

# 3. 환경변수 설정 (이미 준비됨)
# apps/backend/.env 파일이 이미 설정되어 있습니다
# 필요시 Google Places API 키만 수정하세요

# 4. 🔥 중요: 기존 Docker 환경 정리 (충돌 방지)
docker compose down --volumes --rmi all
docker system prune -f

# 5. Docker로 전체 환경 시작
# 1) DB 먼저
docker compose up -d db

# 2) Prisma 준비
docker compose run --rm backend npx prisma generate
docker compose run --rm backend npx prisma migrate deploy

# 3) 앱 띄우기
docker compose up -d backend
docker compose --profile dev up -d prisma-studio
```

### **🔑 Google Places API 키 발급 방법**
1. [Google Cloud Console](https://console.cloud.google.com/) 접속
2. 프로젝트 생성 또는 선택
3. "APIs & Services" → "Credentials" 이동
4. "Create Credentials" → "API Key" 선택
5. 발급된 키를 `GOOGLE_PLACES_BACKEND_KEY`에 입력

### **🌐 서비스 확인**
- **Backend API**: http://localhost:3002
- **Health Check**: http://localhost:3002/health
- **Prisma Studio**: http://localhost:5555 (개발 모드)

### **📋 자주 사용하는 명령어**
- `docker compose up -d db` - PostgreSQL 시작
- `docker compose up -d backend` - 백엔드 시작
- `docker compose --profile dev up -d prisma-studio` - Prisma Studio 시작
- `docker compose down` - 모든 서비스 중지
- `docker compose logs -f` - 실시간 로그 확인

### **❓ 문제가 생기면**
- **포트 충돌**: `docker compose down` 후 재시작
- **컨테이너 이름 충돌**: `docker compose down --volumes --rmi all` 후 재시작
- **Prisma 오류**: `docker compose run --rm backend npx prisma generate` 실행
- **UserLike 테이블 없음**: `npx prisma migrate deploy --schema packages/db/prisma/schema.prisma` 실행
- **환경변수 오류**: `export DATABASE_URL="postgresql://vk:vk@localhost:5432/vk?schema=public"` 설정
- **Prisma Studio 환경변수 오류**: 아래 "로컬 실행 방법" 참고
- **기존 Docker 정리**: [docs/DOCKER_CLEANUP_GUIDE.md](docs/DOCKER_CLEANUP_GUIDE.md) 참고
- **자세한 가이드**: [docs/README.md](docs/README.md) 참고

### **🔧 로컬에서 직접 실행하는 방법 (Docker 없이) - 권장!**

```bash
# 1. 의존성 설치
npm install

# 2. 환경변수 설정 (필수!)
export DATABASE_URL="postgresql://vk:vk@localhost:5432/vk?schema=public"

# 3. Prisma 클라이언트 생성 (필수!)
npx prisma generate --schema packages/db/prisma/schema.prisma

# 4. 데이터베이스 마이그레이션 실행 (필수!)
npx prisma migrate deploy --schema packages/db/prisma/schema.prisma

# 5. 환경변수 파일 설정
cp config/.env.example apps/backend/.env.local

# 6. 백엔드 디렉토리로 이동
cd apps/backend

# 7. 백엔드 서버 시작
npm run dev
```

**실행 결과:**
```
✔ Generated Prisma Client (v5.22.0) to .\node_modules\@prisma\client in 92ms
2 migrations found in prisma/migrations
Applying migration `20250828074306_init`
Applying migration `20250828082745_init`
All migrations have been successfully applied.
[dotenv@17.2.1] injecting env (9) from .env.local
{"level":30,"time":1757307024326,"pid":41496,"hostname":"JM","msg":"Server listening at http://0.0.0.0:3002"}
backend listening on http://localhost:3002
```

**주의**: 로컬 PostgreSQL이 실행 중이어야 합니다.

---

## 📚 상세 가이드

- **설치 및 사용법**: [docs/README.md](docs/README.md)
- **Docker & DB 정리**: [docs/DOCKER_CLEANUP_GUIDE.md](docs/DOCKER_CLEANUP_GUIDE.md)

---

*한국 관광지 정보를 제공하는 백엔드 API 서버입니다.*