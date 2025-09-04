# VisitKorea 백엔드 프로젝트

## 🚀 빠른 시작 가이드

### **1단계: 프로젝트 설정**
```bash
# 의존성 설치
npm install

# 환경변수 설정
cp config/.env.example apps/backend/.env.local
```

### **2단계: 포트 충돌 해결**
```bash
# 5432 포트 사용 중인 컨테이너 확인
docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Ports}}" | findstr 5432

# 해당 컨테이너 중지
docker stop <컨테이너ID>
```

### **3단계: Prisma 클라이언트 생성**
```bash
# Prisma 클라이언트 생성 (필수!)
npx prisma generate --schema packages/db/prisma/schema.prisma
```

### **4단계: 서비스 시작**

**방법 1: Docker로 실행 (권장)**
```bash
# Docker 개발 환경 시작
npm run dev:docker
```

**방법 2: 백엔드만 직접 실행**
```bash
# 백엔드 디렉토리에서 실행
cd apps/backend
npm run dev
```

## 🌐 서비스 URL
- **Backend API**: http://localhost:3002
- **Health Check**: http://localhost:3002/health
- **Prisma Studio**: http://localhost:5555

## 🔧 자주 발생하는 오류 해결

### **@db/client 모듈을 찾을 수 없음**
```bash
# 워크스페이스 재설치
npm install

# Prisma 클라이언트 재생성
npx prisma generate --schema packages/db/prisma/schema.prisma
```

### **5432 포트 충돌**
```bash
# 기존 PostgreSQL 컨테이너 중지
docker stop $(docker ps -q --filter "publish=5432")
```

### **TypeScript 빌드 오류**
```bash
# 전체 프로젝트 빌드 테스트
npm run build
```

## 📋 주요 명령어

### **루트에서 실행**
- `npm run dev:docker` - Docker 개발 환경 시작
- `npm run stop:docker` - 서비스 중지
- `npm run build` - 프로젝트 빌드
- `npm run logs:docker` - 로그 확인

### **백엔드 디렉토리에서 실행**
```bash
cd apps/backend
npm run dev      # 개발 서버 시작
npm run build    # 프로덕션 빌드
npm start        # 빌드된 서버 실행
```

---

## 📚 상세 가이드

더 자세한 설치, 배포, 사용법은 [docs/README.md](docs/README.md)를 참고하세요.

---

*한국 관광지 정보를 제공하는 백엔드 API 서버입니다.*

