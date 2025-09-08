# VisitKorea 프로젝트 완전 가이드

## 🚀 프로젝트 개요

- **WAS 서버**: PostgreSQL + Prisma + Node.js 백엔드
- **Web 서버**: 프론트엔드 애플리케이션  
- **아키텍처**: 클린 아키텍처 + 모노레포 구조
- **배포**: AWS EC2 + Docker

## 📋 사전 요구사항

- **Node.js**: 20.x 이상
- **npm**: 9.x 이상
- **Docker**: PostgreSQL 실행용
- **Git**: 프로젝트 클론용

---

## 🏗️ 현재 아키텍처

```
[웹서버 (Nginx)] ←→ [WAS 서버 (EC2:3002)] ←→ [PostgreSQL DB]
```

- **WAS 서버**: AWS EC2 인스턴스 (포트 3002)
- **백엔드**: Fastify + TypeScript + Prisma
- **데이터베이스**: PostgreSQL

---

## 🚀 빠른 시작 (처음부터)

### 1. 프로젝트 클론
```bash
# Git에서 프로젝트 클론
git clone <repository-url>
cd visitkorea-project
```

### 2. 의존성 설치
```bash
npm install
```

### 3. 환경변수 설정
```bash
# 환경변수 템플릿을 백엔드에 복사
cp config/.env.example apps/backend/.env.local

# 🔑 Google Places API 키만 수정 (필수)
vim apps/backend/.env.local
# GOOGLE_PLACES_BACKEND_KEY=your_actual_api_key_here
```

#### **개인 설정 필수 항목들:**
- **Google Places API 키**: Google Cloud Console에서 발급 (유일한 개인 설정)

#### **Google Places API 키 발급 방법:**
1. [Google Cloud Console](https://console.cloud.google.com/) 접속
2. 프로젝트 생성 또는 선택
3. "APIs & Services" → "Credentials" 이동
4. "Create Credentials" → "API Key" 선택
5. 발급된 키를 `GOOGLE_PLACES_BACKEND_KEY`에 입력

#### **공통 설정 항목들 (수정 불필요):**
- **JWT Secret**: 기본값 `change-me` 사용 (나중에 EC2에서 통일)
- **데이터베이스**: 모든 팀원이 동일한 DB 사용
- **포트, 캐시 등**: 기본값 그대로 사용

### 4. 서비스 시작 (두 가지 방법 중 선택)

#### **방법 A: Docker Compose (권장) - 모든 것이 자동으로 시작됨**
```bash
# 개발 환경 (Prisma Studio 포함)
npm run dev:docker

# 또는 운영 환경 (백엔드만)
npm run start:docker
```

#### **방법 B: 기존 방식 (PostgreSQL만 Docker 사용)**
```bash
# PostgreSQL 컨테이너 시작 + 백엔드 시작
npm run dev:full
```

#### **방법 C: 완전 로컬 (Docker 사용 안함)**
```bash
# PostgreSQL 로컬 설치 후
npm run dev
```

### 5. 서비스 확인
```bash
# 백엔드 API 확인
curl http://localhost:3002/health

# Prisma Studio 확인 (개발 모드에서만)
# 브라우저에서 http://localhost:5555 접속
```

### 6. 완료! 🎉
서비스가 정상적으로 시작되면 다음 URL에서 확인할 수 있습니다:
- **Backend API**: http://localhost:3002
- **Health Check**: http://localhost:3002/health
- **Prisma Studio**: http://localhost:5555 (개발 모드에서만)

---

## 📋 사용 가능한 명령어

### Docker Compose 명령어
- `npm run start:docker` - 운영 환경 시작 (백엔드만)
- `npm run dev:docker` - 개발 환경 시작 (백엔드 + Prisma Studio)
- `npm run stop:docker` - 모든 서비스 중지
- `npm run logs:docker` - 실시간 로그 확인

### 기존 방식 명령어
- `npm run dev:full` - 기존 Docker 컨테이너 사용하여 시작
- `npm run env:update` - 환경변수 업데이트

### 개별 서비스
- `npm run dev` - 백엔드만 시작 (로컬)
- `npm run build` - 백엔드 빌드

---

## 🔧 환경변수 관리

### IP 주소 변경 시
```bash
# 자동 업데이트
npm run env:update

# 또는 수동 수정
vim apps/backend/.env.local
```

### Docker 환경변수 수정
```bash
# .env.docker 파일 수정
vim config/.env.docker

# 서비스 재시작
npm run stop:docker
npm run start:docker
```

---

## 🌐 서비스 URL

- **Backend API**: http://localhost:3002
- **Health Check**: http://localhost:3002/health
- **Prisma Studio**: http://localhost:5555 (개발 모드에서만)

---

## 🐳 Docker 서비스 구성

### PostgreSQL
- **컨테이너명**: vk-postgres
- **포트**: 5432
- **데이터베이스**: vk
- **사용자**: vk/vk

### Backend
- **컨테이너명**: vk-backend
- **포트**: 3002
- **헬스체크**: 자동 모니터링

### Prisma Studio (개발용)
- **컨테이너명**: vk-prisma-studio
- **포트**: 5555
- **프로파일**: dev

---

## 🔍 문제 해결

### 팀원들이 자주 겪는 문제들

#### **1. Docker가 없는 경우**
```bash
# 방법 A: Docker 설치
# Ubuntu/Debian
sudo apt update && sudo apt install docker.io docker-compose

# macOS
brew install docker docker-compose

# 방법 B: Docker 없이 실행 (PostgreSQL만 Docker 사용)
npm run dev:full
```

#### **2. 포트 충돌 문제 (Docker 컨테이너명 충돌)**
```bash
# 기존 컨테이너 정리
npm run stop:docker
docker system prune -f

# 새로 시작
npm run start:docker
```

#### **2-1. 기존 PostgreSQL 컨테이너와 충돌하는 경우**
```bash
# 기존 vk-postgres 컨테이너가 있는 경우
docker stop vk-postgres
docker rm vk-postgres

# 새로 시작
npm run dev:docker
```

#### **3. 환경변수 파일이 없는 경우**
```bash
# 환경변수 템플릿 복사
cp config/.env.example apps/backend/.env.local

# 확인
cat apps/backend/.env.local
```

#### **4. 의존성 설치 실패**
```bash
# 캐시 정리 후 재설치
rm -rf node_modules package-lock.json
npm install
```

#### **5. 서비스 상태 확인**
```bash
# 컨테이너 상태 확인
docker-compose ps

# 로그 확인
npm run logs:docker

# 개별 서비스 로그
docker-compose logs backend
docker-compose logs postgres
```

#### **6. 데이터베이스 연결 문제**
```bash
# PostgreSQL 컨테이너 재시작
docker-compose restart postgres

# 백엔드 재시작
docker-compose restart backend
```

#### **7. 502 Bad Gateway 에러**
```bash
# 1. 백엔드 서버 상태 확인
ps aux | grep node

# 2. 포트 확인
netstat -tlnp | grep :3002

# 3. 환경변수 확인
cat apps/backend/.env.local

# 4. 서비스 재시작
npm run stop:docker
npm run start:docker
```

#### **8. Prisma Studio 접속 안됨**
```bash
# 개발 모드로 재시작
npm run dev:docker

# 브라우저에서 http://localhost:5555 접속
```

---

## 📁 파일 구조

```
visitkorea-project/
├── docker-compose.yml      # Docker Compose 설정
├── scripts/                # 스크립트 폴더
│   ├── docker-start.sh     # 운영 환경 시작 스크립트
│   ├── docker-dev.sh       # 개발 환경 시작 스크립트
│   ├── start-services.sh   # 기존 방식 시작 스크립트
│   └── update-env.sh       # 환경변수 업데이트 스크립트
├── config/                 # 설정 파일 폴더
│   ├── .env.docker         # Docker 환경변수
│   └── .env.example        # 환경변수 템플릿
├── docs/                   # 문서 폴더
│   └── README.md           # 이 파일
├── apps/backend/           # 백엔드 코드
│   ├── Dockerfile          # Docker 이미지 설정
│   └── .env.local          # 로컬 환경변수
└── packages/               # 공유 패키지들
    ├── db/                 # 데이터베이스 관련
    ├── domain/             # 도메인 로직
    └── adapters/           # 외부 어댑터
```

---

## 🎯 권장 사용법

1. **개발 시**: `npm run dev:docker` (Prisma Studio 포함)
2. **운영 시**: `npm run start:docker` (백엔드만)
3. **IP 변경 시**: `npm run env:update`
4. **문제 발생 시**: `npm run logs:docker`로 로그 확인

---

## 👥 팀원들을 위한 요약

### **가장 간단한 시작 방법 (Docker 사용)**
```bash
git clone <repository-url>
cd visitkorea-project
npm install
cp config/.env.example apps/backend/.env.local
# Google Places API 키만 수정
vim apps/backend/.env.local
npm run dev:docker
```

### **Docker가 없는 경우**
```bash
git clone <repository-url>
cd visitkorea-project
npm install
cp config/.env.example apps/backend/.env.local
# Google Places API 키만 수정
vim apps/backend/.env.local
npm run dev:full
```

### **기존 Docker 컨테이너와 충돌하는 경우**
```bash
# 기존 컨테이너 정리
docker stop vk-postgres 2>/dev/null || true
docker rm vk-postgres 2>/dev/null || true

# 새로 시작
npm run dev:docker
```

### **자주 사용하는 명령어**
- `npm run dev:docker` - 개발 환경 시작
- `npm run stop:docker` - 서비스 중지
- `npm run logs:docker` - 로그 확인
- `npm run env:update` - 환경변수 업데이트

### **확인할 URL**
- **Backend API**: http://localhost:3002
- **Health Check**: http://localhost:3002/health
- **Prisma Studio**: http://localhost:5555 (개발 모드에서만)

---

## 🚀 AWS 배포 정보

### 현재 서버 정보
- **WAS 서버 IP**: 13.209.108.148 (탄력적 IP - 고정됨)
- **웹서버 IP**: 52.79.156.197 (탄력적 IP - 고정됨)
- **포트**: 3002
- **OS**: Amazon Linux 2023
- **인스턴스 타입**: t3.micro

### 보안 그룹 설정
- **포트 3002**: WAS 서버용 (웹서버에서 접근)
- **포트 5432**: PostgreSQL용 (로컬에서만)

### 웹서버 연동
- **Nginx 설정**: `proxy_pass http://13.209.108.148:3002`
- **헬스체크**: `http://13.209.108.148:3002/health`

---

## 🔧 Prisma Studio 환경변수 오류 해결

### **오류**: `Environment variable not found: DATABASE_URL`

**해결방법**:
```bash
# 1. 환경변수 설정
export DATABASE_URL="postgresql://vk:vk@localhost:5432/vk?schema=public"

# 2. Prisma Studio 시작
cd apps/backend
npx prisma studio --schema=../../packages/db/prisma/schema.prisma
```

**또는 .env.local 파일 사용**:
```bash
# apps/backend/.env.local 파일이 있으면 자동으로 로드됨
cd apps/backend
npx prisma studio --schema=../../packages/db/prisma/schema.prisma
```

---

## 📞 지원

문제가 발생하면 다음 순서로 확인하세요:

1. **서비스 상태**: `docker-compose ps`
2. **로그 확인**: `npm run logs:docker`
3. **환경변수**: `cat apps/backend/.env.local`
4. **네트워크**: `curl http://localhost:3002/health`
5. **Prisma 환경변수**: `echo $DATABASE_URL`

---

*마지막 업데이트: 2024년 9월 4일*
