# VisitKorea 프로젝트

## 👥 팀원들을 위한 시작 가이드

### **🚀 가장 간단한 시작 방법**

```bash
# 1. 프로젝트 클론
git clone <repository-url>
cd visitkorea-project

# 2. 의존성 설치
npm install

# 3. 환경변수 설정
cp config/.env.example apps/backend/.env.local

# 4. Google Places API 키 수정 (필수)
vim apps/backend/.env.local
# GOOGLE_PLACES_BACKEND_KEY=your_actual_api_key_here

# 5. 서비스 시작
npm run dev:docker
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
- `npm run dev:docker` - 개발 환경 시작
- `npm run stop:docker` - 서비스 중지
- `npm run logs:docker` - 로그 확인

### **❓ 문제가 생기면**
- **Docker 없음**: `npm run dev:full` 사용
- **포트 충돌**: `npm run stop:docker` 후 재시작
- **자세한 가이드**: [docs/README.md](docs/README.md) 참고

---

## 📚 상세 가이드

모든 설치, 배포, 사용법에 대한 상세한 가이드는 [docs/README.md](docs/README.md)를 참고하세요.

---

*한국 관광지 정보를 제공하는 백엔드 API 서버입니다.*

