# VisitKorea 프로젝트

## 🚀 빠른 시작 (팀원용)

### 방법 1: 원클릭 시작 (추천)
**Windows:**
```bash
git clone https://github.com/jemanHan/visitkorea-project-was.git
cd visitkorea-project-was
npm install
powershell -ExecutionPolicy Bypass -File ./scripts/start-dev.ps1
```

**Linux/Mac:**
```bash
git clone https://github.com/jemanHan/visitkorea-project-was.git
cd visitkorea-project-was
npm install
chmod +x scripts/start-dev.sh
./scripts/start-dev.sh
```

### 방법 2: 단계별 실행
**1. 프로젝트 클론 및 의존성 설치**
```bash
git clone https://github.com/jemanHan/visitkorea-project-was.git
cd visitkorea-project-was
npm install
```

**2. 환경변수 파일 생성**
```bash
# Windows
powershell -ExecutionPolicy Bypass -File scripts\setup-env.ps1

# Linux/Mac
chmod +x scripts/setup-env.sh
./scripts/setup-env.sh
```

**3. Docker 서비스 시작**
```bash
docker compose up -d db
docker compose build backend
docker compose run --rm backend npx prisma generate --schema packages/db/prisma/schema.prisma
docker compose run --rm backend npx prisma migrate deploy --schema packages/db/prisma/schema.prisma
docker compose up -d backend
```

**4. 서비스 확인**
- **Backend API**: http://localhost:3002
- **Health Check**: http://localhost:3002/health

---

## 📋 상세 설정

### 🔑 Google Places API 키 설정
`apps/backend/.env` 파일을 열어서 다음 값을 실제 API 키로 변경하세요:
```env
GOOGLE_PLACES_BACKEND_KEY="your_actual_google_places_api_key_here"
```

### 🛠️ 개발 모드
현재 백엔드는 개발 모드로 실행됩니다 (tsx watch 사용):
- 코드 변경 시 자동 재시작
- TypeScript 실시간 컴파일

### 🗄️ 데이터베이스
- **PostgreSQL 15** 사용
- **Prisma ORM**으로 데이터베이스 관리
- 마이그레이션 자동 적용

---

## ❓ 문제 해결

### Docker 관련 문제
```bash
# 모든 컨테이너 정리 후 재시작
docker compose down --volumes --rmi all
docker compose up -d db
docker compose build backend
docker compose up -d backend
```

### Prisma 관련 문제
```bash
# Prisma 클라이언트 재생성
docker compose run --rm backend npx prisma generate --schema packages/db/prisma/schema.prisma

# 마이그레이션 재실행
docker compose run --rm backend npx prisma migrate deploy --schema packages/db/prisma/schema.prisma
```

### 환경변수 문제
```bash
# 환경변수 파일 재생성
# Windows
powershell -ExecutionPolicy Bypass -File scripts\setup-env.ps1

# Linux/Mac
./scripts/setup-env.sh
```

### 서비스 상태 확인
```bash
# 컨테이너 상태 확인
docker compose ps

# 로그 확인
docker compose logs backend
docker compose logs db
```

---

## 🔧 기술 스택

- **Backend**: Node.js 20, TypeScript, Fastify
- **Database**: PostgreSQL 15, Prisma ORM
- **Container**: Docker, Docker Compose
- **Development**: tsx (TypeScript 실행기)

---

## 📁 프로젝트 구조

```
visitkorea-project-was/
├── apps/backend/          # 백엔드 애플리케이션
├── packages/              # 공유 패키지들
│   ├── db/               # 데이터베이스 관련
│   ├── domain/           # 도메인 엔티티
│   └── shared-types/     # 공유 타입 정의
├── scripts/              # 설정 스크립트
└── docker-compose.yml    # Docker 설정
```
