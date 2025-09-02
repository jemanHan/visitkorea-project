# VisitKorea 프로젝트 WAS 서버 AWS 배포 디버깅 가이드

## 🎯 프로젝트 범위
**WAS 서버(EC2) 한정**으로 작성된 가이드입니다. 프론트엔드 관련 내용은 제외하고 백엔드 애플리케이션 실행과 웹서버 연동에 집중합니다.

## 🏗️ 현재 아키텍처
```
[웹서버 (Nginx)] ←→ [WAS 서버 (EC2:3002)] ←→ [PostgreSQL DB]
```
- **WAS 서버**: AWS EC2 인스턴스 (포트 3002)
- **백엔드**: Fastify + TypeScript + Prisma
- **데이터베이스**: PostgreSQL

## 🚀 1단계: AWS EC2 인스턴스 설정

### 1.1 EC2 인스턴스 생성
- **OS**: Amazon Linux 2023
- **인스턴스 타입**: t3.micro 이상
- **보안 그룹**: 포트 3002 열기

### 1.2 보안 그룹 설정
```bash
# 인바운드 규칙 추가
Type: Custom TCP
Port: 3002
Source: 0.0.0.0/0 (또는 특정 IP)
Description: WAS Backend Server
```

## 🔧 2단계: EC2 서버 초기 설정

### 2.1 Node.js 설치
```bash
# Node.js 20.x 설치
curl -fsSL https://rpm.nodesource.com/setup_20.x | sudo bash -
sudo yum install -y nodejs

# 버전 확인
node --version  # v20.x.x
npm --version   # 10.x.x
```

### 2.2 Git 설치 및 프로젝트 클론
```bash
sudo yum install -y git
cd /home/ec2-user
git clone [your-repository-url] visitkorea-project
cd visitkorea-project
```

## 📦 3단계: 프로젝트 의존성 설치

### 3.1 루트 레벨 의존성 설치
```bash
npm install
```

### 3.2 백엔드 의존성 설치
```bash
cd apps/backend
npm install
```

### 3.3 누락된 의존성 추가 설치 (중요!)
```bash
# Fastify 관련 의존성들 - 이 단계가 매우 중요!
npm install proxy-addr
npm install fast-content-type-parse
```

**⚠️ 이 단계가 없으면 "Cannot find module" 오류가 발생합니다.**

## 🛠️ 4단계: 백엔드 애플리케이션 설정

### 4.1 tsx 경로 수정 (핵심!)
`apps/backend/package.json` 수정:
```json
{
  "scripts": {
    "dev": "../../node_modules/.bin/tsx watch src/local.ts",
    "build": "tsc -b",
    "start": "node dist/local.mjs"
  }
}
```

**🔍 문제 원인**: 
- `tsx`가 `node_modules/.bin/`에 생성되지 않음
- Workspace 설정으로 인한 경로 문제
- 상대 경로로 해결

### 4.2 환경 변수 설정
`apps/backend/.env.local` 생성:
```bash
# 데이터베이스 연결
DATABASE_URL="postgresql://username:password@host:port/database"

# Google Places API
GOOGLE_PLACES_BACKEND_KEY="your-api-key"

# 포트 설정
PORT=3002
```

### 4.3 백엔드 라우트 추가
`apps/backend/src/app.ts`에 다음 엔드포인트 추가:

```typescript
// Health check endpoints
app.get("/health", async () => ({ ok: true }));
app.get("/v1/health", async () => ({ ok: true }));

// Database endpoints
app.get("/v1/db/users", async () => {
  try {
    const users = await prisma.user.findMany({
      select: {
        id: true,
        email: true,
        displayName: true,
        lang: true,
        createdAt: true,
        _count: {
          select: {
            likes: true,
            itineraries: true
          }
        }
      }
    });
    return { success: true, data: users };
  } catch (error) {
    return { success: false, error: error.message };
  }
});

app.get("/v1/db/places", async () => {
  try {
    const places = await prisma.place.findMany({
      take: 50,
      orderBy: { id: 'desc' }
    });
    return { success: true, data: places };
  } catch (error) {
    return { success: false, error: error.message };
  }
});

app.get("/v1/db/likes", async () => {
  try {
    const likes = await prisma.userLike.findMany({
      include: {
        user: {
          select: { email: true, displayName: true }
        }
      },
      take: 50,
      orderBy: { createdAt: 'desc' }
    });
    return { success: true, data: likes };
  } catch (error) {
    return { success: false, error: error.message };
  }
});
```

## 🚀 5단계: 백엔드 서버 실행

### 5.1 tmux 설치 및 세션 생성
```bash
# tmux 설치
sudo yum install -y tmux

# 백엔드 세션 생성
tmux new -s backend -d

# 백엔드 서버 실행
tmux send-keys -t backend "cd /home/ec2-user/visitkorea-project/apps/backend && npm run dev" Enter
```

**🔍 왜 tmux를 사용하는가?**
- 터미널 세션이 끊어져도 프로세스가 계속 실행됨
- `tsx watch`가 SIGINT 신호로 인해 종료되는 문제 해결
- 백그라운드에서 안정적인 서버 실행

### 5.2 tmux 세션 관리
```bash
# 세션 재접속
tmux attach -t backend

# 세션 분리 (Ctrl+b → d)
# 세션 목록 확인
tmux list-sessions

# 세션 종료
tmux kill-session -t backend
```

## 🧪 6단계: 연결 테스트

### 6.1 서버 상태 확인
```bash
# 포트 3002 사용 상태 확인
netstat -tlnp | grep :3002

# 프로세스 확인
ps aux | grep tsx
```

### 6.2 API 엔드포인트 테스트
```bash
# Health check
curl http://localhost:3002/health
curl http://localhost:3002/v1/health

# Database endpoints
curl http://localhost:3002/v1/db/users
curl http://localhost:3002/v1/db/places
curl http://localhost:3002/v1/db/likes
```

## 🗄️ 7단계: 데이터베이스 설정

### 7.1 Prisma 설정
```bash
cd packages/db

# Prisma 클라이언트 생성
npx prisma generate

# 데이터베이스 마이그레이션
npx prisma migrate dev

# Prisma Studio 실행 (웹 UI)
npx prisma studio
```

### 7.2 데이터베이스 스키마
`packages/db/prisma/schema.prisma`:
```prisma
model User {
  id           String      @id @default(cuid())
  email        String      @unique
  passwordHash String
  displayName  String?
  lang         String      @default("KR")
  createdAt    DateTime    @default(now())
  likes        UserLike[]
  itineraries  Itinerary[]
}

model Place {
  id        String   @id
  source    String
  placeId   String
  name      String
  address   String?
  lat       Float?
  lng       Float?
  tags      String[]
  items     ItineraryItem[]
}

model UserLike {
  id        String   @id @default(cuid())
  user      User     @relation(fields: [userId], references: [id])
  userId    String
  placeId   String
  name      String?
  address   String?
  rating    Float?
  tags      String[]
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  @@unique([userId, placeId])
  @@index([userId, placeId])
}

model Itinerary {
  id        String          @id @default(cuid())
  userId    String
  title     String
  startDate DateTime?
  endDate   DateTime?
  notes     String?
  createdAt DateTime        @default(now())
  user      User            @relation(fields: [userId], references: [id])
  items     ItineraryItem[]
}

model ItineraryItem {
  id          String   @id @default(cuid())
  itineraryId String
  placeId     String
  day         Int?
  startTime   String?
  endTime     String?
  memo        String?
  itinerary   Itinerary @relation(fields: [itineraryId], references: [id])
  place       Place     @relation(fields: [placeId], references: [id])
}

model PlaceCache {
  placeId   String  @id
  json      Json
  fetchedAt DateTime @default(now())
}
```

## 🚨 8단계: 문제 해결 (핵심!)

### 8.1 일반적인 오류들

#### EADDRINUSE (포트 이미 사용 중)
```bash
# 포트 사용 프로세스 확인
netstat -tlnp | grep :3002

# 프로세스 종료
kill [PID]
```

**🔍 해결 과정:**
1. `netstat -tlnp | grep :3002`로 프로세스 ID 확인
2. `kill [PID]`로 프로세스 종료
3. 포트 해제 확인 후 서버 재시작

#### tsx 모듈을 찾을 수 없음
```bash
# tsx 재설치
npm install tsx --save-dev

# package.json에서 경로 수정
"dev": "../../node_modules/.bin/tsx watch src/local.ts"
```

**🔍 문제 원인:**
- Workspace 설정으로 인해 `node_modules/.bin/tsx`가 생성되지 않음
- 상대 경로로 해결해야 함

#### Prisma 연결 오류
```bash
# 환경 변수 확인
cat .env.local | grep DATABASE

# Prisma 클라이언트 재생성
npx prisma generate
```

### 8.2 로그 확인
```bash
# tmux 세션에서 로그 확인
tmux attach -t backend

# 백그라운드 프로세스 로그
pm2 logs backend-dev  # PM2 사용 시
```

## 🔗 9단계: 웹서버 연동

### 9.1 Nginx 설정 예시
```nginx
server {
    listen 80;
    server_name your-domain.com;

    location /v1/ {
        proxy_pass http://localhost:3002;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### 9.2 연결 테스트
```bash
# 외부에서 접근 테스트
curl http://[EC2-PUBLIC-IP]:3002/v1/health
curl http://[EC2-PUBLIC-IP]:3002/v1/db/users
```

## ✅ 10단계: 배포 완료 확인

### 10.1 서비스 상태 확인
- ✅ 백엔드 서버: `http://0.0.0.0:3002`에서 실행 중
- ✅ Health check: `/health`, `/v1/health` → 200 OK
- ✅ Database API: `/v1/db/*` → 정상 응답
- ✅ 외부 접근: 보안 그룹 포트 3002 열림

### 10.2 모니터링 명령어
```bash
# 서버 상태 확인
netstat -tlnp | grep :3002

# tmux 세션 상태
tmux list-sessions

# 프로세스 상태
ps aux | grep tsx

# API 응답 테스트
curl http://localhost:3002/v1/health
```

## 🔧 11단계: 유지보수

### 11.1 서버 재시작
```bash
# tmux 세션에서 서버 재시작
tmux attach -t backend
Ctrl+c  # 서버 중지
npm run dev  # 서버 재시작
Ctrl+b → d  # 세션 분리
```

### 11.2 코드 업데이트
```bash
# Git pull
git pull origin main

# 의존성 업데이트
npm install

# 서버 재시작
tmux send-keys -t backend C-c
tmux send-keys -t backend "npm run dev" Enter
```

## 🚨 12단계: 디버깅 체크리스트

### 12.1 서버 실행 전 체크
- [ ] Node.js 20.x 설치됨
- [ ] 프로젝트 클론 완료
- [ ] 의존성 설치 완료 (`proxy-addr`, `fast-content-type-parse`)
- [ ] `package.json`의 tsx 경로 수정됨
- [ ] 환경 변수 파일 생성됨

### 12.2 서버 실행 후 체크
- [ ] 포트 3002에서 리스닝 중
- [ ] tmux 세션이 백그라운드에서 실행 중
- [ ] `/health` 엔드포인트 응답 확인
- [ ] `/v1/health` 엔드포인트 응답 확인
- [ ] 외부에서 접근 가능

### 12.3 데이터베이스 연결 체크
- [ ] Prisma 클라이언트 생성됨
- [ ] 데이터베이스 마이그레이션 완료
- [ ] `/v1/db/*` 엔드포인트 응답 확인
- [ ] Prisma Studio 접근 가능

## 📝 13단계: 문제 해결 로그

### 13.1 실제 발생한 오류들

#### 오류 1: Cannot find module 'proxy-addr'
```bash
Error: Cannot find module 'proxy-addr'
Require stack:
- /home/ec2-user/visitkorea-project/apps/backend/node_modules/fastify/lib/request.js
- /home/ec2-user/visitkorea-project/apps/backend/node_modules/fastify/fastify.js
```

**해결 방법:**
```bash
npm install proxy-addr
```

#### 오류 2: Cannot find module 'fast-content-type-parse'
```bash
Error: Cannot find module 'fast-content-type-parse'
```

**해결 방법:**
```bash
npm install fast-content-type-parse
```

#### 오류 3: tsx 모듈을 찾을 수 없음
```bash
npm error Lifecycle script `dev` failed with error:
npm error code 130
```

**해결 방법:**
```json
// package.json 수정
"dev": "../../node_modules/.bin/tsx watch src/local.ts"
```

#### 오류 4: EADDRINUSE (포트 이미 사용 중)
```bash
Error: listen EADDRINUSE: address already in use 0.0.0.0:3002
```

**해결 방법:**
```bash
# 프로세스 확인 및 종료
netstat -tlnp | grep :3002
kill [PID]
```

### 13.2 성공적인 해결 과정
1. **의존성 문제 해결**: `proxy-addr`, `fast-content-type-parse` 설치
2. **tsx 경로 문제 해결**: 상대 경로로 수정
3. **포트 충돌 해결**: tmux를 사용한 안정적인 서버 실행
4. **라우트 문제 해결**: `/v1/health` 경로 추가
5. **데이터베이스 API 추가**: `/v1/db/*` 엔드포인트 구현

## 🎯 14단계: 핵심 포인트 요약

### 14.1 반드시 필요한 단계들
1. **의존성 추가 설치**: `proxy-addr`, `fast-content-type-parse`
2. **tsx 경로 수정**: `../../node_modules/.bin/tsx`
3. **tmux 사용**: 백그라운드에서 안정적인 서버 실행
4. **라우트 추가**: `/v1/health`, `/v1/db/*` 엔드포인트

### 14.2 자주 발생하는 문제들
- 의존성 누락으로 인한 모듈 오류
- tsx 경로 문제로 인한 실행 실패
- 터미널 세션 종료로 인한 프로세스 중단
- 포트 충돌로 인한 서버 시작 실패

### 14.3 성공적인 배포의 핵심
- **단계별 문제 해결**: 각 오류를 하나씩 해결
- **안정적인 서버 실행**: tmux를 사용한 백그라운드 실행
- **완전한 API 구현**: health check부터 데이터베이스 조회까지
- **외부 접근 가능**: `0.0.0.0:3002` 바인딩

---

**⚠️ 주의사항:**
- 환경 변수 파일(.env.local)은 절대 Git에 커밋하지 마세요
- `tsx watch`는 터미널 세션 종료에 취약하므로 tmux 사용을 권장합니다
- 의존성 설치 순서가 중요합니다 (`proxy-addr`, `fast-content-type-parse` 먼저)
- 포트 3002가 이미 사용 중일 때는 반드시 프로세스를 종료해야 합니다

이 가이드를 따라하면 VisitKorea 프로젝트의 WAS 서버를 AWS EC2에 성공적으로 배포하고 웹서버와 연동할 수 있습니다.
